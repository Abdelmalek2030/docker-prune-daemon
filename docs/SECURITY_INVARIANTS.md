# Core Security Invariants & Kernel Threat Boundaries

This document formalizes the unviolatable execution constraints enforced within `docker-prune-daemon`.

---

## 1. Memory Safety & Zero Allocation Loop
- **Invariant I-1**: The core filesystem watermark evaluation loop utilizing `syscall.Statfs` must execute with zero heap allocations (`allocs/op == 0`) to prevent garbage collection jitter under severe disk pressure.
- **Invariant I-2**: CGO is permanently disabled (`CGO_ENABLED=0`) to eliminate dynamic linking vulnerabilities, glibc version skew, and memory corruption vectors.

## 2. Subprocess Execution Guardrails
- **Invariant I-3**: All Docker CLI interactions are invoked strictly via argument arrays (`exec.CommandContext`) without shell interpretation (`/bin/sh -c`), neutralizing arbitrary command injection vectors.
- **Invariant I-4**: Persistent named volumes are structurally excluded from pruning scopes (`--volumes` is never passed), guaranteeing zero risk of user database deletion.

## 3. Kernel Sandbox & Cgroups v2 Isolation
- The systemd service unit enforces hard resource ceilings (`MemoryMax=32M`, `CPUQuota=10%`), ensuring runaway container cleanup loops cannot starve host kernel resources.
