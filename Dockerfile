# Stage 1: Build static binary
FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /docker-prune-daemon .

# Stage 2: Ultimate zero-bloat runtime scratch container
FROM scratch
COPY --from=builder /docker-prune-daemon /usr/local/bin/docker-prune-daemon
ENTRYPOINT ["/usr/local/bin/docker-prune-daemon"]
