# tmux.sh — terminal multiplexer shortcuts

alias t="tmux"
alias ts="tmux_session_picker"
alias tt="bash ~/.config/tmux/sessions/totoro.sh"
alias tw="bash ~/.config/tmux/sessions/nordhealth.sh"
alias twork="bash ~/.config/tmux/sessions/nordhealth.sh"
alias ta="tmux_attach_session"
alias tl="tmux ls"
alias tk="tmux_kill_session"
alias tn="tmux new -s"

alias tch="tmux_cheatsheet"

tmux_cheatsheet() {
  glow - <<'EOF'
# tmux cheatsheet · prefix: Ctrl+Space

## Sessions
| Command | Action |
|---------|--------|
| `tt` | connect to totoro session |
| `tw` / `twork` | connect to nordhealth session |
| `ts` | fuzzy pick / launch session |
| `tl` | list sessions |
| `tn <name>` | new named session |
| `tk` | kill session (fuzzy pick) |
| `prefix d` | detach (session keeps running) |
| `ta` | attach to session (fuzzy pick) |

## Windows
| Key | Action |
|-----|--------|
| `prefix c` | new window (same path) |
| `Alt+1`–`9` | switch to window (no prefix) |
| `Alt+n` / `Alt+p` | next / previous window |
| `Alt+Shift+←` / `Alt+Shift+→` | previous / next window |
| `Alt+[` / `Alt+]` | previous / next window |
| `prefix ,` | rename window |
| `prefix &` | kill window |

## Panes
| Key | Action |
|-----|--------|
| `prefix \` | split right |
| `prefix -` | split down |
| `Alt+hjkl` | navigate panes (no prefix) |
| `Alt+↑` / `Alt+↓` | cycle panes by index |
| `prefix ←→↑↓` | navigate panes |
| `prefix z` | zoom pane fullscreen (toggle) |
| `prefix x` | kill pane |

## Other
| Key | Action |
|-----|--------|
| `prefix r` | reload config |
| `prefix [` | scroll mode (q to exit) |
EOF
}

tmux_attach_session() {
  local session
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null \
    | fzf --prompt="attach > " --height=40%)
  [[ -z "$session" ]] && return
  [[ -n "$TMUX" ]] && tmux switch-client -t "=$session" || tmux attach-session -t "=$session"
}

tmux_kill_session() {
  local session
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null \
    | fzf --prompt="kill session > " --height=40%)
  [[ -z "$session" ]] && return
  tmux kill-session -t "=$session"
}

tmux_session_picker() {
  local sessions_dir="$HOME/.config/tmux/sessions"
  local running defined all
  running=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)
  defined=$(ls "$sessions_dir"/*.sh 2>/dev/null | xargs -I{} basename {} .sh)
  all=$(printf "%s\n%s" "$running" "$defined" | sort -u | grep -v '^$' \
    | fzf --prompt="session > " --height=40%)
  [[ -z "$all" ]] && return
  if tmux has-session -t "=$all" 2>/dev/null; then
    [[ -n "$TMUX" ]] && tmux switch-client -t "=$all" || tmux attach-session -t "=$all"
  elif [[ -f "$sessions_dir/$all.sh" ]]; then
    bash "$sessions_dir/$all.sh"
  else
    tmux new-session -s "$all"
  fi
}
