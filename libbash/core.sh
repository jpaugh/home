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

addPath () {
    local quiet=false
    case "$1" in
        -q|--quiet)
            quiet=true
            shift
            ;;
    esac

    for path in "$@"; do
        [[ -d "$path" ]] || {
            $quiet || echo >& "addPath: cannot add missing directory to path: '$path'"
            continue
        }

        case "$PATH" in
            *":$path:"*)
                ;;
            "$path:"*)
                ;;
            *":$path")
                ;;
            *)
                PATH+=":$path"
                ;;
        esac
    done
}
