# yazi — terminal file manager

# y: launch yazi and cd to wherever you exit
y() {
    local tmp
    tmp="$(mktemp)"
    yazi "$@" --cwd-file="$tmp"
    if [ -s "$tmp" ]; then
        cd "$(cat "$tmp")" || return
    fi
    rm -f "$tmp"
}
