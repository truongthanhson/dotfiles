
# Added by `rbenv init` on Thu Jun  5 05:26:41 PM +07 2025
eval "$(rbenv init - --no-rehash zsh)"

# SDDM launches sessions via `zsh --login` (sources .zprofile, not .zshrc).
# Keep user-local binaries discoverable (Rofi run mode, scripts) for the
# graphical session and any login shell without double-prefixing PATH.
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
