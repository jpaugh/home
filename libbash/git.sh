#!/bin/bash
git_branch_exists() {
  branch="$1";shift
  git rev-parse --verify "refs/heads/$branch" 2>/dev/null 1>&2
}

git_ensure_clean_worktree() {
  local allow_unclean_index=false
  [[ "$1" = "--allow-unclean-index" ]] && allow_unclean_index=true
  $allow_unclean_index || git diff-index --quiet --cached HEAD -- || {
    echo >&2 "Aborting. Git index does not match HEAD"
    exit 1
  }

  git diff-files --quiet || {
    echo >&2 "Aborting. Unstaged files detected"
    exit 1
  }

  result="$(git ls-files --exclude-standard --others)" && test -z "$result" || {
    echo >&2 "Aborting. Untracked files detected"
    exit 1
  }
}
