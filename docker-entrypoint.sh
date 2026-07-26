#!/bin/sh
set -eu

if [ "$#" -gt 0 ]; then
    exec /usr/local/bin/wdtt-server "$@"
fi

: "${WDTT_PASSWORD:?WDTT_PASSWORD must be set}"

set -- \
    -listen "${WDTT_LISTEN:-0.0.0.0:56000}" \
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
