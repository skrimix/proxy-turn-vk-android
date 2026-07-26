# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM golang:1.25-bookworm AS build

ARG TARGETOS
ARG TARGETARCH

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY server.go ./
RUN CGO_ENABLED=0 GOOS="$TARGETOS" GOARCH="$TARGETARCH" \
    go build -trimpath -ldflags="-s -w" -o /out/wdtt-server .

FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        bash \
        ca-certificates \
        iproute2 \
        iptables \
        procps \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /out/wdtt-server /usr/local/bin/wdtt-server
COPY --chmod=0755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN mkdir -p /etc/wdtt

EXPOSE 56000/tcp 56000/udp

STOPSIGNAL SIGTERM

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD ["bash", "-c", ": >/dev/tcp/127.0.0.1/56000"]

ENTRYPOINT ["/bin/sh", "/usr/local/bin/docker-entrypoint.sh"]
