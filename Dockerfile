# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM debian:bookworm-slim AS extract

ARG APK_URL=https://github.com/SpaceNeuroX/proxy-turn-vk-android/releases/download/v1.4.0-beta/app-arm64-v8a-release.apk
ARG APK_SHA256=fe8feffbb982007b7beed47f5581aee3b1e9b0a7133cd33339458c8e63625f5f

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl --fail --location --retry 3 --output /tmp/app.apk "$APK_URL" \
    && echo "$APK_SHA256  /tmp/app.apk" | sha256sum --check --strict \
    && mkdir -p /out \
    && unzip -p /tmp/app.apk assets/server > /out/wdtt-server \
    && chmod 0755 /out/wdtt-server \
    && test "$(od -An -t x1 -j 4 -N 1 /out/wdtt-server | tr -d ' ')" = "02" \
    && test "$(od -An -t x1 -j 18 -N 2 /out/wdtt-server | tr -d ' ')" = "3e00"

FROM debian:bookworm-slim

ARG TARGETARCH

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        bash \
        ca-certificates \
        iproute2 \
        iptables \
        procps \
    && rm -rf /var/lib/apt/lists/* \
    && if [ "$TARGETARCH" != "amd64" ]; then \
        echo "The APK only bundles an x86-64 server; build with --platform linux/amd64." >&2; \
        exit 1; \
    fi

COPY --from=extract /out/wdtt-server /usr/local/bin/wdtt-server
COPY --chmod=0755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN mkdir -p /etc/wdtt

EXPOSE 56000/tcp 56000/udp 56001/udp 56003/udp

STOPSIGNAL SIGTERM

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD ["bash", "-c", ": >/dev/tcp/127.0.0.1/${WDTT_DTLS_PORT:-56000}"]

ENTRYPOINT ["/bin/sh", "/usr/local/bin/docker-entrypoint.sh"]
