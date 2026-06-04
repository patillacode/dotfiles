#!/usr/bin/env bash
SESSION="topstopstops"
source "$HOME/.config/tmux/sessions/_lib.sh"

build_topstopstops() {
    # Left pane (full height): claude code
    tmux new-session -d -s "$SESSION" -n "$SESSION" -c "$HOME/projects/topstopstops"
    tmux send-keys -t "$SESSION" "c" Enter

    # Right column (3 stacked panes)
    tmux split-window -h -t "$SESSION" -c "$HOME/projects/topstopstops-front"
    tmux send-keys -t "$SESSION" "just run" Enter

    tmux split-window -v -t "$SESSION" -c "$HOME/projects/topstopstops"
    tmux send-keys -t "$SESSION" "just run" Enter

    tmux split-window -v -t "$SESSION" -c "$HOME/projects/topstopstops"

    tmux select-pane -t "$SESSION:1.1"
}

tmux_smart_open "$SESSION" build_topstopstops
