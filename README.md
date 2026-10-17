# docker-prune-daemon 🐳

A lightweight background daemon designed for automated disk space reclaim, dangling image cleanup, and Docker resource maintenance across development and staging environments.

## ✨ Features
- **Configurable Thresholds:** Automatically triggers cleanup based on disk usage percentages.
- **Selective Pruning:** Safely removes dangling images, stopped containers, and unused build caches without touching persistent volumes.
- **Zero Overhead:** Minimal CPU/memory footprint implemented in Go.
- **Open Source:** Licensed under the MIT License.

## 🚀 Quick Start

### Build & Run
```bash
git clone [https://github.com/Abdelmalek2030/docker-prune-daemon.git](https://github.com/Abdelmalek2030/docker-prune-daemon.git)
cd docker-prune-daemon
go build -o docker-prune-daemon main.go
./docker-prune-daemon --interval=1h --threshold=85%

