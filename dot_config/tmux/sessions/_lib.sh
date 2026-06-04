# _lib.sh — shared helpers for tmux session scripts.
#
# Resurrect owns session state across reboots. The smart-open logic below makes
# every entry point (session scripts, the `ts` picker, the `tw` alias) defer to
# a saved resurrect snapshot instead of rebuilding — so a restart never clobbers
# the live tabs. A session is only built from scratch when no snapshot exists.

_resurrect_last() {
    printf '%s\n' "${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect/last"
}

# Windows saved for a session in the resurrect snapshot (0 if none). Window lines
# are tab-separated; field 1 is "window", field 2 is the session name.
_resurrect_window_count() {
    local session="$1" file
    file="$(_resurrect_last)"
    [[ -e "$file" ]] || { echo 0; return; }
    awk -F'\t' -v s="$session" '$1=="window" && $2==s {c++} END{print c+0}' "$file"
}

_tmux_attach() {
    local session="$1"
    if [[ -n "$TMUX" ]]; then
        tmux switch-client -t "=$session"
    else
        tmux attach-session -t "=$session"
    fi
}

# Smart open <session> <builder-fn>:
#   running          → attach
#   has snapshot      → start server, wait for the restore to reach the saved
#                       window count, then attach (partial restore still beats a
#                       clobbering rebuild)
#   no snapshot       → run the builder, then attach
tmux_smart_open() {
    local session="$1" builder="$2"

    if tmux has-session -t "=$session" 2>/dev/null; then
        _tmux_attach "$session"
        return
    fi

    local want
    want="$(_resurrect_window_count "$session")"

    if (( want > 0 )); then
        tmux start-server
        local deadline=$(( SECONDS + 15 )) have
        while (( SECONDS < deadline )); do
            if tmux has-session -t "=$session" 2>/dev/null; then
                have="$(tmux list-windows -t "=$session" 2>/dev/null | wc -l | tr -d ' ')"
                (( have >= want )) && break
            fi
            sleep 0.2
        done
        if tmux has-session -t "=$session" 2>/dev/null; then
            _tmux_attach "$session"
            return
        fi
        # Snapshot existed but nothing restored — fall through to a fresh build.
    fi

    "$builder"
    tmux has-session -t "=$session" 2>/dev/null && _tmux_attach "$session"
}
