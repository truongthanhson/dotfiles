#!/usr/bin/env bash
# Sunshine preparation coordinator: display transition is mandatory; tuning is best effort.
set -Eeuo pipefail

readonly DISPLAY_MODE=/home/snow/.local/bin/display-mode-hypr.sh
readonly PERF_HELPER=/home/snow/.config/sway-sunshine/perf.sh

action="${1:-}"
case "$action" in
    do)
        if ! "$DISPLAY_MODE" --quiet stream; then
            "$DISPLAY_MODE" --quiet work || true
            exit 1
        fi
        if [[ -x "$PERF_HELPER" ]] && ! "$PERF_HELPER" on; then
            "$DISPLAY_MODE" --quiet work || true
            exit 1
        fi
        ;;
    undo)
        # Recovery must run even if the optional performance helper has trouble.
        perf_rc=0
        [[ ! -x "$PERF_HELPER" ]] || "$PERF_HELPER" off || perf_rc=$?
        work_rc=0
        "$DISPLAY_MODE" --quiet work || work_rc=$?
        ((work_rc == 0)) || exit "$work_rc"
        exit "$perf_rc"
        ;;
    *)
        printf 'Usage: %s {do|undo}\n' "$0" >&2
        exit 2
        ;;
esac
