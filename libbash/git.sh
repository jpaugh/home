#!/bin/bash
git_local_branch_exists() {
  local branch="$1";shift
  git rev-parse --verify "refs/heads/$branch" 2>/dev/null 1>&2
}
git_ref_exists() {
    local ref="$1";shift
    git rev-parse --verify "$ref" 2>/dev/null 1>&2
}

git_print_branch_checked_out() {
    git branch --show-current
}

git_is_same_commit() {
    local refA="$1"; shift
    local refB="$1"; shift

    [[ "$(git rev-parse "$refA" 2>/dev/null)" == "$(git rev-parse "$refB" 2>/dev/null)" ]]
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

git_print_git_dir() {
    git rev-parse --git-dir
}

git_print_toplevel() {
    git rev-parse --show-toplevel
}

git_is_ancestor() {
    git merge-base --is-ancestor "$@"
}

git_get_refs_by_pattern() {
    # git_get_refs_by_prefix PATTERN
    # List all references which start with PATTERN.
    # PATTERN is a PCRE regex
    declare -a show_ref_args
    local pattern=".*"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --head|--heads|--tags)
                show_ref_args+=("$1")
                ;;
            *)
                pattern="$1"; shift
                break
                ;;
        esac
        shift
    done
    [[ $# -gt 0 ]] && {
        echo >&2 "Ignoring extra arguments: '$@'"
    }

    git show-ref "${show_ref_args[@]}" | cut -f2-9999 -d' ' | $(which grep) --perl-regexp "${pattern}"
}
