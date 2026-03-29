# git.sh — git shortcuts

alias ga="git add"
alias gaa="git add --all"
alias gap="git add --patch"
alias gau="git add -u"
alias gb="git branch"
alias gc="git commit -m"
alias gcb="git checkout -b"
alias gcl="git clone"
alias gco="git checkout"
alias gd="git diff"
alias gl="git log --pretty=oneline --abbrev-commit"
# alias gl="git log"
alias gll="git log --graph --pretty=format:'%C(red)%h %C(white) %an %ar%C(auto) %D%n%s%n'"
alias gla="git log --all --graph --pretty=format:'%C(red)%h %C(white) %an %ar%C(auto) %D%n%s%n'"
alias gp="git push"
alias gs="git status"
alias gu="git pull"

alias wip='git add --all && git commit -m "wip"'
alias clean-git-branches="$HOME/projects/bash/git/clean_git_branches.sh"

# check git config
alias git-config-global="git config --list --global"
alias git-config-local="git config --list --local"
