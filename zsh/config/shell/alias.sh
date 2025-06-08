alias vim="nvim"
alias zsh="nvim ~/.zshrc"
alias vimconf="cd ~/.config/nvim && vim ."
alias tmuxconf="nvim ~/.tmux.conf"
alias lss="~/.local/scripts/tmux_sessionizer"
alias ls="eza"
alias ll="eza -alh"
alias tree="eza --tree"

# git
alias ga='git add'
alias gb='git branch'
alias gc='git checkout'
alias gcl='git clone'
alias gcm='git commit -m'
alias gf='git fetch'
alias gp='git pull origin'
alias gpu='git push origin'
alias gs='git status'  # 'status' is protected name so using 'stat' instead

alias -s txt=$EDITOR
## open Flutter developement file with $EDITOR (neovim)
alias -s dart=$EDITOR
alias -s java=$EDITOR
alias -s swift=$EDITOR
alias -s k=$EDITOR
