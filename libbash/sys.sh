#!/bin/bash

getOS () {
    uname -o | tr '[:upper:]' '[:lower:]'
}

SYSNAME="$(getOS)"

loadsysprofile () {
    echo "Loading system profile for $SYSNAME"
    import "sys/$SYSNAME"
}
