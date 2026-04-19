# tmux.sh — terminal multiplexer shortcuts

alias t="tmux"
alias tm="tmux_session_picker"
alias ta="tmux attach -t"
alias tl="tmux ls"
alias tk="tmux kill-session -t"
alias tn="tmux new -s"

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
