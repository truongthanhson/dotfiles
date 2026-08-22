# dotfiles

GNU Stow-managed configuration. Each top-level directory is a stow package whose
internal path mirrors the home directory — e.g. `hypr/.config/hypr/hyprland.conf`
installs to `~/.config/hypr/hyprland.conf`.

## Restore / install

```bash
cd ~/dotfiles
stow hypr fcitx5 sunshine snow-topbar bin zsh
```

Add `-R` to restow (re-link) an already-installed package. The current install
uses real files (not symlinks); to move to a symlinked stow setup, use
`stow --adopt <pkg>` or copy the files into place manually.

## Packages

### hypr
Hyprland config plus `~/.dmrc` (Session=hyprland, so SDDM defaults to Hyprland).
Implements the work/stream display workflow: work mode = DP-1 @ 2560x1440@240,
stream mode = HDMI-A-1 dummy @ 1920x1080@60, with the topbar hidden in stream
mode. Also wires the Fcitx5 input-method env vars and Ctrl+Space / Super+Space
toggle binds.

### fcitx5
Vietnamese input method (replaced IBus, which cannot drive `ibus-bamboo` on
Hyprland's Wayland — see `zwp_input_method_v2` note below). Bamboo engine with
Telex typing, toggled via the Hyprland binds. `profile` + `config` are the
source of truth; `conf/` is generated runtime state (gitignored).

### sunshine
Sunshine (Moonlight) streaming config: `capture = wlr` + NVENC, tuned for
Nintendo Switch OLED at 720p60. The systemd drop-in
`app-dev.lizardbyte.app.Sunshine.service.d/hyprland-display-recovery.conf`
restores work mode when Sunshine stops, so the display never stays in stream
mode. TLS credentials live in `~/.config/sunshine/credentials/` and are
**not** tracked (gitignored).

### snow-topbar
Topbar config: primary monitor DP-1, ignores HDMI-A-1 so the dummy output never
pollutes the stream capture.

### bin
Workflow scripts (installed to `~/.local/bin`):

| Script | Purpose |
|--------|---------|
| `display-mode-hypr.sh` | Switch outputs between work and stream mode (flock-serialized, rollback on failure) |
| `work-mode.sh` / `stream-mode.sh` | Thin user-facing wrappers (Alt+Shift+F1/F2 binds) |
| `sunshine-session-mode.sh` | Sunshine `global_prep_cmd` do/undo hook |
| `hypr-session-services.sh` | `exec-once` starter for Sunshine (plain Hyprland doesn't activate `graphical-session.target`) |
| `setup-sddm.sh` | Idempotent SDDM bootstrap — reproduces the `/etc` changes below |

### zsh
`.zprofile` adds `~/.local/bin` to PATH for login shells. SDDM launches sessions
via `zsh --login`, which sources `.zprofile` (not `.zshrc`), so this keeps user
scripts and Rofi run-mode discoverable in the graphical session.

## System-level config (reproduced, not stored here)

SDDM replaced LightDM. The `/etc` changes — `/etc/sddm.conf.d/10-snow.conf`,
`/etc/pam.d/sddm` (gnome-keyring unlock), the greeter `Xsetup`, and the
`state.conf` preselect — are applied idempotently by `bin/.local/bin/setup-sddm.sh`.

## Notes

- **IBus → Fcitx5**: IBus speaks input-method protocol v1 while Hyprland only
  exposes `zwp_input_method_manager_v2`, and `ibus-bamboo` crashes on Wayland as
  a result. Fcitx5 ships the same Bamboo engine with native v2 support, so it is
  the supported Vietnamese input method on Hyprland.
- **Topbar**: the Omarchy-style topbar implementation lives in `~/projects/topbar`
  (its own git repository), not here.
