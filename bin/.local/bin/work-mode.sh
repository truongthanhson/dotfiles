#!/usr/bin/env bash
# Local recovery entry point: real 1440p240 display on, stream dummy off.
set -euo pipefail
exec /home/snow/.local/bin/display-mode-hypr.sh work "$@"
