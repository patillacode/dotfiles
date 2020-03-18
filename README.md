# patilla dotfiles

## Automatic dotfiles setup for unix-based systems 

### Why

The goal of this repo is to have an easy way of tracking, syncing and setting up some useful dotfiles such as `.bashrc` or `.vimrc`

### Install

```bash
# go to your home folder
$ cd ~

# clone this repo
$ git clone git@github.com:patillacode/dotfiles.git

# go into the repo folder
$ cd dotfiles

# run the setup script
$ ./setup_dotfiles.sh

```

You should see an output similar to this:

[!](img/setup_ouput.png)

### Quick notes
The styles, aliases, scripts, etc... used here are my personal choice and I use them to quickly have my prefered _aliases_ and vim _syntax color_ etc without having to rewrite them everytime I go into a new machine/system.

The key file in this repo could be `setup_dotfiles.sh` which creates soft-links (`ln -s`) to the files I want to quickly setup (`.bashrc`, `.vimrc`, etc)

Below is and explanation of the whole file organization, each file's purpose and explanation of the content for each file.


### Folders and Files
