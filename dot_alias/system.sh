# system.sh — system-level aliases and utilities

# Color codes for use in other aliases/scripts
RED="\033[0;31m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
NC="\033[0m"

get_port() {
    netstat -vanp tcp | grep $1
    lsof -i tcp:$1
}

alias brc="source $HOME/.bashrc && echo -e '\n${YELLOW}󰚩${CYAN} .bashrc reloaded ${YELLOW}󰚩${NC}'"
alias brew-cask-list-ordered="$HOME/projects/bash/brew_cask_list.sh"
alias brew-list-ordered="$HOME/projects/bash/brew_list.sh"
alias cat="bat"
alias df="duf"
alias dots="dotfiles"
alias dt="dotfiles"
alias f="fzf --preview \"bat --color=always {}\" --bind 'enter:become(nvim {}),ctrl-o:become(zed {})'"
alias fff="fastfetch"
alias j="just"
alias l="eza -aalg --git --icons auto"
alias ll="eza -aalg --git --icons auto"
alias llf='eza -aalgd --git --icons auto "$PWD"/*'
alias lt="eza -aal -snew --git --icons auto"
alias l2="eza -lTg -L=2 --git --icons auto"
alias l3="eza -lTg -L=3 --git --icons auto"
alias nv="nvim"
alias p="python"
alias port="get_port"
alias ss="macosrec"
alias top="btop"
alias v="nvim"
alias venv="python -m venv venv"
alias zrc="source $HOME/.zshrc && echo -e '\n${YELLOW}󰚩${CYAN} .zshrc reloaded ${YELLOW}󰚩${NC}'"

mkcd() { mkdir -p "$1" && cd "$1"; }
