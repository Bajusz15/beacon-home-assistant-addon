# Beacon Home Assistant Add-on

Lightweight monitoring, alerting, and secure remote access agent for Home Assistant. Optional [BeaconInfra](https://beaconinfra.dev) cloud for multi-device dashboards, metrics, and tunneling.

## Features

- **Local dashboard** embedded in the HA sidebar via Ingress
- **Health check monitoring** — HTTP, port, and command checks (HA health check pre-configured)
- **System metrics** — CPU, memory, disk, load average
- **Alerts** — Discord, Slack, webhooks
- **BeaconInfra cloud** — multi-device dashboard and secure remote tunnels (optional, requires API key)
- **Fully offline mode** — no API key means zero cloud connectivity or telemetry

## Installation

### BeaconInfra guided setup

If you are connecting Home Assistant to BeaconInfra, open **HA Setup** in the
BeaconInfra dashboard first. It creates the API key, gives you the repository
URL, and watches for the first heartbeat after you start the add-on.

### Manual setup

1. In Home Assistant, go to **Settings** > **Add-ons** > **Add-on Store**
2. Click **...** (top right) > **Repositories**
3. Add this repository URL:
   ```
   https://github.com/Bajusz15/beacon-home-assistant-addon
   ```
4. Find **Beacon** in the store and click **Install**
5. Configure your options and click **Start**

For cloud mode, paste the full BeaconInfra API key into `api_key`. To expose
Home Assistant remotely through BeaconInfra, enable `tunnel_home_assistant`.

## Configuration

| Option | Default | Description |
|---|---|---|
| `device_name` | _(hostname)_ | Friendly name for this device |
| `api_key` | _(empty)_ | BeaconInfra API key for cloud features |
| `heartbeat_interval` | `30` | Seconds between cloud heartbeats (10-300) |
| `metrics_port` | `9100` | Local dashboard and metrics port |

See [DOCS.md](beacon/DOCS.md) for full documentation.

## Supported Architectures

- `aarch64` (Raspberry Pi 4/5)
- `armv7` (Raspberry Pi 3)
- `amd64` (x86_64)

## Links

- [BeaconInfra Cloud](https://beaconinfra.dev)
- [Beacon Agent Source](https://github.com/Bajusz15/beacon)
