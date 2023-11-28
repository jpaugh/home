#!/bin/bash
#echo "${BASH_SOURCE[0]}"
LIBBASHDIR="$HOME/libbash"

import () {
    for f in "$@"; do
        local fname="$(path_to_filename "$f")"
        import="$__import_${fname}"
        [[ $import == true ]] && continue

        if [[ -f "$LIBBASHDIR/$f.sh" ]]; then
            declare "__import_${fname}=true"
            source "$LIBBASHDIR/$f.sh"
        else
            echo >&2 "import: not found: '$f.sh'"
        fi
    done
}

path_to_filename () {
  echo ${@//\//_}
}
