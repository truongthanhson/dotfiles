#!/usr/bin/env bash
# Sunshine entry point: prove the 1080p60 dummy before switching the real panel off.
set -euo pipefail
exec /home/snow/.local/bin/display-mode-hypr.sh stream "$@"
