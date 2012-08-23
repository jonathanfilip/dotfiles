#!/usr/bin/env bash


# ============================================================================
# Setup {{{
    platform=$(uname)
    if [[ "$platform" == 'Linux' ]]; then
        platform='linux'
    elif [[ "$platform" == 'Darwin' ]]; then
        platform='osx'
    else
        platform='unknown'
    fi
# }}}
# ============================================================================


# ============================================================================
# Options {{{
    shopt -s cdspell # Correct minor cd spelling errors
    shopt -s dotglob # Allow dot files to be returned in path expansion
    shopt -s checkwinsize # Check size after each command
    #set -o vi # Make the prompt like vi
    stty ixoff -ixon # Don't let CTRL S/Q work
# }}}
# ============================================================================


# ============================================================================
# Environment Settings {{{
    export EDITOR=vim
    export VISUAL=vim
    export IGNOREEOF=1 # press ctrl+D twice to exit
    export PROMPT_COMMAND=bash_prompt # Set up the command line
    export GREP_OPTIONS="--exclude=\*.svn\*"
    export HISTCONTROL=ignoreboth
    export LUCIUS_STYLE=light
    if [[ "$platform" == "linux" ]]; then
        #export TERM="xterm-256color"
        export LOAD_CMD="cut -d ' ' -f 1-3 /proc/loadavg"
    elif [[ "$platform" == "osx" ]]; then
        export LOAD_CMD="uptime | cut -d ' ' -f 10-"
    fi
# }}}
# ============================================================================


# ============================================================================
# Aliases {{{
    # ls Commands
    if [[ $platform == 'linux' ]]; then
        alias ls='ls --color=auto'
    elif [[ $platform == 'osx' ]]; then
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
# }}}
# ============================================================================


# ============================================================================
# Functions {{{
    # Bash Prompt {{{
        function bash_prompt()
        {
            local NONE="\[\033[0m\]"

            local K="\[\033[0;30m\]"    # black
            local R="\[\033[0;31m\]"    # red
            local G="\[\033[0;32m\]"    # green
            local Y="\[\033[0;33m\]"    # yellow
            local B="\[\033[0;34m\]"    # blue
            local M="\[\033[0;35m\]"    # magenta
            local C="\[\033[0;36m\]"    # cyan
            local W="\[\033[0;37m\]"    # white

            # bolded colors
            #local EMK="\[\033[1;30m\]"    # black
            #local EMR="\[\033[1;31m\]"    # red
            #local EMG="\[\033[1;32m\]"    # green
            #local EMY="\[\033[1;33m\]"    # yellow
            #local EMB="\[\033[1;34m\]"    # blue
            #local EMM="\[\033[1;35m\]"    # magenta
            #local EMC="\[\033[1;36m\]"    # cyan
            #local EMW="\[\033[1;37m\]"    # white

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

            #    echo -ne "\033]0;${HOSTNAME}\007"
            #if [ "${TITLE}" ]; then
            #    echo -ne "\033]0;${TITLE} - ${HOSTNAME}\007"
            #else
            #    echo -ne "\033]0;${HOSTNAME}\007"
            #fi
        }
    # }}}

    function set_title {
        echo -ne "\033]0;$@\007"
        #export TITLE="$@"
    }

    # Display ls Colors {{{
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
    # }}}


    # Custom greps {{{
        function pygrep {
            grep -r -n --include=*.py $@ *
        }

        function csgrep {
            grep -r -n --include=*.cs $@ *
        }
    # }}}


    # Vim colorshemes {{{
        function lucius_dark {
            export LUCIUS_STYLE=dark
        }

        function lucius_light {
            export LUCIUS_STYLE=light
        }
    # }}}


    # Print Terminal Colors {{{
        function print_colors()
        {
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
    # }}}


    # SVN Commands {{{
        function svn_modified {
            svn status $@ | egrep -v "^\?"
        }
    # }}}

    # TMUX {{{
        function tmux_compress {
            tmux lsw |
            awk -F: '/^[0-9]+/ { if ($1 != ++i) print "tmux move-window -s " $1 " -t " i }' |
            sh
        }

        function tmux_rename {
            local JON=4
            #tmux rename-window "${SHELL_TAG}"
        }

        function tmux_title {
            tmux rename-session "$1"
        }

        function tmux_list {
            tmux list-sessions
        }
        alias tl=tmux_list

        function tmuxn {
            tmux new -s "$1"
        }

        function tmux_attach {
            tmux attach -t "$1"
        }
        alias ta=tmux_attach
    # }}}

# }}}
# ============================================================================


# ============================================================================
# Local Settings {{{
if [ -f ~/.bashrc_local ]; then
    source ~/.bashrc_local
fi
# }}}
# ============================================================================


umask 0002

