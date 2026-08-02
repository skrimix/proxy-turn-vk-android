#!/bin/sh
set -efu

if [ "$#" -gt 0 ]; then
    exec /usr/local/bin/wdtt-server "$@"
fi

: "${WDTT_PASSWORD:?WDTT_PASSWORD must be set}"

validate_port() {
    name="$1"
    value="$2"
    case "$value" in
        ''|*[!0-9]*)
            echo "$name must be a number from 1 to 65535; got: $value" >&2
            exit 1
            ;;
    esac
    if [ "$value" -lt 1 ] || [ "$value" -gt 65535 ]; then
        echo "$name must be in the range 1..65535; got: $value" >&2
        exit 1
    fi
}

dtls_port="${WDTT_DTLS_PORT:-${WDTT_PUBLIC_PORT:-56000}}"
wg_port="${WDTT_WG_PORT:-56001}"
raw_port="${WDTT_RAW_PORT:-56003}"
direct_port="${WDTT_DIRECT_PORT:-}"

validate_port WDTT_DTLS_PORT "$dtls_port"
validate_port WDTT_WG_PORT "$wg_port"
[ -z "$raw_port" ] || validate_port WDTT_RAW_PORT "$raw_port"
[ -z "$direct_port" ] || validate_port WDTT_DIRECT_PORT "$direct_port"

set -- \
    -listen "${WDTT_LISTEN:-0.0.0.0:$dtls_port}" \
    -wg-port "$wg_port" \
    -config-dir "${WDTT_CONFIG_DIR:-/etc/wdtt}" \
    -password "$WDTT_PASSWORD" \
    -dns "${WDTT_DNS:-1.1.1.1,1.0.0.1}"

if [ -n "$direct_port" ]; then
    set -- "$@" -listen-direct "0.0.0.0:$direct_port"
fi

if [ -n "$raw_port" ]; then
    set -- "$@" -listen-raw "0.0.0.0:$raw_port"
fi

if [ -n "${WDTT_ADMIN_ID:-}" ]; then
    set -- "$@" -admin "$WDTT_ADMIN_ID"
fi

if [ -n "${WDTT_BOT_TOKEN:-}" ]; then
    set -- "$@" -bot-token "$WDTT_BOT_TOKEN"
fi

if [ -n "${WDTT_ARGS:-}" ]; then
    # Match deploy.sh/systemd semantics: optional extra arguments are split on whitespace.
    # shellcheck disable=SC2086
    set -- "$@" $WDTT_ARGS
fi

exec /usr/local/bin/wdtt-server "$@"
