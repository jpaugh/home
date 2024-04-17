#!/usr/bin/env bash

main() {
  pushd "$(dirname "$0")"
  local REPO_DIR="$(git rev-parse --show-toplevel)"
  popd

  local source="$REPO_DIR/dotfiles"

  find "$source" -maxdepth 1 -print0 | \
    while read -r -d '' file; do
      local filename="$(basename "$file")"

      # Remove dangling symlinks
      [[ -h "$HOME/$filename" ]] && ! readlink --canonicalize-existing "$HOME/$filename" && {
        rm "$HOME/$filename"
      }

      # Skip existing files
      [[ -e "$HOME/$filename" ]] && {
        echo "Skipping existing file \"~/$filename\""
        continue
      }

      ln --symbolic --verbose --target-directory="$HOME" "$file"
    done
  #-exec ln -sv --target="$HOME" '{}' '+'
}

main
