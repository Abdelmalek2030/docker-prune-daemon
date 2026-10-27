# Changelog

All notable changes to `docker-prune-daemon` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0-0.html).

## [1.0.0] - 2026-10-16

### Added
- Initial production release of `docker-prune-daemon`.
- Zero-dependency Go core utilizing kernel-level `syscall.Statfs` watermark auditing.
- Hardened systemd service unit with Cgroups v2 resource ceilings (`MemoryMax=32M`).
- Automated one-line curl bootstrap installer (`install.sh`).
- UNIX manual page for system administration (`man/docker-prune-daemon.8`).
- Comprehensive CI/CD matrix, Go fuzzing, and CodeQL semantic security pipelines.
