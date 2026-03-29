# docker.sh — container management

alias dcls='docker ps --all --format "table {{.ID}}\\t{{.Image}}\\t{{.Status}}\\t{{.Names}}\\t{{.Ports}}"'
alias dils='docker image ls --format "table {{.ID}}\\t{{.Tag}}\\t{{.Repository}}\\t{{.Size}}\\t{{.CreatedSince}}"'
