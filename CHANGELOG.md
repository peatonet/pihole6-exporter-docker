# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [2026-03-30]

### Fixed
- Re-auth patch now uses `sed` instead of a Python heredoc, which failed silently on Alpine's `sh`. The exporter now correctly re-authenticates against Pi-hole when the session expires (default validity: 1800s), preventing `_1m` metrics from going empty after 30 minutes of uptime.
- Fixed timezone bug in `_1m` metrics: `datetime.now().strftime("%s")` treated local time as UTC, causing the exporter to query a 1-minute window 2 hours in the future (UTC+2/Europe/Madrid) and always get empty results. Replaced with `time.time()` which always returns the correct UTC Unix timestamp.

## [2025-09-06]

### Changed
- Reordered `docker-compose.yaml` service definitions for clarity.

## [2025-09-05]

### Changed
- Added `latest` multiarch tag to Docker Hub alongside `amd64` and `arm64`.

## [2025-09-04]

### Added
- Initial `Dockerfile` based on [bazmonk/pihole6_exporter](https://github.com/bazmonk/pihole6_exporter).
  - Patches the upstream script to support `PIHOLE_SCHEME` and `PIHOLE_PORT` environment variables (instead of hardcoded `https`/`443`), allowing HTTP deployments.
  - Exposes Prometheus metrics on port `9666`.
- `README.md` with usage instructions.
- `LICENSE` (MIT).
