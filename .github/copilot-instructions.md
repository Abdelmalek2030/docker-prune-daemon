# Architectural Directives for AI Assistants

This repository adheres to strict Reference-Grade engineering standards. Any code contributions or AI-generated suggestions must comply with the following invariants:

1. **Zero External Dependencies**: Never introduce third-party libraries, packages, or runtime dependencies. Rely exclusively on base system interpreters (`/bin/sh`, POSIX standard utilities) or Go/Node.js standard libraries.
2. **XDG Base Directory Compliance**: All configuration, data, state, and cache paths must strictly respect `$XDG_*_HOME` environment variables with predictable fallback hierarchies.
3. **Atomic Safety & Signals**: Concurrency mechanisms must use atomic kernel primitives (e.g., POSIX `mkdir(2)` mutexes) paired with deterministic signal traps (`EXIT`, `INT`, `TERM`, `HUP`).
4. **Static Analysis Purity**: Shell scripts must pass aggressive `shellcheck` diagnostics without warnings. Go code must compile cleanly with `CGO_ENABLED=0` and pass race-detector test suites.
