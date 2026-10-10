#!/bin/sh
set -eu

if [ "$#" -gt 0 ]; then
    case "$1" in
        -*) exec /usr/local/bin/imapsync "$@" ;;
        *) exec "$@" ;;
    esac
fi

value_for() {
    case "$1" in
        IMAPSYNC_HOST1) printf '%s' "${IMAPSYNC_HOST1:-}" ;;
        IMAPSYNC_USER1) printf '%s' "${IMAPSYNC_USER1:-}" ;;
        IMAPSYNC_HOST2) printf '%s' "${IMAPSYNC_HOST2:-}" ;;
        IMAPSYNC_USER2) printf '%s' "${IMAPSYNC_USER2:-}" ;;
        IMAPSYNC_PORT1) printf '%s' "${IMAPSYNC_PORT1:-}" ;;
        IMAPSYNC_PORT2) printf '%s' "${IMAPSYNC_PORT2:-}" ;;
        IMAPSYNC_TIMEOUT1) printf '%s' "${IMAPSYNC_TIMEOUT1:-}" ;;
        IMAPSYNC_TIMEOUT2) printf '%s' "${IMAPSYNC_TIMEOUT2:-}" ;;
        IMAPSYNC_LOGDIR) printf '%s' "${IMAPSYNC_LOGDIR:-}" ;;
        IMAPSYNC_MAXAGE) printf '%s' "${IMAPSYNC_MAXAGE:-}" ;;
        IMAPSYNC_MAX_BYTES_PER_SECOND) printf '%s' "${IMAPSYNC_MAX_BYTES_PER_SECOND:-}" ;;
        IMAPSYNC_MAX_MESSAGES_PER_SECOND) printf '%s' "${IMAPSYNC_MAX_MESSAGES_PER_SECOND:-}" ;;
        IMAPSYNC_EXCLUDE) printf '%s' "${IMAPSYNC_EXCLUDE:-}" ;;
    esac
}

require_value() {
    variable_name=$1
    variable_value=$(value_for "$variable_name")

    if [ -z "$variable_value" ]; then
        printf '%s\n' "Missing required environment variable: $variable_name" >&2
        exit 64
    fi
}

require_value IMAPSYNC_HOST1
require_value IMAPSYNC_USER1
require_value IMAPSYNC_HOST2
require_value IMAPSYNC_USER2

set -- /usr/local/bin/imapsync \
    --host1 "$IMAPSYNC_HOST1" \
    --user1 "$IMAPSYNC_USER1" \
    --host2 "$IMAPSYNC_HOST2" \
    --user2 "$IMAPSYNC_USER2"

if [ "${IMAPSYNC_SSL1:-true}" = "true" ]; then
    set -- "$@" --ssl1
fi

if [ "${IMAPSYNC_SSL2:-true}" = "true" ]; then
    set -- "$@" --ssl2
fi

for option in \
    'IMAPSYNC_PORT1 --port1' \
    'IMAPSYNC_PORT2 --port2' \
    'IMAPSYNC_TIMEOUT1 --timeout1' \
    'IMAPSYNC_TIMEOUT2 --timeout2' \
    'IMAPSYNC_LOGDIR --logdir' \
    'IMAPSYNC_MAXAGE --maxage' \
    'IMAPSYNC_MAX_BYTES_PER_SECOND --maxbytespersecond' \
    'IMAPSYNC_MAX_MESSAGES_PER_SECOND --maxmessagespersecond' \
    'IMAPSYNC_EXCLUDE --exclude'; do
    variable_name=${option%% *}
    option_name=${option#* }
    variable_value=$(value_for "$variable_name")

    if [ -n "$variable_value" ]; then
        set -- "$@" "$option_name" "$variable_value"
    fi
done

if [ "${IMAPSYNC_DELETE2:-false}" = "true" ]; then
    set -- "$@" --delete2
fi

if [ "${IMAPSYNC_NOFOLDERSIZES:-false}" = "true" ]; then
    set -- "$@" --nofoldersizes
fi

exec "$@"