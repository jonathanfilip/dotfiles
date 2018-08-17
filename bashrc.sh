#!/usr/bin/env bash


# Setup: {{{1 ================================================================

export PLATFORM=$(uname)
if [[ "$PLATFORM" == 'Linux' ]]; then
    PLATFORM='linux'
elif [[ "$PLATFORM" == 'Darwin' ]]; then
    PLATFORM='osx'
else
    PLATFORM='unknown'
fi


# Options: {{{1 ==============================================================

shopt -s cdspell # Correct minor cd spelling errors
shopt -s dotglob # Allow dot files to be returned in path expansion
shopt -s checkwinsize # Check size after each command
set -o vi # Make the prompt like vi

if [[ $- == *i* ]]
then
    stty ixoff -ixon # Don't let CTRL S/Q work
fi


# Environment: {{{1 ==========================================================

export EDITOR=vim
export VISUAL=vim
export IGNOREEOF=1 # press ctrl+D twice to exit
export PROMPT_COMMAND=bash_prompt # Set up the command line
export GREP_OPTIONS="--exclude=\*.svn\*"
export HISTCONTROL=ignoreboth
if [[ "$PLATFORM" == "linux" ]]; then
    #export TERM="xterm-256color"
    export LOAD_CMD="cut -d ' ' -f 1-3 /proc/loadavg"
elif [[ "$PLATFORM" == "osx" ]]; then
    export LOAD_CMD="uptime | cut -d ' ' -f 10-"
fi


# Aliases: {{{1 ==============================================================

# ls Commands
if [[ $PLATFORM == 'linux' ]]; then
    alias ls='ls --color=auto'
elif [[ $PLATFORM == 'osx' ]]; then
    alias ls='ls -G'
fi
alias lt='ls -ltr'
alias lta='ls -ltrA'
alias ll='ls -l'
alias lla='ls -lA'

# Navigation
alias up="cd ..; "
alias ..="cd ..; "

# Program shortcuts
alias vi=vim
alias l="less"

# Other Commands
alias psme='ps -Af | grep ${USER}'
alias dfme='df -h | egrep "${USER}|Filesystem"'
alias xterm='xterm -ls'

alias ipy='ipython -colors Linux'
alias grep='grep --color=auto'
alias ack='ack --color --color-match=red --color-filename=green --color-lineno=blue'
alias ag='ag --color --color-match=31 --color-path=32 --color-line-number=34'


# Functions: {{{1 ============================================================

function bash_prompt() {
    local NONE="\[\033[0m\]"

    local K="\[\033[0;30m\]"    # black
    local R="\[\033[0;31m\]"    # red
    local G="\[\033[0;32m\]"    # green
    local Y="\[\033[0;33m\]"    # yellow
    local B="\[\033[0;34m\]"    # blue
    local M="\[\033[0;35m\]"    # magenta
    local C="\[\033[0;36m\]"    # cyan
    local W="\[\033[0;37m\]"    # white

    # background colors
    local BGK="\[\033[40m\]"    # black
    local BGR="\[\033[41m\]"    # red
    local BGG="\[\033[42m\]"    # green
    local BGY="\[\033[43m\]"    # yellow
    local BGB="\[\033[44m\]"    # blue
    local BGM="\[\033[45m\]"    # magenta
    local BGC="\[\033[46m\]"    # cyan
    local BGW="\[\033[47m\]"    # white


    if [ "${SHELL_TAG}" ]; then
        PS1="\n${NONE}[${NONE}${Y}${SHELL_TAG}${NONE}${NONE}]${NONE} "
        PS1="${PS1}${NONE}[${NONE}${C}\u@\h${NONE}${NONE}]${NONE} "
        PS1="${PS1}${G}${PWD}${NONE}\n> "
    else
        PS1="\n${NONE}[${NONE}${C}${USER}@${HOSTNAME}${NONE}${NONE}]${NONE} ${G}${PWD}${NONE}\n> "
    fi
}

function set_title {
    echo -ne "\033]0;$@\007"
}

function dirdiff {
    vim -c "DirDiff $1 $2"
}

function lscolors {
    local header="no:global default;fi:normal file;di:directory;"
    header="${header}ln:symbolic link;pi:named pipe;so:socket;"
    header="${header}do:door;bd:block device;cd:character device;"
    header="${header}or:orphan symlink;mi:missing file;su:set uid;"
    header="${header}sg:set gid;tw:sticky other writable;"
    header="${header}ow:other writable;st:sticky;ex:executable;"
    eval $(echo ${header}|sed -e 's/:/="/g; s/\;/"\n/g')
    {
    IFS=:
    for i in $LS_COLORS
    do
        echo -e "\e[${i#*=}m$( x=${i%=*}; [ "${!x}" ] && echo \
            "${!x}" || echo "$x" )\e[m"
    done
    }
}

function pygrep {
    grep -r -n --include=*.py "$@" *
}

function csgrep {
    grep -r -n --include=*.{cs,xaml} "$@" *
}

function cgrep {
    grep -r -n --include=*.{cpp,h,H,hpp,c,C} "$@" *
}

function pyag {
    ag --python "$@"
}

function csag {
    ag --cssharp "$@"
}

function cppag {
    ag --cpp "$@"
}

function print_colors() {
    T='gYw'   # The test text
    echo -e "\n                 40m     41m     42m     43m\
    44m     45m     46m     47m";
    for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m'\
            '  32m' '1;32m' '  33m' '1;33m' '  34m' '1;34m'\
            '  35m' '1;35m' '  36m' '1;36m' '  37m' '1;37m';
        do FG=${FGs// /}
        echo -en " $FGs \033[$FG  $T  "
        for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
            do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
        done
        echo;
    done
    echo
}

function tmux_compress {
    tmux lsw |
    awk -F: '/^[0-9]+/ { if ($1 != ++i) print "tmux move-window -s " $1 " -t " i }' |
    sh
}

function tmuxn {
    tmux new -s "$1"
}

function tmux_attach {
    tmux attach -t "$1"
}
alias ta=tmux_attach

declare -A projects
projects["clear"]="unset SHELL_TAG"

function _proj() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local choices=${!projects[@]}
    COMPREPLY=( $(compgen -W "${choices/clear/}" -- $cur) )
}

function proj() {
    if [[ ${projects[$1]} ]]
    then
        eval ${projects[$1]}
    else
        echo "No project named '$1'."
    fi
}
complete -F _proj proj

declare -A directories

function _chd() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local choices=${!directories[@]}
    COMPREPLY=( $(compgen -W "${choices}" -- $cur) )
}

function chd() {
    if [[ ${directories[$1]} ]]
    then
        eval ${directories[$1]}
    else
        echo "No directory shortcut named '$1'."
    fi
}
complete -F _chd chd

function add_dir_to_variable() {
    varname=$1
    eval argvar=\$$varname
    #dir=${2%/}
    dir=$2
    if [[ -z "$argvar" ]]
    then
        eval export $varname=$dir
        return
    fi

    if [[ ! -d "$dir" ]]
    then
        echo "add_dir_to_variable: directory '$dir' does not exist."
        return
    fi

    if [[ ":$argvar:" != *":$dir:"* ]]
    then
        if [[ -n "$3" ]] && [[ "$3" == "1" ]]
        then
            eval export $varname=$dir:\$$varname
        else
            eval export $varname=\$$varname:$dir
        fi
    fi

}

function add_to_path() {
    for var in $@
    do
        add_dir_to_variable "PATH" $var
    done
}

function prepend_to_path() {
    for var in $@
    do
        add_dir_to_variable "PATH" $var 1
    done
}

function add_to_ld_library_path() {
    for var in $@
    do
        add_dir_to_variable "LD_LIBRARY_PATH" $var
    done
}

function prepend_to_ld_library_path() {
    for var in $@
    do
        add_dir_to_variable "LD_LIBRARY_PATH" $var 1
    done
}

function add_to_python_path() {
    for var in $@
    do
        add_dir_to_variable "PYTHON_PATH" $var
    done
}

function prepend_to_python_path() {
    for var in $@
    do
        add_dir_to_variable "PYTHON_PATH" $var 1
    done
}

function vimdocx() {
    pandoc -f docx -t markdown $1 | vim -
}



# Local: {{{1 ================================================================

if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi

