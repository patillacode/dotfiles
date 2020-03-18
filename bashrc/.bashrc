# ~/.bashrc: executed by bash(1) for non-login shells.

# since this .bashrc is configured in steps we set this
# as the source of truth where we keep all the model-like files
export DOTFILES_DIR="$HOME/dotfiles"

# If not running interactively, don't do anything
[[ $- == *i* ]] || return

### history
# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# source all custom generic bashrc related dotfiles: .functions, .aliases, .exports, .prompt, etc
bashrc_dir="$DOTFILES_DIR/bashrc"

for dotfile in "$bashrc_dir"/.*
do
    [[ -f "$dotfile" ]] && [[ ! $(basename $dotfile) =~ ^(.|..|.bashrc)$ ]] && source "$dotfile"  #&& echo "sourcing $dotfile"
done

# source specific .bashrc related dotfiles for the current host if available: .functions, .aliases, .exports, etc
if [[ -d "$bashrc_dir/$HOSTNAME" ]]
then
    for dotfile in "$bashrc_dir/$HOSTNAME/".*
    do
	    [[ -f $dotfile ]] && [[ ! $(basename $dotfile) =~ ^(.|..)$ ]] && source $dotfile
    done
fi

[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash

bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'
