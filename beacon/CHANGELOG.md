## 0.4.3

- Fix `s6-overlay-suexec: can only run as pid 1` crash loop
- Migrate to S6 v3 longrun service pattern (`/command/with-contenv` shebang)
- Run beacon via S6 service instead of Docker CMD

## 0.4.2

- Fix add-on not appearing in HA store (invalid map and build.yaml formats)
- Use standard BUILD_ARCH variable for cross-compilation
- Remove invalid `map: type: data` entry (`/data` is always available)

## 0.4.1

- Initial Home Assistant add-on release
- Beacon master agent with local dashboard via Ingress
- Home Assistant health check pre-configured out of the box
- Optional BeaconInfra cloud dashboard and tunnel
- System metrics collection (CPU, memory, disk, load average)
- Monitoring, alerting (Discord, Slack, webhook)
