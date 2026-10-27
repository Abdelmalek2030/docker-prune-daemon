package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/signal"
	"syscall"
	"time"
)

// Config holds deterministic runtime parameters for the daemon.
type Config struct {
	Interval  time.Duration
	Threshold int
	DryRun    bool
	Once      bool
	Until     string
}

// Validate enforces strict invariants on runtime configuration.
func (c Config) Validate() error {
	if c.Interval < time.Second {
		return errors.New("interval must be at least 1s")
	}
	if c.Threshold < 1 || c.Threshold > 99 {
		return errors.New("threshold must be between 1 and 99 percent")
	}
	if c.Until == "" {
		return errors.New("until filter duration cannot be empty")
	}
	return nil
}

// DiskUsagePercent inspects filesystem utilization for the given path.
func DiskUsagePercent(path string) (int, error) {
	var stat syscall.Statfs_t
	if err := syscall.Statfs(path, &stat); err != nil {
		return 0, err
	}
	if stat.Blocks == 0 {
		return 0, nil
	}
	used := stat.Blocks - stat.Bavail
	percent := int((used * 100) / stat.Blocks)
	return percent, nil
}

// ShouldPrune evaluates whether current disk pressure exceeds the configured watermark.
func ShouldPrune(usage, threshold int) bool {
	return usage >= threshold
}

// BuildPruneArgs constructs deterministic Docker CLI arguments.
func BuildPruneArgs(cfg Config) []string {
	return []string{
		"system", "prune",
		"--all",
		"--force",
		"--filter", fmt.Sprintf("until=%s", cfg.Until),
	}
}

func runCycle(ctx context.Context, cfg Config, rootPath string) error {
	usage, err := DiskUsagePercent(rootPath)
	if err != nil {
		return fmt.Errorf("statfs %s failed: %w", rootPath, err)
	}

	log.Printf("[INFO] disk_usage=%d%% threshold=%d%% dry_run=%v", usage, cfg.Threshold, cfg.DryRun)

	if !ShouldPrune(usage, cfg.Threshold) {
		return nil
	}

	args := BuildPruneArgs(cfg)
	if cfg.DryRun {
		log.Printf("[DRY-RUN] threshold exceeded; would execute: docker %v", args)
		return nil
	}

	cmd := exec.CommandContext(ctx, "docker", args...)
	out, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("docker prune failed: %w (output: %s)", err, string(out))
	}
	log.Printf("[OK] reclaim cycle completed: %s", string(out))
	return nil
}

func main() {
	var cfg Config
	var showVersion bool

	flag.DurationVar(&cfg.Interval, "interval", 30*time.Minute, "Polling interval between disk audits")
	flag.IntVar(&cfg.Threshold, "threshold", 80, "Disk usage percentage watermark (1-99) to trigger prune")
	flag.BoolVar(&cfg.DryRun, "dry-run", false, "Inspect disk usage and log actions without pruning")
	flag.BoolVar(&cfg.Once, "once", false, "Execute a single audit cycle and exit")
	flag.StringVar(&cfg.Until, "until", "24h", "Prune resources created before this duration")
	flag.BoolVar(&showVersion, "version", false, "Print version information and exit")
	flag.Parse()

	if showVersion {
		fmt.Println("docker-prune-daemon v1.0.0")
		return
	}

	if err := cfg.Validate(); err != nil {
		log.Fatalf("[FATAL] invalid configuration: %v", err)
	}

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM, syscall.SIGHUP)
	defer stop()

	rootPath := os.Getenv("DOCKER_DATA_ROOT")
	if rootPath == "" {
		rootPath = "/"
	}

	log.Printf("[START] docker-prune-daemon initialized (interval=%s, threshold=%d%%, root=%s)", cfg.Interval, cfg.Threshold, rootPath)

	if err := runCycle(ctx, cfg, rootPath); err != nil {
		log.Printf("[WARN] cycle error: %v", err)
	}
	if cfg.Once {
		return
	}

	ticker := time.NewTicker(cfg.Interval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			log.Println("[STOP] termination signal received; shutting down gracefully")
			return
		case <-ticker.C:
			if err := runCycle(ctx, cfg, rootPath); err != nil {
				log.Printf("[WARN] cycle error: %v", err)
			}
		}
	}
}
