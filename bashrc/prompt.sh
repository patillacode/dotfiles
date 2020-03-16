#!/bin/bash
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
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

# recover the current git branch
get_git_branch() {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

if [ "$color_prompt" = yes ]; then
    default_ps="${debian_chroot:+($debian_chroot)}"
    datetime="\033[01;35m\]\$(date +%k:%M)\033[00m\]"
    user_host="\[\033[0;33m\]\u@\h\[\033[00m\]:"
    path="\[\033[0;32m\]\w\[\033[00m\]"
    git_branch="[$(get_git_branch)]"
    close="\033[01;32m\]\$\[\033[00m\]"  
else
    default_ps='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    user_host="\u@\h:"
    path="\w"
    git_branch="[$(get_git_branch)]"
    close="\$"
fi

unset color_prompt force_color_prompt

if [[ $VIRTUAL_ENV != "" ]]
then
    venv="$(basename ${VIRTUAL_ENV}) "
else
    venv=''
fi

export PS1="$venv$datetime $user_host$path$git_branch$close " 

