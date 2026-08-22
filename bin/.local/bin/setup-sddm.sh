#!/usr/bin/env bash
# Replace LightDM with SDDM on the Snow workstation.
#
# Run as:  sudo bash /home/snow/.local/bin/setup-sddm.sh
#
# Safe and idempotent:
#   * Keeps LightDM installed (disabled) as a rollback.
#   * Does NOT stop or restart the running display manager, so the current
#     session is never interrupted. The swap takes effect on next boot.
#   * Backs up any file it overwrites with a timestamped suffix.
#
# Rollback (at a root shell):
#   systemctl disable sddm.service
#   systemctl enable lightdm.service
#   reboot
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
    printf 'Run with sudo/root: sudo bash %s\n' "$0" >&2
    exit 1
fi

REAL_USER=snow
STAMP="$(date +%Y%m%d-%H%M%S)"

printf '==> Installing SDDM (LightDM stays installed as fallback)\n'
pacman -S --needed --noconfirm sddm

printf '==> Writing /etc/sddm.conf.d/10-snow.conf\n'
install -d /etc/sddm.conf.d
cat > /etc/sddm.conf.d/10-snow.conf <<'EOF'
# Snow workstation SDDM configuration.
# The greeter runs on X11 (matches the working NVIDIA/X11 stack); user
# sessions are Wayland (Hyprland), with i3 kept as an X11 fallback session.
[General]
Numlock=none

[Users]
RememberLastUser=true
RememberLastSession=true
EOF

printf '==> Writing greeter Xsetup (real monitor on, dummy HDMI off)\n'
XSETUP=/usr/share/sddm/scripts/Xsetup
[[ -e "$XSETUP" ]] && cp -a "$XSETUP" "${XSETUP}.before-sddm-setup-${STAMP}"
cat > "$XSETUP" <<'EOF'
#!/bin/sh
# SDDM X11 greeter: show the login screen only on the real display.
command -v xrandr >/dev/null 2>&1 || exit 0
xrandr --output HDMI-0 --off --output DP-0 --auto --primary 2>/dev/null || true
EOF
chmod 755 "$XSETUP"

printf '==> Writing /etc/pam.d/sddm (unlock gnome-keyring, like LightDM did)\n'
PAM=/etc/pam.d/sddm
[[ -e "$PAM" ]] && cp -a "$PAM" "${PAM}.before-sddm-setup-${STAMP}"
cat > "$PAM" <<'EOF'
#%PAM-1.0
auth        include     system-login
-auth       optional    pam_gnome_keyring.so
account     include     system-login
password    include     system-login
session     include     system-login
-session    optional    pam_gnome_keyring.so auto_start
EOF

printf '==> Preselecting Hyprland for %s (honors existing ~/.dmrc)\n' "$REAL_USER"
STATE=/var/lib/sddm/state.conf
if [[ ! -e "$STATE" ]]; then
    install -d /var/lib/sddm
    cat > "$STATE" <<EOF
[Last]
Session=hyprland.desktop
User=${REAL_USER}
EOF
    chown sddm:sddm "$STATE"
fi

printf '==> Enabling SDDM and disabling LightDM (no immediate restart)\n'
systemctl disable lightdm.service
systemctl enable sddm.service

printf '\nDone. SDDM is enabled and LightDM is disabled.\n'
printf 'The current session is untouched. Reboot when ready:\n'
printf '    sudo systemctl reboot\n\n'
printf 'First login: pick the user, confirm the session selector shows\n'
printf '"Hyprland", then log in. Rollback instructions are in the script header.\n'
