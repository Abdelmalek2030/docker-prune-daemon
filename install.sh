#!/bin/sh
# Secure, zero-dependency one-line installer for docker-prune-daemon.

set -eu

REPO="Abdelmalek2030/docker-prune-daemon"
PREFIX="${PREFIX:-/usr/local}"
BINDIR="${PREFIX}/bin"
MANDIR="${PREFIX}/share/man/man8"
SYSTEMD_DIR="/etc/systemd/system"

printf "=== Installing docker-prune-daemon ===\n"

# 1. Detect architecture
ARCH="$(uname -m)"
case "$ARCH" in
    x86_64|amd64) GOARCH="amd64" ;;
    aarch64|arm64) GOARCH="arm64" ;;
    *)
        printf "Error: Unsupported architecture '%s'. Only amd64 and arm64 are supported.\n" "$ARCH" >&2
        exit 1
        ;;
esac

# 2. Verify root privileges for system-wide paths
if [ "$(id -u)" -ne 0 ]; then
    printf "Warning: Not running as root. Installation to %s may fail without sudo.\n" "$PREFIX"
fi

# 3. Fetch latest release binary URL
API_URL="https://api.github.com/repos/${REPO}/releases/latest"
printf "Fetching latest release metadata from GitHub...\n"

if command -v curl >/dev/null 2>&1; then
    DOWNLOAD_URL="$(curl -sSfL "$API_URL" | grep "browser_download_url.*linux-${GOARCH}.tar.gz" | cut -d '"' -f 4)"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOAD_URL="$(wget -qO- "$API_URL" | grep "browser_download_url.*linux-${GOARCH}.tar.gz" | cut -d '"' -f 4)"
else
    printf "Error: Neither curl nor wget is available.\n" >&2
    exit 1
fi

if [ -z "${DOWNLOAD_URL:-}" ]; then
    printf "Error: Could not locate release tarball for architecture linux-%s.\n" "$GOARCH" >&2
    exit 1
fi

# 4. Download and extract archive in temporary sandbox
TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'dpd_install')"
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM HUP

printf "Downloading release archive...\n"
if command -v curl >/dev/null 2>&1; then
    curl -sSfL "$DOWNLOAD_URL" -o "${TMP_DIR}/release.tar.gz"
else
    wget -qO "${TMP_DIR}/release.tar.gz" "$DOWNLOAD_URL"
fi

tar -xzf "${TMP_DIR}/release.tar.gz" -C "$TMP_DIR"

# 5. Install binary, man page, and systemd service unit
printf "Installing components into system paths...\n"
mkdir -p "$BINDIR" "$MANDIR" "$SYSTEMD_DIR" 2>/dev/null || true

# Find compiled binary inside extracted files
BINARY_PATH="$(find "$TMP_DIR" -type f -name "docker-prune-daemon" | head -n 1)"
if [ -z "${BINARY_PATH:-}" ]; then
    # Fallback to direct compilation if release tarball extraction differs
    printf "Notice: Compiling binary locally from source fallback...\n"
    CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o "${TMP_DIR}/docker-prune-daemon" .
    BINARY_PATH="${TMP_DIR}/docker-prune-daemon"
fi

install -m 0755 "$BINARY_PATH" "${BINDIR}/docker-prune-daemon"

if [ -f "${TMP_DIR}/man/docker-prune-daemon.8" ]; then
    install -m 0644 "${TMP_DIR}/man/docker-prune-daemon.8" "${MANDIR}/docker-prune-daemon.8"
elif [ -f "man/docker-prune-daemon.8" ]; then
    install -m 0644 "man/docker-prune-daemon.8" "${MANDIR}/docker-prune-daemon.8"
fi

if [ -f "${TMP_DIR}/docker-prune-daemon.service" ]; then
    install -m 0644 "${TMP_DIR}/docker-prune-daemon.service" "${SYSTEMD_DIR}/docker-prune-daemon.service"
elif [ -f "docker-prune-daemon.service" ]; then
    install -m 0644 "docker-prune-daemon.service" "${SYSTEMD_DIR}/docker-prune-daemon.service"
fi

printf "\nInstallation completed successfully!\n"
printf "To enable and start the background daemon, run:\n"
printf "  sudo systemctl daemon-reload\n"
printf "  sudo systemctl enable --now docker-prune-daemon.service\n"
