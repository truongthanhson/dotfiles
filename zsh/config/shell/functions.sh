_os_is_mac() { [[ "$OSTYPE" == darwin* ]]; }

_os_open() { if _os_is_mac; then open "$@"; else xdg-open "$@"; fi }

# first Android SDK that actually exists: $ANDROID_HOME, then the macOS and Linux defaults
_android_sdk() {
  local sdk
  for sdk in "$ANDROID_HOME" "$HOME/Library/Android/sdk" "$HOME/Android/Sdk"; do
    [[ -n "$sdk" && -d "$sdk" ]] && { echo "$sdk"; return 0 }
  done
  return 1
}

# ch [profile] - browse chrome history and open the chosen URL(s); defaults to the Default profile
ch() {
  local cols sep db root url
  cols=$(( COLUMNS / 3 ))
  sep='{::}'
  if _os_is_mac; then
    root="$HOME/Library/Application Support/Google/Chrome"
  else
    root="$HOME/.config/google-chrome"
  fi
  db="$root/${1:-Default}/History"
  [[ -f "$db" ]] || { echo "ch: history db not found: $db" >&2; return 1; }

  cp -f "$db" /tmp/h
  sqlite3 -separator "$sep" /tmp/h \
    "select substr(title, 1, $cols), url
     from urls order by last_visit_time desc" |
  awk -F "$sep" '{printf "%-'"$cols"'s  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | while read -r url; do
    _os_open "$url"
  done
}

# fcd - fuzzy cd into a subdirectory (was fd(), which shadowed the fd binary)
fcd() {
  local dir
  dir=$(fd --type d --hidden --exclude .git . "${1:-.}" 2>/dev/null \
    | fzf +m --preview 'eza -la --color=always --icons {}') && cd "$dir"
}

# fh - search in your command history and execute selected command
fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

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
# sakani-bootstrap [path] [extra flags...] - wire AI tooling into a sakani worktree
# Runs ai-dotfiles' bootstrap-project.sh against the current dir (or a given path):
# dry-runs first, asks to confirm, then applies. Extra flags (e.g. --backup-existing,
# -y to skip the prompt) pass through. Override the checkout via DOTFILES_AI_ROOT.
sakani-bootstrap() {
  local ai_root="${DOTFILES_AI_ROOT:-$HOME/projects/ai-dotfiles}"
  local script="$ai_root/scripts/bootstrap-project.sh"
  [[ -x "$script" ]] || { echo "sakani-bootstrap: not found: $script" >&2; return 1; }

  local assume_yes=0 target=""
  local -a flags=()
  while (( $# )); do
    case "$1" in
      -y|--yes) assume_yes=1 ;;
      -*) flags+=("$1") ;;
      *) [[ -z "$target" ]] && target="$1" || flags+=("$1") ;;
    esac
    shift
  done
  target="${target:-$PWD}"
  target="${target:A}"

  [[ -d "$target" ]] || { echo "sakani-bootstrap: no such directory: $target" >&2; return 1; }
  if [[ "$(git -C "$target" rev-parse --is-bare-repository 2>/dev/null)" == true ]]; then
    echo "sakani-bootstrap: $target is a bare repo; cd into a worktree first" >&2
    return 1
  fi

  echo "→ dry-run: $target"
  "$script" --dry-run "$target" "${flags[@]}" || return 1
  if (( ! assume_yes )); then
    echo
    read -q "REPLY?Apply bootstrap to ${target}? [y/N] " || { echo; echo "aborted"; return 1; }
    echo
  fi
  "$script" "$target" "${flags[@]}"
}

ticket() {
  local id="$1"          # e.g. SAKANI-41100
  local desc="$2"        # e.g. fix-map-filter-persistence
  local vault="$HOME/vault"
  local filename="${id}-${desc}.md"
  local filepath="$vault/00-Projects/Sakani/$filename"
  local date=$(date +%Y-%m-%d)
  local year=$(date +%Y)

  # Create note with pre-filled frontmatter
  cat > "$filepath" << EOF
---
id: $(date +%s)
aliases:
  - ${id}-${desc}
tags:
  - sakani
  - ticket
ticket: https://jira.nhc.sa/browse/${id}
mr:
figma:
status: in-progress
sprint: "${year}-S"
created: ${date}
closed:
---
# ${id} ${desc}

## Understanding

## Implementation Plan

- [ ]

## Decisions & Context

## Test Accounts / Environments

## References

- Jira: https://jira.nhc.sa/browse/${id}
EOF

  echo "Created: $filepath"
}

# swt - create a Sakani worktree, bootstrap AI context, and cd into it
# usage: swt <folder-slug> <branch> [--build]
#   folder-slug : worktree becomes ~/projects/sakani-<folder-slug>
#   branch      : checked out if it exists (local/remote), else created from origin/master
#   --build     : also run the melos cold-start (initsds, bootstrap, arcgis install)
# copies .nvim.lua and the fvm SDK pin (.fvmrc, .fvm/) from $main since both are gitignored
swt() {
  local main="$HOME/projects/sakani-v4-mobile"
  local vault="$HOME/vault/03-Resources/AI-Assistants/projects/sakani"
  local bootstrap="$HOME/projects/ai-dotfiles/scripts/bootstrap-project.sh"

  local build=0
  local -a pos=()
  local arg
  for arg in "$@"; do
    if [[ "$arg" == "--build" ]]; then
      build=1
    else
      pos+=("$arg")
    fi
  done

  if (( ${#pos} < 2 )); then
    echo "usage: swt <folder-slug> <branch> [--build]" >&2
    return 1
  fi

  local slug="${pos[1]}"
  local branch="${pos[2]}"
  local wt="$HOME/projects/sakani-${slug}"

  [[ -e "$main/.git" ]] || { echo "swt: main repo not found at $main" >&2; return 1; }
  [[ -e "$wt" ]] && { echo "swt: $wt already exists" >&2; return 1; }

  echo "==> fetching origin"
  git -C "$main" fetch origin --quiet || return 1

  echo "==> creating worktree $wt (branch: $branch)"
  if git -C "$main" show-ref --verify --quiet "refs/heads/$branch" \
     || git -C "$main" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    git -C "$main" worktree add "$wt" "$branch" || return 1
  else
    git -C "$main" worktree add -b "$branch" "$wt" origin/master || return 1
  fi

  echo "==> bootstrapping AI context"
  "$bootstrap" --vault-dir "$vault" "$wt" || return 1

  if [[ -f "$main/.nvim.lua" ]]; then
    echo "==> copying .nvim.lua into worktree"
    cp "$main/.nvim.lua" "$wt/.nvim.lua"
  fi

  if [[ -f "$main/.fvmrc" ]]; then
    echo "==> copying fvm SDK pin into worktree"
    cp "$main/.fvmrc" "$wt/.fvmrc"
    cp -R "$main/.fvm" "$wt/.fvm"
  fi

  if (( build )); then
    echo "==> melos cold-start (takes a few minutes; needs gitlab.iwa.fi SSH key loaded)"
    ( cd "$wt" \
      && melos run initsds \
      && melos clean && melos bootstrap \
      && dart run arcgis_maps install ) || return 1
  fi

  echo "==> done; entering $wt"
  cd "$wt"
}
# fbr - fuzzy checkout a git branch (local or remote)
fbr() {
  local branch
  branch=$(git for-each-ref --format='%(refname:short)' refs/heads refs/remotes \
    | grep -v '/HEAD$' | sort -u \
    | fzf --preview 'git log --oneline --color=always --max-count=30 {}') || return
  git checkout "${branch#origin/}"
}

# rgv [query] - live ripgrep across the tree; open the chosen match in nvim at that line
rgv() {
  local sel file line
  sel=$(: | fzf --ansi --disabled --query "${*:-}" \
    --bind 'start:reload:rg --line-number --no-heading --color=always --smart-case {q} || true' \
    --bind 'change:reload:rg --line-number --no-heading --color=always --smart-case {q} || true' \
    --delimiter=: \
    --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
    --preview-window 'up,60%,+{2}/2') || return
  file=${sel%%:*}; line=${${sel#*:}%%:*}
  [[ -n "$file" ]] && nvim "+${line}" "$file"
}

# fglog - browse git history with fzf; enter pages the full commit (glog is an OMZ alias)
fglog() {
  git log --color=always --format='%C(auto)%h %s %C(black)%C(bold)%cr %an' "$@" \
    | fzf --ansi --no-sort --reverse \
        --preview 'git show --color=always {1}' \
        --bind 'enter:execute(git show --color=always {1} | less -R)'
}

# vn - fuzzy-find a vault note and open it in nvim (pairs with ticket())
vn() {
  local f
  f=$(fd --type f -e md . "$HOME/vault" \
    | fzf --preview 'bat --style=plain --color=always {}') && nvim "$f"
}

# fkill [signal] - pick process(es) with fzf and kill them (default TERM)
fkill() {
  local pids
  local -a sort_flag
  # BSD ps has no --sort; -r is its sort-by-CPU
  if _os_is_mac; then sort_flag=(-r); else sort_flag=(--sort=-%cpu); fi
  pids=$(ps -eo pid,user,%cpu,%mem,comm "${sort_flag[@]}" | sed 1d \
    | fzf --multi --header='select process(es) to kill' | awk '{print $1}')
  [[ -n "$pids" ]] && echo "$pids" | xargs kill "${1:--TERM}"
}

# mkcd - make a directory (and parents) and cd into it
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# extract - unpack most archive types by extension
extract() {
  [[ -f "$1" ]] || { echo "extract: '$1' is not a file" >&2; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.xz)         tar xJf "$1" ;;
    *.tar.zst)        tar xf "$1" ;;
    *.tar)            tar xf "$1" ;;
    *.gz)             gunzip "$1" ;;
    *.bz2)            bunzip2 "$1" ;;
    *.zip)            unzip "$1" ;;
    *.rar)            unrar x "$1" ;;
    *.7z)             7z x "$1" ;;
    *.zst)            unzstd "$1" ;;
    *) echo "extract: unknown archive type '$1'" >&2; return 1 ;;
  esac
}

_emu_bin() {
  local sdk bin
  sdk=$(_android_sdk) || { echo "Android SDK not found; set ANDROID_HOME" >&2; return 1; }
  bin="$sdk/emulator/emulator"
  [[ -x "$bin" ]] || { echo "emulator not found: $bin" >&2; return 1; }
  echo "$bin"
}

# emu [avd] [flags...] - launch an Android AVD detached, no terminal log.
#   emu -l   list available AVDs
# On Linux, hides the NVIDIA Vulkan ICD from the emulator so its Vulkan init can't
# stall Warp's Vulkan renderer (whole-UI hang). Defaults to the 16KB Pixel 8 Pro AVD.
emu() {
  local bin avd
  bin=$(_emu_bin) || return 1
  case "$1" in
    -l|--list|ls) "$bin" -list-avds; return ;;
  esac
  avd="${1:-Pixel_8_Pro_API_35_-_16KB}"
  (( $# )) && shift
  if _os_is_mac; then
    ( "$bin" -avd "$avd" "$@" >/dev/null 2>&1 & )
    echo "emu: started $avd (detached)"
  else
    ( VK_LOADER_DRIVERS_DISABLE=nvidia_icd.json "$bin" -avd "$avd" "$@" >/dev/null 2>&1 & )
    echo "emu: started $avd (detached; NVIDIA Vulkan ICD disabled)"
  fi
}

# emu-gpu [avd] [flags...] - like emu but renders on the host GPU (smooth).
#   emu-gpu -l   list available AVDs
# On Linux this does NOT block the NVIDIA Vulkan ICD, so the emulator's Vulkan can
# collide with Warp's and hang it - start the emulator before Warp, or keep Warp closed.
emu-gpu() {
  local bin avd
  bin=$(_emu_bin) || return 1
  case "$1" in
    -l|--list|ls) "$bin" -list-avds; return ;;
  esac
  avd="${1:-Pixel_8_Pro_API_35_-_16KB}"
  (( $# )) && shift
  ( "$bin" -avd "$avd" -gpu host "$@" >/dev/null 2>&1 & )
  if _os_is_mac; then
    echo "emu-gpu: started $avd (host GPU)"
  else
    echo "emu-gpu: started $avd (NVIDIA GPU; may hang Warp if open)"
  fi
}

# tab-complete emu/emu-gpu with the installed AVD names
(( $+functions[compdef] )) && {
  _emu() {
    local bin
    bin=$(_emu_bin 2>/dev/null) || return
    compadd -- ${(f)"$("$bin" -list-avds 2>/dev/null)"}
  }
  compdef _emu emu emu-gpu
}

function y() {  
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd  
    yazi "$@" --cwd-file="$tmp"  
    IFS= read -r -d '' cwd < "$tmp"  
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"  
    rm -f -- "$tmp"  
}
