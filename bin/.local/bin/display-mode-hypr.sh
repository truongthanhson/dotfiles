#!/usr/bin/env bash
# Safe, serialized Hyprland output switching for local work and Sunshine.
set -Eeuo pipefail

readonly REAL_OUTPUT="DP-1"
readonly STREAM_OUTPUT="HDMI-A-1"
readonly REAL_WIDTH=2560 REAL_HEIGHT=1440 REAL_REFRESH=240
readonly STREAM_WIDTH=1920 STREAM_HEIGHT=1080 STREAM_REFRESH=60
readonly REAL_RULE="${REAL_OUTPUT},${REAL_WIDTH}x${REAL_HEIGHT}@${REAL_REFRESH},0x0,1"
readonly STREAM_RULE="${STREAM_OUTPUT},${STREAM_WIDTH}x${STREAM_HEIGHT}@${STREAM_REFRESH},0x0,1"
readonly POLL_ATTEMPTS=50
readonly POLL_INTERVAL=0.1

quiet=0
mode=""
for argument in "$@"; do
    case "$argument" in
        --quiet) quiet=1 ;;
        work|stream|status)
            [[ -z "$mode" ]] || { printf 'Only one mode may be specified.\n' >&2; exit 2; }
            mode="$argument"
            ;;
        *) printf 'Usage: %s [--quiet] {work|stream|status}\n' "$0" >&2; exit 2 ;;
    esac
done
[[ -n "$mode" ]] || { printf 'Usage: %s [--quiet] {work|stream|status}\n' "$0" >&2; exit 2; }

for command_name in hyprctl jq flock; do
    command -v "$command_name" >/dev/null 2>&1 || {
        printf 'Required command not found: %s\n' "$command_name" >&2
        exit 1
    }
done
[[ "$REAL_OUTPUT" =~ ^[A-Za-z0-9_.:-]+$ && "$STREAM_OUTPUT" =~ ^[A-Za-z0-9_.:-]+$ ]] || {
    printf 'Refusing invalid fixed output name.\n' >&2
    exit 1
}

runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
[[ -d "$runtime_dir" ]] || { printf 'Runtime directory unavailable: %s\n' "$runtime_dir" >&2; exit 1; }
exec 9>"${runtime_dir}/snow-display-mode.lock"
flock -w 10 9 || { printf 'Another display transition did not finish within 10 seconds.\n' >&2; exit 1; }

monitors_json() {
    hyprctl -j monitors
}

monitor_active() {
    local output=$1 snapshot
    snapshot=$(monitors_json)
    jq -e --arg output "$output" '.[] | select(.name == $output)' <<<"$snapshot" >/dev/null
}

monitor_matches() {
    local output=$1 width=$2 height=$3 refresh=$4 snapshot
    snapshot=$(monitors_json)
    jq -e --arg output "$output" --argjson width "$width" --argjson height "$height" \
        --argjson refresh "$refresh" '
        .[] | select(
            .name == $output and
            .width == $width and
            .height == $height and
            ((.refreshRate - $refresh) | fabs) < 0.6
        )' <<<"$snapshot" >/dev/null
}

active_count() {
    local snapshot
    snapshot=$(monitors_json)
    jq 'length' <<<"$snapshot"
}

wait_for_match() {
    local output=$1 width=$2 height=$3 refresh=$4
    local attempt
    for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
        if monitor_matches "$output" "$width" "$height" "$refresh"; then
            return 0
        fi
        sleep "$POLL_INTERVAL"
    done
    printf 'Timed out waiting for %s at %sx%s@%s.\n' "$output" "$width" "$height" "$refresh" >&2
    return 1
}

wait_for_absent() {
    local output=$1 attempt
    for ((attempt = 0; attempt < POLL_ATTEMPTS; attempt++)); do
        if ! monitor_active "$output"; then
            return 0
        fi
        sleep "$POLL_INTERVAL"
    done
    printf 'Timed out waiting for %s to become inactive.\n' "$output" >&2
    return 1
}

apply_monitor_rule() {
    local rule=$1 response
    if ! response=$(hyprctl --quiet keyword monitor "$rule" 2>&1); then
        printf 'Hyprland rejected monitor rule %s: %s\n' "$rule" "$response" >&2
        return 1
    fi
}

ensure_enabled() {
    local output=$1 width=$2 height=$3 refresh=$4 rule=$5
    if monitor_matches "$output" "$width" "$height" "$refresh"; then
        return 0
    fi
    apply_monitor_rule "$rule"
    wait_for_match "$output" "$width" "$height" "$refresh"
}

ensure_disabled() {
    local output=$1
    if ! monitor_active "$output"; then
        return 0
    fi
    apply_monitor_rule "${output},disable"
    wait_for_absent "$output"
}

require_active_output() {
    local count
    count=$(active_count)
    if ((count < 1)); then
        printf 'Safety check failed: Hyprland reports no active outputs.\n' >&2
        return 1
    fi
}

notify_success() {
    ((quiet)) && return 0
    command -v notify-send >/dev/null 2>&1 || return 0
    notify-send "$1" "$2" 2>/dev/null || true
}

restore_real_best_effort() {
    # Never disable the dummy here: rollback first guarantees a local output.
    set +e
    apply_monitor_rule "$REAL_RULE"
    wait_for_match "$REAL_OUTPUT" "$REAL_WIDTH" "$REAL_HEIGHT" "$REAL_REFRESH"
    set -e
}

stream_error() {
    local rc=$?
    trap - ERR
    printf 'Stream transition failed; restoring %s before returning.\n' "$REAL_OUTPUT" >&2
    restore_real_best_effort
    exit "$rc"
}

run_work() {
    # The recovery path always proves the real monitor before touching HDMI.
    ensure_enabled "$REAL_OUTPUT" "$REAL_WIDTH" "$REAL_HEIGHT" "$REAL_REFRESH" "$REAL_RULE"
    require_active_output
    ensure_disabled "$STREAM_OUTPUT"
    wait_for_match "$REAL_OUTPUT" "$REAL_WIDTH" "$REAL_HEIGHT" "$REAL_REFRESH"
    require_active_output
    notify_success "Work mode" "2560x1440 @ 240Hz on ${REAL_OUTPUT}"
}

run_stream() {
    trap stream_error ERR
    # Enable and prove the dummy before removing the only local display.
    ensure_enabled "$STREAM_OUTPUT" "$STREAM_WIDTH" "$STREAM_HEIGHT" "$STREAM_REFRESH" "$STREAM_RULE"
    require_active_output
    ensure_disabled "$REAL_OUTPUT"
    wait_for_match "$STREAM_OUTPUT" "$STREAM_WIDTH" "$STREAM_HEIGHT" "$STREAM_REFRESH"
    require_active_output
    trap - ERR
    notify_success "Stream mode" "1920x1080 @ 60Hz on ${STREAM_OUTPUT}; ${REAL_OUTPUT} off"
}

print_status() {
    monitors_json | jq -r '.[] | "\(.name) \(.width)x\(.height)@\(.refreshRate)Hz position=\(.x)x\(.y) reserved=\(.reserved)"'
}

case "$mode" in
    work) run_work ;;
    stream) run_stream ;;
    status) print_status ;;
esac
