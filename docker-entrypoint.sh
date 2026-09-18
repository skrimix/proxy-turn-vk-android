#!/bin/sh
set -eu

if [ "$#" -gt 0 ]; then
    exec /usr/local/bin/wdtt-server "$@"
fi

: "${WDTT_PASSWORD:?WDTT_PASSWORD must be set}"

raw_port="${WDTT_RAW_PORT:-56003}"
case "$raw_port" in
    *[!0-9]*)
        echo "WDTT_RAW_PORT must be a number from 1 to 65535" >&2
        exit 1
        ;;
esac
if [ "$raw_port" -lt 1 ] || [ "$raw_port" -gt 65535 ]; then
    echo "WDTT_RAW_PORT must be in the range 1..65535" >&2
    exit 1
fi

set -- \
    -listen "${WDTT_LISTEN:-0.0.0.0:56000}" \
    -listen-raw "0.0.0.0:$raw_port" \
    -wg-port "${WDTT_WG_PORT:-56001}" \
    -config-dir "${WDTT_CONFIG_DIR:-/etc/wdtt}" \
    -password "$WDTT_PASSWORD" \
    -dns "${WDTT_DNS:-1.1.1.1,1.0.0.1}"

if [ -n "${WDTT_ADMIN_ID:-}" ]; then
    set -- "$@" -admin "$WDTT_ADMIN_ID"
fi

if [ -n "${WDTT_BOT_TOKEN:-}" ]; then
    set -- "$@" -bot-token "$WDTT_BOT_TOKEN"
fi

exec /usr/local/bin/wdtt-server "$@"
