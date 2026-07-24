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
