# Security Threat Model & Isolation Guarantees

This document outlines the security posture and attack surface mitigations of `docker-prune-daemon`.

---

## 1. Attack Surface & Trust Boundaries

| Vector | Risk | Mitigation Strategy |
| :--- | :--- | :--- |
| **Third-Party Supply Chain** | Malicious transitive dependencies | **Zero External Dependencies**: Compiled strictly with Go standard library modules (`CGO_ENABLED=0`). |
| **Command Injection** | Arbitrary shell execution via `--until` flag | Uses `exec.CommandContext` argument arrays directly without invoking `/bin/sh -c`. |
| **Resource Exhaustion (DoS)** | Runaway daemon memory or CPU spikes | Enforced via `systemd` Cgroups v2 (`MemoryMax=32M`, `CPUQuota=10%`). |
| **Volume Data Loss** | Accidental deletion of persistent databases | Never passes `--volumes` to `docker system prune`; restricts scope to dangling/stopped artifacts older than `until`. |
