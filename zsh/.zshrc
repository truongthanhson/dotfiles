if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
	z
)

source $ZSH/oh-my-zsh.sh

alias vim="nvim"
alias zsh="nvim ~/.zshrc"
alias vimconf="cd ~/.config/nvim && vim ."
alias tmuxconf="nvim ~/.tmux.conf"
alias lss="~/.local/scripts/tmux_sessionizer"
alias ls="exa"
alias ll="exa -alh"
alias tree="exa --tree"
alias gs="git status"

export FLUTTER="/Users/sontruong/DevTools/flutter-3.7.10/flutter"
export ANDROID="/Users/sontruong/Library/Android/sdk"
export POSTGRESQL="/usr/local/opt/postgresql@10"
export MYSQL="/usr/local/mysql"
export PATH="$PATH:$MYSQL/bin"
export PATH="$FLUTTER/bin:$PATH"
export PATH="$PATH:$POSTGRESQL/bin"
export PATH="$PATH:$ANDROID/platform-tools:$ANDROID/tools"
export PATH="$PATH":"$HOME/.pub-cache/bin"




source ~/powerlevel10k/powerlevel10k.zsh-theme


[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ch - browse chrome history
ch() {
  local cols sep
  cols=$(( COLUMNS / 3 ))
  sep='{::}'

  cp -f ~/Library/Application\ Support/Google/Chrome/Profile\ 1/History /tmp/h

  sqlite3 -separator $sep /tmp/h \
    "select substr(title, 1, $cols), url
     from urls order by last_visit_time desc" |
  awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs open
}

#
# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}
 
# fh - search in your command history and execute selected command
fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}
