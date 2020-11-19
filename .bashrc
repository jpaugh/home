#!/bin/bash

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

SAVE_PWD="$PWD"

AM_ROOT=false
[[ $UID -eq 0 ]] && AM_ROOT=true

# ANSI Colors (convenience variables)
declare -A COLOR
COLOR[normal]='\e[0m'
COLOR[green]='\e[1;32m'
COLOR[blue]='\e[1;34m'
COLOR[red]='\e[1;31m'
COLOR[yellow]='\e[1;33m'

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

isFunction () {
    declare -F "$1" >/dev/null
}

getOS () {
    case uname in
        [Ll][Ii][Nn][Uu][Xx])
            echo Linux
            ;;
        [Mm][Ii][Nn][Gg][Ww]*)
            echo MinGW
            ;;
    esac
}

JP_ENVIRONMENT="$(getOS)"

if _BASHRC_WAS_RUN 2>/dev/null; then
    :;
else    # Stuff that only needs to run the first time we source .bashrc.
        # Useful to allow resourcing new changes
    OLD_PATH="$PATH"
    PATH="$HOME/bin"
    PATH+=":$HOME/.local/bin"
    PATH+=":$HOME/node_modules/.bin"    # npm/node
    export PATH+=":/usr/local/heroku/bin" # Heroku Toolbelt
    PATH+=":$HOME/.cabal/bin"       # Haskell / Cabal
    PATH+=":/opt/java/jre/bin::/opt/java/jdk/bin" # Java
    PATH+=":/opt/maven/latest/bin"  # Maven
    #PATH+="$HOME/.gem/ruby/2.1.0/bin"
    #PATH+=":$HOME/build/gradle/gradle-2.3/bin"
    #PATH+=":$HOME/build/adt/adt-bundle-linux-x86-20140702/sdk/platform-tools"
    #PATH+=":$HOME/build/adt/adt-bundle-linux-x86-20140702/sdk/tools"
    #PATH+=":$HOME/build/adt/adt-bundle-linux-x86-20140702/sdk/build-tools/android-4.4W"
    #PATH+=":/usr/local/texlive/2013/bin/i386-linux"

    # The following line in case the OS default is not sane; Commented
    # out because I trust Ubuntu more than Gentoo in this regard
    #PATH+=":/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/usr/games/bin:/usr/local/games/bin"
    PATH+=":/opt/ghc/bin"
    PATH+=":/opt/neovim/latest/bin"
    PATH+=":$OLD_PATH"
    export PATH

    alias _BASHRC_WAS_RUN=true
    # Update PATH for the Google Cloud SDK
    #source '/home/jpaugh/google-cloud-sdk/path.bash.inc'
    # Enable bash completion for gcloud
    #source '/home/jpaugh/google-cloud-sdk/completion.bash.inc'

    # Set the DEFAULT_CMD to git, once
    # The DEFAULT_CMD is the command to run if the command line could
    # not be understood;
    DEFAULT_CMD=git
    if isFunction command_not_found_handle; then
	renameFunction command_not_found_handle PREVIOUS_COMMAND_NOT_FOUND_HANDLE
    else
	PREVIOUS_COMMAND_NOT_FOUND_HANDLE() { :; }
    fi

    command_not_found_handle () {
        eval '"$DEFAULT_CMD" $DEFAULT_CMD_PREFIX_ARGS "$@" $DEFAULT_CMD_POSTFIX_ARGS'
        if [ $? -gt 0 ]; then
            PREVIOUS_COMMAND_NOT_FOUND_HANDLE "$@"
        fi
    }
    export DEFAULT_CMD
fi

EDITOR=vim
LESS='--ignore-case --chop-long-lines'
CFLAGS="-O2 -fomit-frame-pointer -pipe"
CXXFLAGS="-O2 -fomit-frame-pointer -pipe"
MAKEOPTS="-j3"
JAVA_HOME="/opt/java/jdk"

# Only show the last 3 directories in the path
PROMPT_DIRTRIM=3

# Unlimited history
HISTSIZE=""
HISTFILESIZE=""

export EDITOR LESS CFLAGS CXXFLAGS MAKEOPTS PROMPT_DIRTRIM JAVA_HOME HISTSIZE HISTFILESIZE

# For aliases that may need sudo to gain root priviledges
SUDO=sudo
SUDO+=" "
$AM_ROOT && unset SUDO;

alias g=git
alias pdf='gui evince'
alias myps='ps u -u $USER'
alias less='less --LINE-NUMBERS'
if [[ -x  $(which colordiff 2>/dev/null) ]]; then
    alias diff='colordiff -u'
else
    alias diff='diff -u'
fi

alias vi=vim

#vim () {
#    if [ -z "$DISPLAY" ]; then
#        # Vim hangs if it can't find an X server.
#        # -X tells it not to connect to the X server.
#        command vim -X "$@"
#    else
#        command vim "$@"
#    fi
#}

# Tack on the end of a command line (`; beepx`) to get status info when
# the command ends
# TODO: Learn how to do this with `notify-send`
beepx () {
    if [ $? -gt 0 ]; then
        beep -D 100 -f 440 -r 1 -n -f 246.95
    else
        beep -D 100 -f 440 -r 1 -n -f 329.6
    fi
}

grok () {
    DIR=$1;shift
    grep -IR "$@" "$DIR"
}

# Last mod time of a file or files
get_file_timestamp () {
    ls -1 --time-style=+%s -l  "$@" | cut -f6 -d" "
}

# Make sure our version of the .bashrc file is up-to-date, or reload it.
chk_bashrc_timestamp () {
    FILE="$(readlink -f "$HOME/.bashrc")"
    if [[ "$_BASHRC_TIMESTAMP" -lt "$(get_file_timestamp "$FILE")" ]]; then
        echo >&2 "Reloading .bashrc..."
        . ~/.bashrc
    fi
}
_BASHRC_TIMESTAMP=$(date +%s)

# Collection of commands to run between prompts. Should be lightweight
prompt_cmd () {
    err=$?
    if [ $err -gt 0 ]; then
        echo >&2 -e "Error code: ${COLOR[red]}$err${COLOR[normal]}"
    fi
    chk_bashrc_timestamp
}
PROMPT_COMMAND=prompt_cmd

cd "$SAVE_PWD"

__brc_warn () {
    __brc_message "${COLOR[yellow]}" "[WARNING]" "$@"
}
__brc_error () {
    __brc_message "${COLOR[red]}" "[ERROR]" "$@"
}

__brc_message () {
    MSG_COLOR="$1";shift
    echo >&2 -en "$MSG_COLOR"
    echo >&2 "$@"
    echo >&2 -en "${COLOR[normal]}"
}

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias lF='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Steam Games

#Adventure capitalist
alias adcap='steam steam://rungameid/346900'
alias factorio='steam steam://rungameid/427520'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

BIB_APIKEY=4O4A2eA4iSv496GI4rla4aWNw3wHOACcMoXHQXuj
##
# Bible STuff
bib-apicall () {
    curl -L -u "$BIB_APIKEY:X" "http://bibles.org/v2$@" \
        | jq '' | tee /tmp/bib-apicall-$RANDOM.json | jq -C '' | less -RXF
}

bib-search () {
    local query excludeQuery book testament
    local translation=ESV
    local language=eng
    local spell=yes
    local joinOperator=all
    local sortOrder=relevance
    local offset=0
    local limit=500

    while [[ $# -gt 0 ]]; do
        case $1 in
            # Free-form values
            -t|--translation)
                shift
                translation="$1"
                ;;
            -x|--exclude)
                shift
                excludeQuery="$1"
                ;;
            -l|--language)
                shift;
                language="$1"
                ;;
            -b|--book)
                shift
                book="$1"
                ;;

            -c|--canonical-sort)
                sortOrder=canonical
                ;;
            -r|--relevance-sort)
                sortOrder=relevance
                ;;
            -f|--offset)
                shift
                offset="$1"
                ;;
            -m|--limit)
                shift
                limit="$1"
                ;;

            # Spelling
            -s|--spell)
                spell=yes
                ;;
            -S|--no-spell)
                spell=no
                ;;

            # Join Operator
            -a|--and)
                joinOperator=all
                ;;
            -o|--or)
                joinOperator=any
                ;;

            # Testament
            -e|--old|--old-testament)
                testament="OT"
                ;;
            -n|--new|--new-testament)
                testament="NT"
                ;;
            -d|--deuterocanonical)
                testament="DEUT"
                ;;
            *)
                if [[ -z $query ]]; then
                    query="$1"
                else
                    query="$query+$1"
                fi
                ;;
        esac
        shift;
    done
    if [[ -z $query ]]; then
        echo >&2 "Missing search query"
        return 1
    fi
    local transString="$language-$translation"
    params="query=$query&offset=$offset&limit=$limit"
    params+="&version=$transString&language=$language"
    params+="&precision=$joinOperator&sort_order=$sortOrder&spelling=$spell"
    [[ -n $excludeQuery ]] && params+="&exclude=$excludeQuery"
    [[ -n $book ]] && params+="&book=$transString:$book"
    [[ -n $testament ]] && params+="&testament=$testament"

    bib-apicall "/search.js?$params"
}
if [ -e /home/jpaugh/.nix-profile/etc/profile.d/nix.sh ]; then
    . /home/jpaugh/.nix-profile/etc/profile.d/nix.sh;
fi # copied from .bash_profile
