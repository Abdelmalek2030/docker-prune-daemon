# System Architecture & Execution Pipeline

`docker-prune-daemon` is designed around a deterministic, low-overhead event loop utilizing only the Go standard library (`syscall`, `context`, `os/signal`, `os/exec`).

---

## 1. Execution Pipeline

```text
[Timer Ticker / Init]
         │
         ▼
┌──────────────────────────────────────────┐
│ syscall.Statfs(DOCKER_DATA_ROOT or "/")  │
└──────────────────────────────────────────┘
         │
         ▼
  Usage >= Threshold? ──(No)──► [Sleep until next tick]
         │
       (Yes)
         ▼
   Dry-Run Enabled? ────(Yes)─► [Emit audit log & return]
         │
        (No)
         ▼
┌──────────────────────────────────────────┐
│ exec.CommandContext(ctx, "docker", ...)  │
│ system prune --all --force --filter=...  │
└──────────────────────────────────────────┘
