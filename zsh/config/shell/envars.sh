export FLUTTER=$HOME/devtools/flutter
#export NVIM_HOME=/home/sontruong/Documents/dev-tools/nvim
export ANDROID_HOME=$HOME/Library/Android/sdk
#export JAVA_HOME=/usr/lib/jvm/jdk-21-oracle-x64
export GOLANG_HOME=~/go

## PATH stuffs
export PATH=$FLUTTER/bin:$PATH
#export PATH=$NVIM_HOME/usr/bin:$PATH
export PATH=$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH
#export PATH=$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"
export PATH=$PATH:$GOLANG_HOME/bin
export PATH=$PATH:/opt/nvim-linux64/bin
export PATH=$PATH:~/.local/scripts

## Editor
export EDITOR=nvim

## Fzf configuration
# tokyonight dark
export FZF_DEFAULT_OPTS='--color=bg+:#292e42,bg:#16161e,border:#1f2335,hl:#ff9e64,fg:#a9b1d6,header:#292e42,pointer:#bb9af7,fg+:#a9b1d6,preview-bg:#24283b,prompt:#7dcfff,hl+:#7aa2f7,info:#e0af68'
# tokyonight day
# export FZF_DEFAULT_OPTS='--color=bg+:#c4c8da,bg:#e9e9ec,border:#e9e9ec,hl:#b15c00,fg:#6172b0,header:#c4c8da,pointer:#9854f1,fg+:#6172b0,preview-bg:#e1e2e7,prompt:#007197,hl+:#2e7de9,info:#8c6c3e'


