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

if _BASHRC_WAS_RUN 2>/dev/null; then
    :;
else    # Stuff that only needs to run the first time we source .bashrc.
        # Useful to allow resourcing new changes
    OLD_PATH="$PATH"
    PATH="$HOME/bin"
    PATH+=":$HOME/node_modules/.bin"
    #PATH+="$HOME/.cabal/bin"
    #PATH+="$HOME/.gem/ruby/2.1.0/bin"
    #PATH+=":$HOME/build/gradle/gradle-2.3/bin"
    #PATH+=":$HOME/build/adt/adt-bundle-linux-x86-20140702/sdk/platform-tools"
    #PATH+=":$HOME/build/adt/adt-bundle-linux-x86-20140702/sdk/tools"
    #PATH+=":$HOME/build/adt/adt-bundle-linux-x86-20140702/sdk/build-tools/android-4.4W"
    #PATH+=":/usr/local/texlive/2013/bin/i386-linux"

    # The following line in case the OS default is not sane; Commented
    # out because I trust Ubuntu more than Gentoo in this regard
    #PATH+=":/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/usr/games/bin:/usr/local/games/bin"
    PATH+=":$OLD_PATH"
    export PATH

    alias _BASHRC_WAS_RUN=true

    # Set the DEFAULT_CMD to git, once
    # The DEFAULT_CMD is the command to run if the command line could
    # not be understood;
    DEFAULT_CMD=git

    # Update PATH for the Google Cloud SDK
    #source '/home/jpaugh/google-cloud-sdk/path.bash.inc'
    # Enable bash completion for gcloud
    #source '/home/jpaugh/google-cloud-sdk/completion.bash.inc'

#command_not_found_handle () {
#    eval '"$DEFAULT_CMD" $DEFAULT_CMD_PREFIX_ARGS "$@" $DEFAULT_CMD_POSTFIX_ARGS'
#}
export DEFAULT_CMD
fi

EDITOR=vim
CFLAGS="-O2 -fomit-frame-pointer -pipe"
CXXFLAGS="-O2 -fomit-frame-pointer -pipe"
MAKEOPTS="-j3"

# Only show the last 3 directories in the path
PROMPT_DIRTRIM=3

export EDITOR CFLAGS CXXFLAGS MAKEOPTS PROMPT_DIRTRIM

# For aliases that may need sudo to gain root priviledges
SUDO=sudo
SUDO+=" "
$AM_ROOT && unset SUDO;

alias g=git
alias pdf='gui evince'
alias myps='ps u -u $USER'
alias diff='colordiff -u'

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

# Tack on the end of a command line (`&& beepx`) to get status info when
# the command ends
# TODO: Learn how to do this with `notify-send`
beepx () {
    if [ $? -gt 0 ]; then
        beep
    else
        beep -f
    fi
}

# Last mod time of a file or files
get_file_timestamp () {
    ls -1 --time-style=+%s -l  "$@" | cut -f6 -d" "
}

# Make sure our version of the .bashrc file is up-to-date, or reload it.
chk_bashrc_timestamp () {
    if [[ "$_BASHRC_TIMESTAMP" -lt "$(get_file_timestamp "$HOME/.bashrc")" ]]; then
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

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
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
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

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
