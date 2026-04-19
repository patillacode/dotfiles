#!/usr/bin/env bash
SESSION="work"

tmux has-session -t "=$SESSION" 2>/dev/null && exec tmux attach-session -t "=$SESSION"

# ── Tab 1: assistant ──────────────────────────────────────────────
tmux new-session -d -s "$SESSION" -n "assistant" -c "/Users/gonz/assistant"
tmux send-keys -t "$SESSION:assistant.1" "c"
tmux split-window -h -t "$SESSION:assistant" -c "$HOME"

# ── Tab 2: provet ─────────────────────────────────────────────────
tmux new-window -t "$SESSION" -n "provet" -c "/Users/gonz/projects/nordhealth/provetcloud"
tmux send-keys -t "$SESSION:provet.1" "c"
tmux split-window -h -t "$SESSION:provet" -c "/Users/gonz/projects/nordhealth/provetcloud/app"
tmux send-keys -t "$SESSION:provet.2" "just app"
tmux split-window -v -t "$SESSION:provet.2" -c "/Users/gonz/projects/nordhealth/provetcloud"

# ── Tab 3: efsta ──────────────────────────────────────────────────
tmux new-window -t "$SESSION" -n "efsta" -c "/Users/gonz/projects/nordhealth/efsta-fiscalization"
tmux send-keys -t "$SESSION:efsta.1" "c"
tmux split-window -h -t "$SESSION:efsta" -c "/Users/gonz/projects/nordhealth/efsta-efr-app"
tmux send-keys -t "$SESSION:efsta.2" "docker compose up efsta-app-es"
tmux split-window -v -t "$SESSION:efsta.2" -c "/Users/gonz/projects/nordhealth/efsta-fiscalization"
tmux send-keys -t "$SESSION:efsta.3" "just run-dev && just run-local"
tmux split-window -v -t "$SESSION:efsta.3" -c "/Users/gonz/projects/nordhealth/efsta-fiscalization"

# ── Tab 4: reviews ────────────────────────────────────────────────
tmux new-window -t "$SESSION" -n "reviews" -c "/Users/gonz/projects/nordhealth/provetcloud"
tmux send-keys -t "$SESSION:reviews.1" "c"
tmux split-window -h -t "$SESSION:reviews" -c "/Users/gonz/projects/nordhealth/efsta-fiscalization"
tmux send-keys -t "$SESSION:reviews.2" "c"

# ── Tab 5: banana ─────────────────────────────────────────────────
tmux new-window -t "$SESSION" -n "banana" -c "$HOME"
tmux split-window -h -t "$SESSION:banana" -c "$HOME"

tmux select-window -t "$SESSION:assistant"
tmux select-pane -t "$SESSION:assistant.1"
tmux attach-session -t "$SESSION"
