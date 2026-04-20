#!/usr/bin/env bash
SESSION="ligaconquis"

if tmux has-session -t "=$SESSION" 2>/dev/null; then
    if [[ -n "$TMUX" ]]; then
        exec tmux switch-client -t "=$SESSION"
    else
        exec tmux attach-session -t "=$SESSION"
    fi
fi

# Left pane (full height): claude code
tmux new-session -d -s "$SESSION" -c "$HOME/projects/ligaconquis"
tmux send-keys -t "$SESSION" "c" Enter

# Right column (3 stacked shells)
tmux split-window -h -t "$SESSION" -c "$HOME/projects/ligaconquis"
tmux split-window -v -t "$SESSION" -c "$HOME/projects/ligaconquis"
tmux split-window -v -t "$SESSION" -c "$HOME/projects/ligaconquis"

tmux select-pane -t "$SESSION:1.1"
if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "=$SESSION"
else
    tmux attach-session -t "=$SESSION"
fi
