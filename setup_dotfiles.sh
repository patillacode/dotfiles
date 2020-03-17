#!/bin/bash
# script to set custom dotfiles
CYAN="\033[1;36m"
RED="\033[0;31m"
GREEN="\033[0;32m"
GREEN_BOLD="\033[1;32m"
NOCOLOR="\033[0m"


echo -e "\n${GREEN}################################################${NOCOLOR}"

echo -e "${GREEN}Setting your dotfiles...${NOCOLOR}"
echo -e "${GREEN}################################################${NOCOLOR}"

# path vars
dotfiles_dir="$HOME/dotfiles"
backups_dir="$dotfiles_dir/backups"

echo -e "\n${CYAN}This script will create soft-links from $dotfiles_dir to your home folder ($HOME)${NOCOLOR}\n"

echo -e "${GREEN}################################################${NOCOLOR}"
echo -e "${GREEN}Backing up...${NOCOLOR}"
echo -e "${GREEN}################################################${NOCOLOR}"

# create backups dir if it doesn't exist
if [[ ! -d $backups_dir ]]; then
    mkdir $backups_dir
    echo -e "${CYAN}Created $backups_dir ...${NOCOLOR}"
    backups_dir_exists=0
else
    echo -e "${RED}The backups directory already exists - adding datetime to filenames to avoid rewriting...${NOCOLOR}"
    backups_dir_exists=1
fi

# backup originals
declare -a dotfiles=(".bashrc" ".vim" ".vimrc")
for dotfile in "${dotfiles[@]}"
do
    echo -e "${CYAN}Running backup for '$dotfile' ...${NOCOLOR}"
    if [[ -f "$HOME/$dotfile" ]]; then
        if [[ $backups_dir_exists -eq 1 ]]; then
            cp "$HOME/$dotfile" "$backups_dir/${dotfile}_$(date  +%Y%m%d_%k%M)"
            #echo "cp $HOME/$dotfile $backups_dir/${dotfile}_$(date +%Y%m%d_%k%M)"
        else
            cp "$HOME/$dotfile" "$backups_dir/$dotfile"
            #echo "cp $HOME/$dotfile $backups_dir/$dotfile"
        fi
    elif [[ -d "$HOME/$dotfile" ]]; then
        if [[ $backups_dir_exists -eq 1 ]]; then
           cp -Lr "$HOME/$dotfile" "$backups_dir/${dotfile}_$(date  +%Y%m%d_%k%M)"
           #echo "cp -Lr $HOME/$dotfile $backups_dir/${dotfile}_$(date +%Y%m%d_%k%M)"
        else
            cp -Lr "$HOME/$dotfile" "$backups_dir/$dotfile"
            #echo "cp -Lr $HOME/$dotfile $backups_dir/$dotfile"
         fi
    fi
    rm -rf "$HOME/$dotfile"
    #echo "rm -rf $HOME/$dotfile"
done

echo -e "${GREEN}Back up is now done!${NOCOLOR}"
echo -e "${GREEN}################################################${NOCOLOR}"

echo -e "\n${CYAN}Setting .bashrc ...${NOCOLOR}"

# set .bashrc
bashrc_dir="$dotfiles_dir/bashrc"
bashrc_file="$bashrc_dir/.bashrc"

if [[ -f $bashrc_file ]]; then
    ln -s $bashrc_file "$HOME/.bashrc"
    ls -al $HOME/.bashrc
fi

echo -e "${CYAN}################################################${NOCOLOR}"

echo -e "\n${CYAN}Setting .vim/ & .vimrc ...${NOCOLOR}"
# set .vim & .vimrc
vim_dir="$dotfiles_dir/vim"
vim_folder="$vim_dir/.vim"
vimrc_file="$vim_dir/.vimrc"

if [[ -d $vim_folder ]]; then
    ln -s $vim_folder "$HOME/.vim"
    #echo "ln -s $vim_folder $HOME/.vim"
    ls -al $HOME/.vim
fi

if [[ -f $vimrc_file ]]; then
    ln -s $vimrc_file "$HOME/.vimrc"
    ls -al $HOME/.vimrc
fi

echo -e "${CYAN}################################################${NOCOLOR}"

echo -e "\n${GREEN_BOLD}All dotfiles have been set, try to run 'brc' to reload the new .bashrc${NOCOLOR}\n"
