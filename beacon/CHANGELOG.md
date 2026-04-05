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
