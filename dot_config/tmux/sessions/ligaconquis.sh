#!/usr/bin/env bash
SESSION="ligaconquis"
source "$HOME/.config/tmux/sessions/_lib.sh"

build_ligaconquis() {
    # Left pane (full height): claude code
    tmux new-session -d -s "$SESSION" -c "$HOME/projects/ligaconquis"
    tmux send-keys -t "$SESSION" "c" Enter

    # Right column (3 stacked shells)
    tmux split-window -h -t "$SESSION" -c "$HOME/projects/ligaconquis"
    tmux split-window -v -t "$SESSION" -c "$HOME/projects/ligaconquis"
    tmux split-window -v -t "$SESSION" -c "$HOME/projects/ligaconquis"

    tmux select-pane -t "$SESSION:1.1"
}

tmux_smart_open "$SESSION" build_ligaconquis
