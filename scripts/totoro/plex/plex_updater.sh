#!/bin/bash

export TERM="${TERM-xterm}" # set $TERM to xterm if not set
tput setaf 1 && tput bold
echo "Stopping the Plex server"
sudo service plexmediaserver stop

tput sgr0 && tput setaf 4
echo "Moving to /tmp/ ..."
cd /tmp/

echo "Downloading latest version of Plex server..."
curl -s "https://plex.tv/downloads/details/1?build=linux-ubuntu-x86_64&channel=16&distro=ubuntu" | grep -Po '(?<=url=\")(\S+)(?=\")' | xargs wget > /dev/null 2>&1

file_name=$(curl -s "https://plex.tv/downloads/details/1?build=linux-ubuntu-x86_64&channel=16&distro=ubuntu" | grep -Po '(?<=fileName=\")(\S+)(?=\")')

tput setaf 6
echo -ne "\nInstalling new image: "
tput sgr0 && tput bold
echo -e "$file_name\n"
tput sgr0 && tput setaf 6
sudo dpkg -i $file_name

tput setaf 1 && tput bold
echo -e "\nRestarting Plex server..."
sudo service plexmediaserver start
tput op

tput setaf 5 && tput sgr0
echo -n "Checking new server is running..."
systemctl is-active --quiet plexmediaserver && echo -e " \e[32m\e[1mRunning!\n"

