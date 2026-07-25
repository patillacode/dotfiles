# herdr — terminal workspace manager for AI coding agents
alias h='herdr'
alias ht='herdr --remote totoro'
alias hs='herdr_machine_picker'

herdr_machine_picker() {
  local machine
  machine=$(printf "bars\ntotoro\nnordhealth\n" \
    | fzf --prompt="herdr > " --height=40%)
  [[ -z "$machine" ]] && return
  # ~/.ssh/config supplies the user for each host, so bare names are enough.
  if [[ "$machine" == "$(hostname -s)" ]]; then
    herdr
  else
    herdr --remote "$machine"
  fi
}
