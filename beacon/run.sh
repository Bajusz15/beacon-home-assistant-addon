#!/command/with-contenv bashio

# ── Read options ────────────────────────────────────────────────────────────
DEVICE_NAME=$(bashio::config 'device_name')
API_KEY=$(bashio::config 'api_key')
HEARTBEAT_INTERVAL=$(bashio::config 'heartbeat_interval')
METRICS_PORT=$(bashio::config 'metrics_port')

# Fallback defaults
DEVICE_NAME=${DEVICE_NAME:-$(hostname)}
API_KEY=${API_KEY:-""}
HEARTBEAT_INTERVAL=${HEARTBEAT_INTERVAL:-30}
METRICS_PORT=${METRICS_PORT:-9100}

# ── Beacon home directory ────────────────────────────────────────────────────
# /data is the persistent volume for this add-on.
# BEACON_HOME is used directly as the base dir by beacon (not $BEACON_HOME/.beacon).
# HOME must also be set — beacon uses os.UserHomeDir() as a fallback in some code paths.
export HOME="/data"
export BEACON_HOME="/data/beacon"
mkdir -p "${BEACON_HOME}/config/projects/home-assistant"
mkdir -p "${BEACON_HOME}/state"
mkdir -p "${BEACON_HOME}/logs"
mkdir -p "${BEACON_HOME}/templates"

# ── Write Beacon config ──────────────────────────────────────────────────────
cat > "${BEACON_HOME}/config.yaml" << EOF
device_name: "${DEVICE_NAME}"
heartbeat_interval: ${HEARTBEAT_INTERVAL}
metrics_port: ${METRICS_PORT}
metrics_listen_addr: "0.0.0.0"
cloud_reporting_enabled: $([ -n "${API_KEY}" ] && echo "true" || echo "false")
$([ -n "${API_KEY}" ] && echo "api_key: \"${API_KEY}\"" || echo "# api_key not set — running offline")

system_metrics:
  enabled: true
  interval: "60s"
  cpu: true
  memory: true
  disk: true
  load_average: true
  disk_path: "/"

projects:
  - id: "home-assistant"
    config_path: "${BEACON_HOME}/config/projects/home-assistant/monitor.yml"
EOF

# ── Write default HA health check project ───────────────────────────────────
# Only write if not already customized by user
if [ ! -f "${BEACON_HOME}/config/projects/home-assistant/monitor.yml" ]; then
  cat > "${BEACON_HOME}/config/projects/home-assistant/monitor.yml" << EOF
checks:
  - name: "ha_http"
    type: http
    url: "http://homeassistant:8123/manifest.json"
    interval: 30s
    timeout: 10s
EOF
fi

# ── Start Beacon master ──────────────────────────────────────────────────────
bashio::log.info "Starting Beacon master (device: ${DEVICE_NAME}, cloud: $([ -n "${API_KEY}" ] && echo "enabled" || echo "offline"))"

exec beacon master
