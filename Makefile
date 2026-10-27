PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
SYSTEMD_DIR ?= /etc/systemd/system
MANDIR ?= $(PREFIX)/share/man/man8
BINARY := docker-prune-daemon

.PHONY: all help build check lint test bench install uninstall clean

all: build

help:
	@printf "docker-prune-daemon build & deployment interface\n\n"
	@printf "Targets:\n"
	@printf "  make build      Compile stripped, static Go binary\n"
	@printf "  make check      Verify Go formatting and module tidy state\n"
	@printf "  make lint       Run go vet static analysis across all packages\n"
	@printf "  make test       Execute unit tests with race detector enabled\n"
	@printf "  make bench      Run statfs syscall performance benchmarks\n"
	@printf "  make install    Install binary, systemd unit, and man(8) page\n"
	@printf "  make uninstall  Remove installed binary, unit file, and man page\n"
	@printf "  make clean      Remove compiled artifacts\n"

build:
	CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o $(BINARY) .

check:
	@test -z "$$(gofmt -l .)" || (printf "Error: gofmt required on:\n$$(gofmt -l .)\n" && exit 1)

lint: check
	go vet ./...

test:
	go test -v -race ./...

bench:
	go test -bench=. -benchmem ./...

install: build
	install -d "$(DESTDIR)$(BINDIR)"
	install -m 0755 $(BINARY) "$(DESTDIR)$(BINDIR)/$(BINARY)"
	install -d "$(DESTDIR)$(SYSTEMD_DIR)"
	install -m 0644 docker-prune-daemon.service "$(DESTDIR)$(SYSTEMD_DIR)/docker-prune-daemon.service"
	@if [ -f man/docker-prune-daemon.8 ]; then \
		install -d "$(DESTDIR)$(MANDIR)"; \
		install -m 0644 man/docker-prune-daemon.8 "$(DESTDIR)$(MANDIR)/docker-prune-daemon.8"; \
	fi

uninstall:
	rm -f "$(DESTDIR)$(BINDIR)/$(BINARY)"
	rm -f "$(DESTDIR)$(SYSTEMD_DIR)/docker-prune-daemon.service"
	rm -f "$(DESTDIR)$(MANDIR)/docker-prune-daemon.8"

clean:
	rm -f $(BINARY)
