#!/bin/bash

isShellInteractive() {
    case $- in
        *i*) true;;
          *) false;;
    esac
}

isShellColorable() {
    [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null
}


if isShellColorable; then
    # ANSI Colors (convenience variables)
    declare -A COLOR
    COLOR[normal]='\e[0m'
    COLOR[green]='\e[1;32m'
    COLOR[blue]='\e[1;34m'
    COLOR[red]='\e[1;31m'
    COLOR[magenta]='\e[1;35m'
    COLOR[muteyellow]='\e[1;33m'
fi

aliasIfExecutable() {
    local executable="$1"; shift
    local alias="$1"; shift
    local args="$1"; shift

    type -t "$executable" >/dev/null || return
    alias "$alias"="'$executable' $args" 
}
