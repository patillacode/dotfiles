#!/bin/bash
# Claude Code — Tokyo Night no-bg 3-line status line v6
# Re-exec with bash 4+ if running under bash 3.2 (macOS system bash lacks \uXXXX support)
if [[ "${BASH_VERSINFO[0]:-0}" -lt 4 ]]; then
  for _b in "$(command -v bash 2>/dev/null)" /opt/homebrew/bin/bash /usr/local/bin/bash; do
    [[ -x "$_b" && "$_b" != /bin/bash ]] && exec "$_b" "$0" "$@"
  done
fi

input=$(cat)

# ── Parse (real Claude Code 2.1.87 field names) ─────────────────
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty' 2>/dev/null)
[[ -z "$cwd" || "$cwd" == "null" ]] && cwd="$PWD"

# Model display_name is already clean in real JSON ("Sonnet 4.6")
model=$(echo "$input" | jq -r '.model.display_name // empty' 2>/dev/null)

# Session ID lives at top level
session_id=$(echo "$input" | jq -r '.session_id // .session.id // empty' 2>/dev/null)

# Context window — all real field names
ctx_used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)
ctx_total=$(echo "$input"    | jq -r '.context_window.context_window_size // empty' 2>/dev/null)
ctx_used=$(echo "$input" | jq -r '
  ((.context_window.current_usage.input_tokens              // 0) +
   (.context_window.current_usage.output_tokens             // 0) +
   (.context_window.current_usage.cache_creation_input_tokens // 0) +
   (.context_window.current_usage.cache_read_input_tokens   // 0))
  | if . == 0 then empty else . end' 2>/dev/null)

# Rate limits (the "session window" — 5-hour and 7-day)
rl5_pct=$(echo "$input"    | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null)
rl5_reset=$(echo "$input"  | jq -r '.rate_limits.five_hour.resets_at // empty' 2>/dev/null)
rl7_pct=$(echo "$input"    | jq -r '.rate_limits.seven_day.used_percentage // empty' 2>/dev/null)
rl7_reset=$(echo "$input"  | jq -r '.rate_limits.seven_day.resets_at // empty' 2>/dev/null)

for v in model session_id ctx_used_pct ctx_total ctx_used rl5_pct rl5_reset rl7_pct rl7_reset; do
  [[ "${!v}" == "null" ]] && eval "$v="
done

R=$'\e[0m'
bold=$'\e[1m'

# ── Tokyo Night foreground-only palette ─────────────────────────
C_DIR=117    # cyan        #7dcfff
C_GIT=141    # purple      #bb9af7
C_MDL=179    # amber       #e0af68
C_ELP=111    # blue        #7aa2f7
C_DIV=238    # very dim    (thin › separators only)
C_LBL=246    # readable gray (CTX / 5H / 7D labels)
C_RST=244    # soft gray   (↺ reset countdowns)
C_VNV=150    # sage green  #9ece6a
C_NUM=255    # bright white  (token counts)
C_SEP=240    # medium gray   (the "/" between token counts)
C_CRT=210    # coral         (critical bar color, git behind)
C_ORG=214    # orange        (bar warning 50-85%, git untracked dots)

SEP=$'\ue0b1'

I_DIR=$'\uf07b'   I_HOME=$'\uf015'
I_GIT=$'\ue702'   I_STH=$'\uf01c'
I_MDL=$'\uf4bc'   I_ELP=$'\uf253'
I_CTX=$'\uf0c3'   I_5H=$'\uf017'   I_7D=$'\uf073'
I_PY=$'\ue235'

# ── Helpers ──────────────────────────────────────────────────────
fmt_k() {
  local n=$1
  (( n >= 1000000 )) && { awk "BEGIN{printf \"%.1fM\",$n/1000000}"; return; }
  (( n >= 1000 ))    && { awk "BEGIN{printf \"%.0fk\",$n/1000}"; return; }
  printf "%d" "$n"
}

bar_color() {
  local p=$1
  (( p > 85  )) && echo $C_CRT && return   # coral
  (( p >= 50 )) && echo $C_ORG  && return   # orange
  echo $C_VNV                              # mint
}

make_bar() {
  local pct=$1 fg=$2 bar="" i
  local filled=$(( pct / 10 ))
  local empty=$(( 10 - filled ))
  for (( i=0; i<filled; i++ )); do bar+="\e[38;5;${fg}m▓"; done
  for (( i=0; i<empty;  i++ )); do bar+="\e[38;5;${C_DIV}m░"; done
  printf "%s\e[0m" "$bar"
}

fmt_countdown() {
  local ts=$1
  [[ -z "$ts" ]] && return
  local now delta h m
  now=$(date +%s)
  delta=$(( ts - now ))
  (( delta <= 0 )) && printf "soon" && return
  h=$(( delta / 3600 ))
  m=$(( (delta % 3600) / 60 ))
  if   (( h >= 24 )); then printf "%dd %dh" $(( h/24 )) $(( h%24 ))
  elif (( h > 0  )); then printf "%dh %dm" "$h" "$m"
  else                    printf "%dm" "$m"; fi
}

# ── Directory ────────────────────────────────────────────────────
# HOME may not be set in Claude Code's sandbox; match /Users/X or /home/X directly
display_dir=$(printf '%s' "$cwd" | sed -E 's|^/Users/[^/]+|~|; s|^/home/[^/]+|~|')
dir_icon=$I_DIR
[[ "$display_dir" == "~" ]] && dir_icon=$I_HOME

# ── Git ──────────────────────────────────────────────────────────
git_branch="" git_dots="" git_stash="" git_remote=""
if git -C "$cwd" -c core.useBuiltinFSMonitor=false rev-parse --git-dir &>/dev/null; then
  git_branch=$(git -C "$cwd" -c core.useBuiltinFSMonitor=false \
    symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  prc=$(git -C "$cwd" -c core.useBuiltinFSMonitor=false \
    status --porcelain --no-optional-locks 2>/dev/null)
  printf '%s' "$prc" | grep -q '^??' \
    && git_dots+="\e[38;5;${C_ORG}m ●\e[38;5;${C_GIT}m"   # untracked: orange
  printf '%s' "$prc" | grep -q '^ M\|^MM' \
    && git_dots+="\e[38;5;${C_DIR}m ●\e[38;5;${C_GIT}m"   # modified:  cyan
  printf '%s' "$prc" | grep -qE '^[MADRCU]' \
    && git_dots+="\e[38;5;${C_VNV}m ●\e[38;5;${C_GIT}m"   # staged:    green
  stash_n=$(git -C "$cwd" stash list 2>/dev/null | wc -l | tr -d ' ')
  (( stash_n > 0 )) && git_stash=" \e[38;5;${C_MDL}m${I_STH} ${stash_n}\e[38;5;${C_GIT}m"
  if upstream=$(git -C "$cwd" rev-parse --abbrev-ref "@{u}" 2>/dev/null); then
    ahead=$(git  -C "$cwd" rev-list --count "${upstream}..HEAD" 2>/dev/null || echo 0)
    behind=$(git -C "$cwd" rev-list --count "HEAD..${upstream}" 2>/dev/null || echo 0)
    (( ahead  > 0 )) && git_remote+=" \e[38;5;${C_VNV}m↑${ahead}\e[38;5;${C_GIT}m"
    (( behind > 0 )) && git_remote+=" \e[38;5;${C_CRT}m↓${behind}\e[38;5;${C_GIT}m"
  fi
fi

# ── Session elapsed ──────────────────────────────────────────────
elapsed_str=""
if [[ -n "$session_id" ]]; then
  ts_file="/tmp/csl-${session_id}"
  [[ ! -f "$ts_file" ]] && date +%s > "$ts_file"
  start=$(cat "$ts_file" 2>/dev/null)
  d=$(( $(date +%s) - start ))
  h=$(( d/3600 )); m=$(( (d%3600)/60 )); s=$(( d%60 ))
  if   (( h > 0 )); then elapsed_str="${h}h ${m}m"
  elif (( m > 0 )); then elapsed_str="${m}m ${s}s"
  else                   elapsed_str="${s}s"; fi
fi

# ── Venv ─────────────────────────────────────────────────────────
venv_str=""
if [[ -n "$VIRTUAL_ENV" ]]; then
  py_ver=$(python --version 2>&1 | awk '{split($2,a,"."); print a[1]"."a[2]}')
  venv_str="  \e[38;5;${C_DIV}m${SEP}\e[0m  \e[38;5;${C_VNV}m${I_PY} ${py_ver}\e[0m"
fi

# ── Line 1: session — model  ›  elapsed  ›  venv ────────────────
L1="${bold}\e[38;5;${C_MDL}m${I_MDL}  ${model:-Claude}\e[0m"
if [[ -n "$elapsed_str" ]]; then
  L1+="  \e[38;5;${C_DIV}m${SEP}\e[0m  \e[38;5;${C_ELP}m${I_ELP}  ${elapsed_str}\e[0m"
fi
L1+="${venv_str}"

# ── Line 2: workspace — dir  ›  git ─────────────────────────────
L2="${bold}\e[38;5;${C_DIR}m${dir_icon}  ${display_dir}\e[0m"
if [[ -n "$git_branch" ]]; then
  L2+="  \e[38;5;${C_DIV}m${SEP}\e[0m  \e[38;5;${C_GIT}m${I_GIT}  ${git_branch}${git_dots}${git_remote}${git_stash}\e[0m"
fi

# ── Line 3: context window ───────────────────────────────────────
ctx_pct=${ctx_used_pct:-0}
ctx_fg=$(bar_color "$ctx_pct")
ctx_bar=$(make_bar "$ctx_pct" "$ctx_fg")
if [[ -n "$ctx_used" && "$ctx_used" != "0" && -n "$ctx_total" && "$ctx_total" != "0" ]]; then
  u=$(fmt_k "$ctx_used"); t=$(fmt_k "$ctx_total")
  ctx_info="  \e[38;5;${ctx_fg}m${ctx_pct}%${R}  ${bold}\e[38;5;${C_NUM}m${u}${R}  \e[38;5;${C_SEP}m/${R}  ${bold}\e[38;5;${C_NUM}m${t}${R}"
elif [[ -n "$ctx_total" && "$ctx_total" != "0" ]]; then
  used_tok=$(awk "BEGIN{printf \"%.0f\", ${ctx_total} * ${ctx_pct} / 100}")
  u=$(fmt_k "$used_tok"); t=$(fmt_k "$ctx_total")
  ctx_info="  \e[38;5;${ctx_fg}m${ctx_pct}%${R}  ${bold}\e[38;5;${C_NUM}m${u}${R}  \e[38;5;${C_SEP}m/${R}  ${bold}\e[38;5;${C_NUM}m${t}${R}"
else
  ctx_info="  \e[38;5;${ctx_fg}m${ctx_pct}%${R}"
fi
L3="\e[38;5;${C_LBL}mCTX\e[0m  ${ctx_bar}${ctx_info}"

# ── Line 4: 5-hour rate limit ────────────────────────────────────
# ── Line 5: 7-day rate limit ────────────────────────────────────
if [[ -n "$rl5_pct" || -n "$rl7_pct" ]]; then
  # Round floats — jq can emit e.g. 28.000000000000004; $((...)) breaks on floats
  p5=$(awk "BEGIN{printf \"%.0f\", ${rl5_pct:-0}+0}")
  p7=$(awk "BEGIN{printf \"%.0f\", ${rl7_pct:-0}+0}")

  # 5-hour window
  fg5=$(bar_color "$p5")
  bar5=$(make_bar "$p5" "$fg5")
  L4="\e[38;5;${C_LBL}m 5H\e[0m  ${bar5}  \e[38;5;${fg5}m${p5}%\e[0m"
  cd5=$(fmt_countdown "$rl5_reset")
  [[ -n "$cd5" ]] && L4+="  \e[38;5;${C_RST}m↺ ${cd5}\e[0m"

  # 7-day window
  fg7=$(bar_color "$p7")
  bar7=$(make_bar "$p7" "$fg7")
  L5="\e[38;5;${C_LBL}m 7D\e[0m  ${bar7}  \e[38;5;${fg7}m${p7}%\e[0m"
  cd7=$(fmt_countdown "$rl7_reset")
  [[ -n "$cd7" ]] && L5+="  \e[38;5;${C_RST}m↺ ${cd7}\e[0m"
else
  L4="\e[38;5;${C_LBL}m 5H  —\e[0m"
  L5="\e[38;5;${C_LBL}m 7D  —\e[0m"
fi

printf "%b\n%b\n%b\n%b\n%b" "$L1" "$L2" "$L3" "$L4" "$L5"
