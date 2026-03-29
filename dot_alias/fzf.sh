# fzf.sh — fzf-powered interactive helpers

# ─── git ────────────────────────────────────────────────────────

# switch branch
fbr() {
    local branch
    branch=$(git branch --all --sort=-committerdate | grep -v HEAD |
        fzf --height 40% --reverse) &&
    git checkout "$(echo "$branch" | sed 's/.* //' | sed 's#remotes/[^/]*/##')"
}

# browse git log, preview diffs
flog() {
    git log --oneline --color=always |
        fzf --ansi --reverse \
            --preview 'git show --color=always {1}' \
            --bind 'enter:execute(git show --color=always {1} | less -R)'
}

# stage files interactively
fga() {
    local files
    files=$(git diff --name-only | fzf -m --reverse --preview 'git diff --color=always {}') &&
    echo "$files" | xargs git add
}

# ─── docker ─────────────────────────────────────────────────────

# exec into a running container
dexec() {
    local cid
    cid=$(docker ps --format '{{.ID}}\t{{.Names}}\t{{.Image}}' |
        fzf --height 40% --reverse | awk '{print $1}') &&
    docker exec -it "$cid" "${1:-sh}"
}

# stop containers
dstop() {
    local cids
    cids=$(docker ps --format '{{.ID}}\t{{.Names}}\t{{.Image}}' |
        fzf -m --height 40% --reverse | awk '{print $1}')
    [ -n "$cids" ] && echo "$cids" | xargs docker stop
}

# tail container logs
dlogs() {
    local cid
    cid=$(docker ps --format '{{.ID}}\t{{.Names}}\t{{.Image}}' |
        fzf --height 40% --reverse | awk '{print $1}') &&
    docker logs -f "$cid"
}

# remove images
drmi() {
    local images
    images=$(docker images --format '{{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.Size}}' |
        fzf -m --height 40% --reverse | awk '{print $1}')
    [ -n "$images" ] && echo "$images" | xargs docker rmi
}

# ─── system ─────────────────────────────────────────────────────

# kill processes
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m --height 40% --reverse | awk '{print $2}')
    [ -n "$pid" ] && echo "$pid" | xargs kill -"${1:-9}"
}

# cd into subdirectories
fcd() {
    local dir
    dir=$(find "${1:-.}" -type d 2>/dev/null |
        fzf --height 40% --reverse --preview 'ls -la {}') &&
    cd "$dir"
}

# ssh into a host from ~/.ssh/config
fssh() {
    local host
    host=$(grep -E '^Host ' ~/.ssh/config 2>/dev/null | grep -v '\*' | awk '{print $2}' |
        fzf --height 40% --reverse) &&
    ssh "$host"
}

# browse and print env var values
fenv() {
    local var
    var=$(env | sort | fzf --height 40% --reverse) &&
    echo "$var" | cut -d= -f2-
}

# edit config files
fedit() {
    local file
    file=$(find ~/.config ~/.alias -type f 2>/dev/null |
        fzf --height 40% --reverse --preview 'head -50 {}') &&
    "${EDITOR:-vim}" "$file"
}
