# docker-prune-daemon

<div align="center">

[![CI Matrix & Quality Gate](https://github.com/Abdelmalek2030/docker-prune-daemon/actions/workflows/ci.yml/badge.svg)](https://github.com/Abdelmalek2030/docker-prune-daemon/actions/workflows/ci.yml)
[![Security Audit](https://github.com/Abdelmalek2030/docker-prune-daemon/actions/workflows/security-audit.yml/badge.svg)](https://github.com/Abdelmalek2030/docker-prune-daemon/actions/workflows/security-audit.yml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/Abdelmalek2030/docker-prune-daemon/badge)](https://securityscorecards.dev/projects/github.com/Abdelmalek2030/docker-prune-daemon)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Go Version](https://img.shields.io/badge/Go-1.22%2B-blue.svg)](go.mod)
[![Architecture](https://img.shields.io/badge/Architecture-100%25%20Go-orange.svg)]()
[![Zero-Deps](https://img.shields.io/badge/Dependencies-Zero-green.svg)]()

**A reference-grade, zero-dependency background daemon written in Go for autonomous Docker disk space reclaim, statfs watermark auditing, and systemd resource maintenance.**

</div>

---

## 🏗️ Architecture & Design Philosophy

`docker-prune-daemon` is meticulously engineered for mission-critical Linux environments adhering to strict *Zero Bloat & Minimal Surface Area* principles:

- **Zero External Dependencies**: Built strictly on the Go standard library (`syscall`, `context`, `os/signal`, `os/exec`) with zero third-party module bloat and zero supply-chain risk.
- **Kernel-Level Disk Inspection**: Evaluates filesystem watermarks directly via high-precision `syscall.Statfs` with sub-microsecond overhead before invoking Docker CLI cleanup commands.
- **Systemd Sandboxing & Cgroups v2**: Enforces hard resource ceilings (`MemoryMax=32M`, `CPUQuota=10%`) to guarantee zero host resource starvation under heavy container workloads.
- **Industrial Release & Provenance**: Automated multi-architecture cross-compilation via GoReleaser and cryptographic artifact attestation (SLSA).

---

## 🚀 Quick Installation (One-Line Bootstrap)

To install the binary, systemd unit file, and UNIX manual page (`man8`) instantly on your production node:

```sh
curl -sSL [https://raw.githubusercontent.com/Abdelmalek2030/docker-prune-daemon/main/install.sh](https://raw.githubusercontent.com/Abdelmalek2030/docker-prune-daemon/main/install.sh) | sudo bash
