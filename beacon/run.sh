#!/command/with-contenv bashio

set -e

# ── Read options ────────────────────────────────────────────────────────────
DEVICE_NAME=$(bashio::config 'device_name')
API_KEY=$(bashio::config 'api_key')
HEARTBEAT_INTERVAL=$(bashio::config 'heartbeat_interval')
METRICS_PORT=$(bashio::config 'metrics_port')
TUNNEL_HA=$(bashio::config 'tunnel_home_assistant')
LOG_LEVEL=$(bashio::config 'log_level')

# Fallback defaults
DEVICE_NAME=${DEVICE_NAME:-$(hostname)}
API_KEY=${API_KEY:-""}
HEARTBEAT_INTERVAL=${HEARTBEAT_INTERVAL:-30}
METRICS_PORT=${METRICS_PORT:-9100}
TUNNEL_HA=${TUNNEL_HA:-false}
LOG_LEVEL=${LOG_LEVEL:-""}

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

CONFIG_FILE="${BEACON_HOME}/config.yaml"

# ── Seed config.yaml on first start ─────────────────────────────────────────
# This block runs only once. After that, the file is preserved and we just
# overlay Supervisor-managed keys on top — so user edits (tunnels, projects,
# system_metrics tweaks, etc.) survive restarts.
if [ ! -f "${CONFIG_FILE}" ]; then
  bashio::log.info "Seeding ${CONFIG_FILE} (first start)"
  cat > "${CONFIG_FILE}" << EOF
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
fi

# ── Build overlay with Supervisor-managed keys ──────────────────────────────
# Only the keys that originate from HA add-on options are overlaid. Every other
# top-level key in config.yaml (tunnels, projects, system_metrics, ...) is left
# untouched by the merge.
OVERLAY_FILE=$(mktemp)
trap 'rm -f "${OVERLAY_FILE}"' EXIT

{
  echo "device_name: \"${DEVICE_NAME}\""
  echo "heartbeat_interval: ${HEARTBEAT_INTERVAL}"
  echo "metrics_port: ${METRICS_PORT}"
  echo "metrics_listen_addr: \"0.0.0.0\""
  if [ -n "${API_KEY}" ]; then
    echo "cloud_reporting_enabled: true"
    echo "api_key: \"${API_KEY}\""
  fi
  if [ -n "${LOG_LEVEL}" ]; then
    echo "log_level: \"${LOG_LEVEL}\""
  fi
} > "${OVERLAY_FILE}"

# Deep-merge overlay into existing config. Mikefarah yq's `*=` does a deep merge
# where the right-hand side wins on scalars and maps, while keys present only in
# the base (tunnels, projects, ...) are preserved.
yq -i ". *= load(\"${OVERLAY_FILE}\")" "${CONFIG_FILE}"

# ── Optional preset: auto-tunnel to Home Assistant Core ─────────────────────
# When enabled, ensure a tunnels[] entry with id=homeassistant exists, without
# clobbering other user-defined tunnels. When disabled, we do nothing — we do
# NOT remove an existing entry, so toggling off does not destroy state.
if bashio::var.true "${TUNNEL_HA}"; then
  HAS_HA_TUNNEL=$(yq '[.tunnels // [] | .[] | select(.id == "homeassistant")] | length' "${CONFIG_FILE}")
  if [ "${HAS_HA_TUNNEL}" = "0" ]; then
    bashio::log.info "Adding 'homeassistant' tunnel preset to ${CONFIG_FILE}"
    yq -i '.tunnels = ((.tunnels // []) + [{"id":"homeassistant","upstream":{"protocol":"http","host":"homeassistant","port":8123}}])' "${CONFIG_FILE}"
  fi
fi

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
bashio::log.info "Starting Beacon master (device: ${DEVICE_NAME}, cloud: $([ -n "${API_KEY}" ] && echo "enabled" || echo "offline"), tunnel_ha: ${TUNNEL_HA})"

exec beacon master
