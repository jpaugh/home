#!/bin/bash
[[ -f "$HOME/libbash/core.sh"  ]] && . "$HOME/libbash/core.sh" || {
    echo >&2 "Cannot load libbash"
    read -p "Press any key to continue..."
    exit 1
}
import sys script
import shell

isShellInteractive || exit 1

SAVE_PWD="$PWD"

__set_path() {
    OLD_PATH="$PATH"
    PATH="$HOME/bin"
    PATH+=":$HOME/.local/bin"
    PATH+=":$HOME/node_modules/.bin"    # npm/node
    PATH+=":/usr/local/heroku/bin" # Heroku Toolbelt
    PATH+=":$HOME/.cabal/bin"       # Haskell / Cabal
    PATH+=":/opt/java/jre/bin::/opt/java/jdk/bin" # Java
    PATH+=":/opt/maven/latest/bin"  # Maven
    #PATH+="$HOME/.gem/ruby/2.1.0/bin"
    #PATH+=":$HOME/build/gradle/gradle-2.3/bin"
    #PATH+=":$HOME/build/adt/adt-bundle-linux-x86-20140702/sdk/platform-tools"
    #PATH+=":$HOME/build/adt/adt-bundle-linux-x86-20140702/sdk/tools"
    #PATH+=":$HOME/build/adt/adt-bundle-linux-x86-20140702/sdk/build-tools/android-4.4W"
    #PATH+=":/usr/local/texlive/2013/bin/i386-linux"

    PATH+=":/opt/neovim/latest/bin"
    PATH+=":/opt/ghc/bin"
    PATH+=":$OLD_PATH"
    export PATH
}

__set_vars() {
    EDITOR=vim
    LESS='--ignore-case --chop-long-lines'
    CFLAGS="-O2 -fomit-frame-pointer -pipe"
    CXXFLAGS="-O2 -fomit-frame-pointer -pipe"
    MAKEOPTS="-j3"

    # JAVA_EXEC will take the form ".../something/bin/java", where
    # "something" is the JAVA_HOME
    local JAVA_EXEC="$(readlink -f "$(which java)")"
    JAVA_HOME="$(dirname "$(dirname "$JAVA_EXEC")")"

    # Only show the last 3 directories in the path of PS1, PS2, etc
    PROMPT_DIRTRIM=3

    # don't put duplicate lines or lines starting with space in the history.
    # See bash(1) for more options
    HISTCONTROL=ignoreboth

    # For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
    HISTSIZE=-1
    HISTFILESIZE=-1

    export EDITOR LESS CFLAGS CXXFLAGS MAKEOPTS PROMPT_DIRTRIM JAVA_HOME HISTSIZE HISTFILESIZE HISTCONTROL
}

__set_ls_color() {
    if [ -x /usr/bin/dircolors ]; then
        local dircolors_database="~/.dircolors"
        [ -r $dircolors_database ] || dircolors_database=""
        eval "$(dircolors --bourne-shell $dircolors_database)"
        export LS_COLORS
    fi
}


__set_aliases() {
    # Add a $SUDO variable that allows alias definitions to escalate to
    # root. Works fine if the user already is root, too. 
    local SUDO="sudo"
    isRootUser && unset SUDO

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

    alias ll='ls -alF'
    alias la='ls -A'
    alias lF='ls -CF'

    if isShellColorable; then
        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'

        __set_ls_color
        if [ -x /usr/bin/dircolors ]; then
            alias ls='ls --color=auto'
            alias dir='dir --color=auto'
            alias vdir='vdir --color=auto'
        fi
    fi

    [ -f ~/.bash_aliases ] && . ~/.bash_aliases
}

__set_shellopts() {

    # append to the history file, don't overwrite it
    shopt -s histappend

    # check the window size after each command and, if necessary,
    # update the values of LINES and COLUMNS.
    shopt -s checkwinsize

    # If set, the pattern "**" used in a pathname expansion context will
    # match all files and zero or more directories and subdirectories.
    shopt -s globstar

}

__empty_command_not_found_handle() { :; }
__my_command_not_found_handle() {
    eval '"$DEFAULT_CMD" $DEFAULT_CMD_PREFIX_ARGS "$@" $DEFAULT_CMD_POSTFIX_ARGS'
    if [ $? -gt 0 ]; then
        # Chain to the previous command_not_found_handle
        PREVIOUS_COMMAND_NOT_FOUND_HANDLE "$@"
    fi
}
__set_command_not_found_handle() {
    if isFunction command_not_found_handle; then
        # preserve existing handle to allow chaining
        renameFunction command_not_found_handle PREVIOUS_COMMAND_NOT_FOUND_HANDLE
    else
        renameFunction __empty_command_not_found_handle PREVIOUS_COMMAND_NOT_FOUND_HANDLE
    fi
    renameFunction __my_command_not_found_handle command_not_found_handle

    # our command_not_found_handle runs the DEFAULT_CMD with the entire
    # commandline as its parameters iff the user-typed command cannot be
    # found
    export DEFAULT_CMD=git
}

__set_shell_prompt() {
    # set variable identifying the chroot you work in (used in the prompt below)
    if [ -z "${chroot_label:-}" ] && [ -r /etc/debian_chroot ]; then
        local chroot_label=$(cat /etc/debian_chroot)
    fi

    # If this is an xterm set the title to user@host:dir
    local winTitle=""
    case "$TERM" in
    xterm*|rxvt*)
        winTitle="\[\e]0;${chroot_label:+($chroot_label)}\u@\h: \w\a\]"
        ;;
    esac

    # TODO: Figure out how to define this in a sourced script
    if isShellColorable; then
        # ANSI Colors (convenience variables)
        declare -A COLOR
        COLOR[normal]='\e[0m'
        COLOR[green]='\e[1;32m'
        COLOR[darkgreen]='\e[32m'
        COLOR[blue]='\e[1;34m'
        COLOR[red]='\e[1;31m'
        COLOR[magenta]='\e[1;35m'
        COLOR[mutemagenta]='\e[35m'
        COLOR[yellow]='\e[1;33m'
        COLOR[muteyellow]='\e[33m'
    fi

    local userHost="\[${COLOR[darkgreen]}\]\u@\h"
    local sysname="\[${COLOR[mutemagenta]}\]$SYSNAME"
    local directory="\[${COLOR[muteyellow]}\]\w\[${COLOR[normal]}\]"
    local prompt="\n\$ "

    export PS1="$winTitle$userHost $sysname $directory$prompt"
}

__do_external_setup() {
    if [ -e /home/jpaugh/.nix-profile/etc/profile.d/nix.sh ]; then
        . /home/jpaugh/.nix-profile/etc/profile.d/nix.sh;
    fi # copied from .bash_profile


    # make less more friendly for non-text input files, see lesspipe(1)
    [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

    # Enable programmable completion features (you don't need to enable
    # this, if it's already enabled in /etc/bash.bashrc and /etc/profile
    # sources /etc/bash.bashrc).
    if ! shopt -oq posix; then
      if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
      elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
      fi
    fi
}


if _BASHRC_WAS_RUN 2>/dev/null; then
    :;
else
    alias _BASHRC_WAS_RUN=true
    # Since we allow re-sourcing the .bashrc to integrate new changes,
    # we need to protect some actions to ensure they only happen the
    # first time.

    __set_path
    __set_command_not_found_handle
    loadsysprofile
    __do_external_setup
fi

__set_shellopts
__set_vars
__set_aliases
__set_shell_prompt


# grep, backwards
grok () {
    local DIR=$1;shift
    grep -IR "$@" "$DIR"
}


# Reload .bashrc if it's been updated since the last time it ran
chk_bashrc_timestamp () {
    if [[ "$_BASHRC_TIMESTAMP" -lt "$(getFileTimestamp "$HOME/.bashrc")" ]]; then
        echo >&2 "Reloading .bashrc..."
        . ~/.bashrc
    fi
}
_BASHRC_TIMESTAMP=$(date +%s)

prompt_cmd () {
    err=$?
    if [ $err -gt 0 ]; then
        echo >&2 -e "Error code: ${COLOR[red]}$err${COLOR[normal]}"
    fi
    chk_bashrc_timestamp
}
PROMPT_COMMAND=prompt_cmd
