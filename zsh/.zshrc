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
source ~/config/shell/envars.sh
source ~/config/shell/alias.sh
source ~/config/shell/functions.sh
source ~/config/shell/secrets.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
