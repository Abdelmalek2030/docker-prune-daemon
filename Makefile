BINARY_NAME=docker-prune-daemon
VERSION=1.0.0
LDFLAGS="-s -w -X main.Version=$(VERSION)"

.PHONY: all build test clean lint check bench install uninstall

all: clean check lint test build

build:
	@echo "==> Compiling static binary (CGO_ENABLED=0)..."
	CGO_ENABLED=0 go build -trimpath -ldflags=$(LDFLAGS) -o $(BINARY_NAME) .

test:
	@echo "==> Running behavioral unit tests with race detector..."
	go test -v -race -cover ./...

check:
	@echo "==> Verifying gofmt code formatting compliance..."
	@test -z "$$(gofmt -s -l .)" || (echo "Error: Unformatted Go files detected" && exit 1)

lint:
	@echo "==> Running static analysis via go vet..."
	go vet ./...

bench:
	@echo "==> Executing syscall.Statfs performance benchmarks..."
	go test -bench=. -benchmem ./...

clean:
	@echo "==> Cleaning build artifacts..."
	rm -f $(BINARY_NAME)
	rm -rf dist/

install: build
	@echo "==> Installing binary, systemd unit, and man(8) page..."
	install -m 0755 $(BINARY_NAME) /usr/local/bin/$(BINARY_NAME)
	install -m 0644 docker-prune-daemon.service /etc/systemd/system/docker-prune-daemon.service
	install -m 0644 man/docker-prune-daemon.8 /usr/local/share/man/man8/docker-prune-daemon.8
	systemctl daemon-reload

uninstall:
	@echo "==> Uninstalling system components..."
	rm -f /usr/local/bin/$(BINARY_NAME)
	rm -f /etc/systemd/system/docker-prune-daemon.service
	rm -f /usr/local/share/man/man8/docker-prune-daemon.8
	systemctl daemon-reload
