#!/bin/bash
SYSNAME="$(uname -o | tr '[:upper:]' '[:lower:]')"
loadsysprofile () {
    echo "Loading system profile for $SYSNAME"
    import "sys/$SYSNAME"
}
