# utils.sh — project shortcuts and utility aliases

alias icons="sudo $HOME/projects/icon-replacer/replace_icons.sh -f -q"
alias ttt="cd $HOME/projects/topstopstops"
alias ttf="cd $HOME/projects/topstopstops-front"

# cup (totoro service manager)
alias cup-check='cd $HOME/services/cup && just check && cd -'
alias cup-notify='cd $HOME/services/cup && just notify'
alias cup='cup-check'
# cup-update: interactive TUI for selectively updating outdated images (see ~/.local/bin/cup-update)
