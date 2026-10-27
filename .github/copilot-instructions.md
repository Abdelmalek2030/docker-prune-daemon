# Architectural Directives for AI Assistants

1. **Zero External Dependencies**: Never introduce third-party Go modules into `go.mod`. Rely strictly on the Go standard library.
2. **Static Compilation**: All builds must remain compatible with `CGO_ENABLED=0`.
3. **Concurrency & Signals**: Use `context.Context` and `os/signal` for deterministic lifecycle management and race-free execution (`go test -race`).
4. **Systemd Sandboxing**: Preserve strict Cgroups v2 and kernel isolation directives inside `docker-prune-daemon.service`.
