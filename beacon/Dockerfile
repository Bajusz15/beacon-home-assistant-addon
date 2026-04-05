ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
ARG BUILD_ARCH=amd64

# hadolint ignore=DL3006
FROM golang:1.26-alpine AS builder

ARG BUILD_ARCH

WORKDIR /build

RUN apk add --no-cache git ca-certificates

# Clone beacon at the pinned release tag
RUN git clone --depth 1 --branch v0.4.1-master-cloud-login \
    https://github.com/Bajusz15/beacon.git .

# Map HA's BUILD_ARCH to Go's GOARCH/GOARM and build
RUN case "${BUILD_ARCH}" in \
      aarch64) GOARCH=arm64; GOARM= ;; \
      armv7)   GOARCH=arm;   GOARM=7 ;; \
      amd64)   GOARCH=amd64; GOARM= ;; \
      *)       echo "Unsupported BUILD_ARCH: ${BUILD_ARCH}"; exit 1 ;; \
    esac && \
    CGO_ENABLED=0 GOOS=linux GOARCH="${GOARCH}" GOARM="${GOARM}" \
    go build \
      -ldflags="-s -w \
        -X beacon/internal/version.Version=v0.4.1 \
        -X beacon/internal/cloud.DefaultBeaconInfraAPIURL=https://beaconinfra.dev/api" \
      -o /beacon ./cmd/beacon

# hadolint ignore=DL3006
FROM ${BUILD_FROM}

LABEL \
  io.hass.version="0.4.3" \
  io.hass.type="addon" \
  io.hass.arch="aarch64|amd64"

# Install minimal runtime deps
RUN apk add --no-cache ca-certificates tzdata jq bash

COPY --from=builder /beacon /usr/local/bin/beacon
COPY run.sh /run.sh
COPY rootfs /
RUN chmod +x /run.sh /etc/s6-overlay/s6-rc.d/beacon/run
