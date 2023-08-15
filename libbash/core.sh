#!/bin/bash
#echo "${BASH_SOURCE[0]}"
LIBBASHDIR="$HOME/libbash"

import () {
    for f in "$@"; do
        if [[ -f "$LIBBASHDIR/$f.sh" ]]; then
            source "$LIBBASHDIR/$f.sh"
        else
            echo >&2 "import: not found: '$f.sh'"
        fi
    done
}
