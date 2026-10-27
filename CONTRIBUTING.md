# Contributing to docker-prune-daemon

Thank you for your interest in contributing. To preserve our zero-bloat architecture, all pull requests must adhere to the following engineering invariants:

1. **Zero External Dependencies**: `go.mod` must remain free of third-party packages.
2. **Formatting & Static Analysis**: Code must pass `make check` (`gofmt`) and `make lint` (`go vet`).
3. **Race-Free Concurrency**: All changes must pass `make test` (`go test -v -race ./...`).
4. **Conventional Commits**: Commit messages must follow the `<type>(<scope>): <description>` specification.
