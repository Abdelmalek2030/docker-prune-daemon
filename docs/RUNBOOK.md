# Operational Runbook & Production Troubleshooting

This runbook details diagnostic procedures and operational recovery steps for production nodes executing `docker-prune-daemon`.

---

## 1. Inspecting Live Daemon Telemetry
To tail real-time journal logs and filter by systemd identifier:
```sh
journalctl -u docker-prune-daemon.service -f --output=cat
