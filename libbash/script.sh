#!/bin/bash

isRootUser () { [[ $UID -eq 0 ]]; }
isFunction () { declare -F "$1" >/dev/null; }

renameFunction () {
    local oldName="$1"; shift
    local newName="$1"

    local definition="$(declare -f "$oldName")"
    if [[ $? -gt 0 ]]; then
        echo >&2 "renameFunction: $oldName is not a function"
        return
    fi

    if declare -f  "$newName" >/dev/null 2>/dev/null; then
        echo >&2 "renameFunction: $newName is already defined"
        return
    fi

    eval "$(echo "${definition/"$oldName"/"$newName"}")"
    # Does not work for recursive functions (like "//" would), but also
    # doesn't break if $oldName is a substring of something else

    unset "$oldName"
}

# Last mod time of a file or files
getFileTimestamp () {
    ls -1 --time-style=+%s -l  "$@" | cut -f6 -d" "
}
