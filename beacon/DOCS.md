# Beacon for Home Assistant

## What is Beacon?

Beacon is a lightweight monitoring, alerting, and secure remote access agent. It runs as a background service that:

- **Monitors** services via HTTP, port, and command checks
- **Alerts** you via Discord, Slack, or webhooks when something goes down
- **Reports** device health (CPU, memory, disk) to a local dashboard
- **Connects** to [BeaconInfra](https://beaconinfra.dev) cloud for multi-device dashboards and secure remote tunnels (optional)

Without an API key, Beacon runs fully offline with zero cloud connectivity or telemetry.

## Installation

1. In Home Assistant, go to **Settings** > **Add-ons** > **Add-on Store**
2. Click the **...** menu (top right) > **Repositories**
3. Add: `https://github.com/Bajusz15/beacon-home-assistant-addon`
4. Find **Beacon** in the store and click **Install**
5. Configure options (see below), then click **Start**

## Configuration Options

| Option | Type | Default | Description |
|---|---|---|---|
| `device_name` | string | _(hostname)_ | Friendly name for this device in dashboards |
| `api_key` | password | _(empty)_ | BeaconInfra API key (`usr_...`). Leave empty for offline mode |
| `heartbeat_interval` | integer | `30` | Seconds between cloud heartbeats (10-300). Only used when API key is set |
| `metrics_port` | port | `9100` | Port for the local dashboard and metrics API |

## Accessing the Dashboard

After starting the add-on, click **Open Web UI** in the add-on info page (or use the sidebar entry). Beacon's local dashboard shows:

- Device health (CPU, memory, disk, load)
- Project status and check results
- Tunnel status (if configured)

The dashboard is also available as a Prometheus metrics endpoint at `/metrics` for integration with Grafana or other tools.

## Monitoring Projects

Beacon comes pre-configured with a Home Assistant health check that pings `http://homeassistant:8123/api/` every 30 seconds.

### Adding Custom Projects

1. Install the **File Editor** or **SSH** add-on
2. Navigate to `/data/beacon/config/projects/`
3. Create a new directory for your project (e.g., `my-service/`)
4. Create a `monitor.yml` file inside it:

```yaml
checks:
  - name: "my_service_http"
    type: http
    url: "http://192.168.1.100:8080/health"
    interval: 60s
    timeout: 10s

  - name: "my_service_port"
    type: port
    host: "192.168.1.100"
    port: 5432
    interval: 30s
```

5. Add the project to Beacon's config at `/data/beacon/config.yaml` under the `projects` list:

```yaml
projects:
  - id: "home-assistant"
    config_path: "/data/beacon/config/projects/home-assistant/monitor.yml"
  - id: "my-service"
    config_path: "/data/beacon/config/projects/my-service/monitor.yml"
```

6. Restart the add-on to pick up the new project.

### Check Types

- **http**: Send HTTP requests and check for expected status codes
- **port**: Check if a TCP port is open
- **command**: Run a shell command and check exit code

## Alerts

Beacon supports alerting via Discord, Slack, and generic webhooks. Alert configuration is per-project in the project's config directory.

Create an `alerts.yml` file alongside `monitor.yml`:

```yaml
alert_channels:
  webhook:
    url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
    method: POST
    content_type: application/json
    template: |
      {"text": "{{.Title}}: {{.Message}}"}

alert_routing:
  - severity: "critical"
    channels: ["webhook"]
```

See the [Beacon documentation](https://beaconinfra.dev) for the full alert configuration reference.

## Tunnel / Remote Access

With a BeaconInfra API key, Beacon can establish secure reverse tunnels to your Home Assistant instance. This provides remote access without exposing ports or configuring a VPN.

Visit [beaconinfra.dev](https://beaconinfra.dev) to create an account and get your API key.

## Offline Mode

If no `api_key` is configured, Beacon runs in fully offline mode:

- No cloud connectivity or telemetry
- Local dashboard and monitoring still fully functional
- Alerts (webhooks, etc.) still work — they are outbound HTTP only
- No tunnel or remote access features

## Data Persistence

All Beacon data is stored under `/data/beacon/` which persists across add-on restarts and updates:

- `config.yaml` — main Beacon configuration (regenerated on each start from HA options)
- `config/projects/` — project monitoring configs (preserved across restarts)
- `state/` — check state, log cursors
- `logs/` — project-specific logs

The default Home Assistant health check config is only written if it doesn't already exist, so your customizations are preserved.
