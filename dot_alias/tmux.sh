# tmux.sh — terminal multiplexer shortcuts

alias t="tmux"
alias ts="tmux_session_picker"
alias tt="bash ~/.config/tmux/sessions/totoro.sh"
alias tw="bash ~/.config/tmux/sessions/nordhealth.sh"
alias ta="tmux_attach_session"
alias tl="tmux ls"
alias tk="tmux_kill_session"
alias tn="tmux new -s"

alias tch="tmux_cheatsheet"

tmux_cheatsheet() {
  glow ~/.config/tmux/cheatsheet.md
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
  local resurrect_last="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect/last"
  if ! tmux list-sessions >/dev/null 2>&1 && [[ -e "$resurrect_last" ]]; then
    tmux start-server
    local deadline=$(( SECONDS + 5 ))
    while (( SECONDS < deadline )); do
      tmux list-sessions >/dev/null 2>&1 && break
      sleep 0.1
    done
  fi
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
