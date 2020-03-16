#!/bin/bash

# script to set custom dotfiles
dotfiles_dir="$HOME/dotfiles"

# set .bashrc
bashrc_dir="$dotfiles_dir/bashrc"
bashrc_file="$bashrc_dir/.bashrc"

echo $bashrc_dir
echo $bashrc_file

if [ -f $bashrc_file ]; then
    ln -s $bashrc_file "${HOME}/.bashrc"
fi

# set .vim & .vimrc
vim_dir="$dotfiles_dir/vim"
vim_folder="$vim_dir/.vim"
vimrc_file="$vim_dir/.vimrc"

if [ -d $vim_folder ]; then
    ln -s $vim_folder "${HOME}/.vim"
fi

if [ -f $vimrc_file ]; then
    ln -s $vimrc_file "${HOME}/.vimrc"
fi

