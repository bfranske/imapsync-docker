#!/bin/sh
set -eu

if [ "$#" -gt 0 ]; then
    case "$1" in
        -*) exec /usr/local/bin/imapsync "$@" ;;
        *) exec "$@" ;;
    esac
fi

if [ -z "${IMAPSYNC_ARGS_FILE:-}" ]; then
    printf '%s\n' 'IMAPSYNC_ARGS_FILE is required when no command is supplied.' >&2
    exit 64
fi

if [ ! -r "$IMAPSYNC_ARGS_FILE" ]; then
    printf '%s\n' "IMAPSYNC_ARGS_FILE is not readable: $IMAPSYNC_ARGS_FILE" >&2
    exit 64
fi

set --
while IFS= read -r argument || [ -n "$argument" ]; do
    case "$argument" in
        ''|'#'*) continue ;;
    esac
    set -- "$@" "$argument"
done < "$IMAPSYNC_ARGS_FILE"

exec /usr/local/bin/imapsync "$@"