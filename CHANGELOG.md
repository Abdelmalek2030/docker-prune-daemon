# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-10-27

### Added
- Core Go background daemon with `syscall.Statfs` disk usage watermark evaluation.
- Context-aware signal trapping (`SIGINT`, `SIGTERM`, `SIGHUP`) and `--dry-run` / `--once` execution modes.
- Hardened `systemd` service unit with Cgroups v2 resource caps (`MemoryMax=32M`).
- Section 8 UNIX manual page (`man/docker-prune-daemon.8`) and static `CGO_ENABLED=0` `Makefile`.
- Automated GitHub Actions CI pipeline for `gofmt`, `go vet`, race detection, and syscall benchmarks.
