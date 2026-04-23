## 0.4.6

- Preserve user edits in `/data/beacon/config.yaml` across restarts: the add-on now deep-merges Supervisor options into the file instead of overwriting it. Manually added `tunnels:` and custom `projects:` entries are no longer wiped.
- New option `tunnel_home_assistant` (default `false`): when enabled, auto-adds a BeaconInfra tunnel entry pointing at `homeassistant:8123` so HA Core can be reached remotely without VPN or port-forwarding. Toggling off does not remove existing entries.
- New option `log_level` (`debug|info|warn|error`, default `info`): overlaid into config on each start.
- Install `yq` in the image for the merge logic.

## 0.4.5

- Fix "Connection lost" in Ingress dashboard: use relative fetch path
- Bump beacon to v0.5.2-tunnel-homeassistant

## 0.4.4

- Fix crash loop: `beacon master` has no `--foreground` flag; run it directly

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
