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
