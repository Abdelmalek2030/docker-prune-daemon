# docker-prune-daemon

A lightweight, zero-dependency background daemon written in Go for autonomous disk space reclaim, dangling image cleanup, and Docker resource maintenance across Linux production and staging environments.

[![CI](https://github.com/Abdelmalek2030/docker-prune-daemon/actions/workflows/ci.yml/badge.svg)](https://github.com/Abdelmalek2030/docker-prune-daemon/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![Go Reference](https://img.shields.io/badge/Go-1.22%2B%20(Zero--Deps)-00ADD8.svg)](#architecture--design-philosophy)

---

## Architecture & Design Philosophy

- **Zero External Dependencies**: Built strictly on the Go standard library (`syscall`, `context`, `os/signal`, `os/exec`) with zero third-party module bloat and zero supply-chain risk.
- **Kernel-Level Disk Inspection**: Evaluates filesystem watermarks directly via `syscall.Statfs` with sub-microsecond overhead before invoking Docker CLI subprocesses.
- **Persistent Volume Safety**: Reclaims stopped containers, dangling images, and build caches older than a configurable duration (`-until`) without ever touching persistent named volumes.
- **Hardened Systemd Integration**: Ships with a strict Cgroups v2 service unit (`MemoryMax=32M`, `CPUQuota=10%`, `ProtectSystem=strict`, `NoNewPrivileges=true`).
- **Formal Specifications**:
  - [System Architecture & Execution Pipeline](docs/ARCHITECTURE.md)
  - [Security Threat Model & Isolation Guarantees](docs/THREAT_MODEL.md)

---

## CLI Flags & Configuration

| Flag | Default | Description |
| :--- | :--- | :--- |
| `-interval` | `30m` | Polling interval between disk pressure audits (e.g., `15m`, `1h`). |
| `-threshold` | `80` | Disk usage percentage watermark (`1-99`) required to trigger cleanup. |
| `-until` | `24h` | Only prune resources created before this duration filter. |
| `-dry-run` | `false` | Inspect disk watermarks and log intended actions without pruning. |
| `-once` | `false` | Execute a single audit cycle and exit deterministically. |
| `-version` | `false` | Print version identifier and exit. |

*Environment Variable*: Set `DOCKER_DATA_ROOT` (defaults to `/`) to inspect a dedicated Docker partition (e.g., `/var/lib/docker`).

---

## Installation & Systemd Deployment

### Method 1: Standalone One-Line Bootstrap (Recommended)

Install the latest release binary, systemd service unit, and man(8) page automatically:

```sh
curl -sSfL [https://raw.githubusercontent.com/Abdelmalek2030/docker-prune-daemon/main/install.sh](https://raw.githubusercontent.com/Abdelmalek2030/docker-prune-daemon/main/install.sh) | sudo sh
```

### Method 2: Build & Install via Makefile

```sh
git clone git@github.com:Abdelmalek2030/docker-prune-daemon.git
cd docker-prune-daemon

# Compile stripped static binary (CGO_ENABLED=0) and install unit + man(8) page
sudo make install

# Enable and start the background service
sudo systemctl daemon-reload
sudo systemctl enable --now docker-prune-daemon.service
```

### Standalone Execution

```sh
# Run a single non-destructive dry-run check at a 75% threshold
./docker-prune-daemon -threshold=75 -dry-run -once

# Read section 8 UNIX manual page locally
man ./man/docker-prune-daemon.8
```

---

## Quality Gates & Verification

```sh
# 1. Verify gofmt formatting compliance
make check

# 2. Run go vet static analysis
make lint

# 3. Execute behavioral unit tests with race detector enabled
make test

# 4. Benchmark statfs syscall latency
make bench
```

---

## Security & Governance

- [Security Policy & Vulnerability Disclosure](SECURITY.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Changelog History](CHANGELOG.md)

---

## License

Released under the [MIT License](LICENSE). Engineered by [Abdelmalek](https://github.com/Abdelmalek2030).
