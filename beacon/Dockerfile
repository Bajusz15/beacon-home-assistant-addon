ARG BUILD_FROM
FROM golang:1.26-alpine AS builder

WORKDIR /build

# Clone beacon at the pinned release tag
RUN apk add --no-cache git ca-certificates
RUN git clone --depth 1 --branch v0.4.1-master-cloud-login \
    https://github.com/Bajusz15/beacon.git .

# Build for target arch (BUILD_GOARCH/BUILD_GOARM injected by HA build system via build.yaml)
ARG BUILD_GOARCH
ARG BUILD_GOARM
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=${BUILD_GOARCH} \
    GOARM=${BUILD_GOARM}

RUN go build \
    -ldflags="-s -w \
      -X beacon/internal/version.Version=v0.4.1 \
      -X beacon/internal/version.Commit=$(git rev-parse --short HEAD) \
      -X beacon/internal/version.BuildDate=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
      -X beacon/internal/cloud.DefaultBeaconInfraAPIURL=https://beaconinfra.dev/api" \
    -o /beacon ./cmd/beacon

# Runtime stage — use the HA base image
FROM ${BUILD_FROM}

LABEL \
  io.hass.version="0.4.1" \
  io.hass.type="addon" \
  io.hass.arch="aarch64|armv7|amd64"

# Install minimal runtime deps
RUN apk add --no-cache ca-certificates tzdata jq bash

COPY --from=builder /beacon /usr/local/bin/beacon
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
