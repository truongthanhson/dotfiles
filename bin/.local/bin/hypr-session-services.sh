#!/usr/bin/env bash
# Publish the current Hyprland instance before starting systemd-managed Sunshine.
set -euo pipefail

variables=(WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE XDG_RUNTIME_DIR)
for variable in "${variables[@]}"; do
    [[ -n "${!variable:-}" ]] || {
        printf 'Required Hyprland session variable is unset: %s\n' "$variable" >&2
        exit 1
    }
done

systemctl --user import-environment "${variables[@]}"
dbus-update-activation-environment --systemd "${variables[@]}"
systemctl --user start sunshine.service
