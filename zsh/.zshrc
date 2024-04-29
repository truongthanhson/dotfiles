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


#export FLUTTER=/home/sontruong/Documents/dev-tools/flutter
#export NVIM_HOME=/home/sontruong/Documents/dev-tools/nvim
#export ANDROID_HOME=/home/sontruong/Android/Sdk
#export JAVA_HOME=/usr/lib/jvm/jdk-21-oracle-x64
#export GOLANG_HOME=/usr/local/go
#export PATH=$FLUTTER/bin:$PATH
#export PATH=$NVIM_HOME/usr/bin:$PATH
#export PATH=$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH
#export PATH=$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$PATH
#export PATH="$PATH":"$HOME/.pub-cache/bin"
#export PATH=$PATH:$GOLANG_HOME/bin
export PATH=$PATH:/opt/nvim-linux64/bin


# source ~/powerlevel10k/powerlevel10k.zsh-theme


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

## [Completion] 
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/sontruong/.dart-cli-completion/zsh-config.zsh ]] && . /home/sontruong/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

# amazing -wip- command for save work-in-progess to git
# ref: https://itnext.io/multitask-like-a-pro-with-the-wip-commit-2f4d40ca0192
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'

alias gunwip='git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1'

# Similar to `gunwip` but recursive "Unwips" all recent `--wip--` commits not just the last one
function gunwipall() {
  local _commit=$(git log --grep='--wip--' --invert-grep --max-count=1 --format=format:%H)

  # Check if a commit without "--wip--" was found and it's not the same as HEAD
  if [[ "$_commit" != "$(git rev-parse HEAD)" ]]; then
    git reset $_commit || return 1
  fi
}
