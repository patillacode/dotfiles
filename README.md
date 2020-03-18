# patilla dotfiles

## Automatic dotfiles setup for unix-based systems 

### Why

The goal of this repo is to have an easy way of tracking, syncing and setting up some useful dotfiles such as `.bashrc` or `.vimrc`

### Quick notes
The styles, aliases, scripts, etc... used here are my personal choice and I use it to quickly have my prefered aliases and vim syntax color etc without having to rewrite them everytime I go into a new machine/system.

All the files in here are separated in _modules_ for an easier understanding and edition.

The key file in this repo could be `setup_dotfiles.sh` which creates soft-links (`ln -s`) to the files I want to quickly setup (`.bashrc`, `.vimrc`, etc)

Also, my `.bashrc` sources/imports a bunch of other files such as `.aliases` or `.prompt` and does several things for me.

The good thing is that you can easily edit any of these files and just use the automatic setup script.

Below is and explanation of the whole file organization, each file's purpose and explanation of the content for each file.


### The stuff
