#!/bin/bash

getOS () {
    uname -o | tr '[:upper:]' '[:lower:]'
}

SYSNAME="$(getOS)"

loadsysprofile () {
    local SYSNAME_FILE="$(path_to_filename "$SYSNAME")"
    echo "Loading system profile for $SYSNAME"
    import "sys/$SYSNAME_FILE"
}
