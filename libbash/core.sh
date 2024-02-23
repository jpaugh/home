#!/bin/bash
#echo "${BASH_SOURCE[0]}"
LIBBASHDIR="$HOME/libbash"
MOD_PREFIX="__LIBBASH_MODULE_"

import () {
    for f in "$@"; do
        local module_name="${f//\/_}"
        did_try_load_module "$module_name" && return

        if [[ -f "$LIBBASHDIR/$f.sh" ]]; then
            source "$LIBBASHDIR/$f.sh"
            set_module_loadstate "$module_name" true
        else
            echo >&2 "import: not found: '$f.sh'"
            set_module_loadstate "$module_name" false
        fi
    done
}

if [[ -z "$__LIBBASH_CORE_IS_LOADED" ]]; then
    __LIBBASH_CORE_IS_LOADED=true
fi

get_module_loadstate() {
    module_name="${MOD_PREFIX}$1";shift
    eval echo \$''"$module_name"
}

set_module_loadstate() {
    module_name="${MOD_PREFIX}$1";shift
    state="$2" # should be true or false
    declare "$module_name"="$state"
}

is_module_loaded() {
    local loadstate = get_module_loadstate "$@"
    [[ $loadstate == "true" ]]
}

did_try_load_module() {
    local loadstate = get_module_loadstate "$@"
    [[ -n $loadstate ]]
}


# Core module loaded successfully
set_module_loadstate core true
