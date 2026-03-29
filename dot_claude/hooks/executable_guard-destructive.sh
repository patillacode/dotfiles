#!/usr/bin/env bash
# guard-destructive: blocks dangerous bash commands before Claude executes them.
#
# Exit code protocol:
#   0  safe (or jq unavailable — fail open)
#   0  dangerous — outputs JSON deny decision via hookSpecificOutput

if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

[ -z "$CMD" ] && exit 0

# Strip quoted strings to avoid false positives on commit messages, echo args, etc.
# Collapse newlines first so multiline -m "..." commit messages are stripped correctly.
SAFE_CMD=$(echo "$CMD" | tr '\n' ' ' | sed "s/\"[^\"]*\"//g; s/'[^']*'//g")

MATCHED=""

# rm with any recursive flag (-r, -R, -rf, -fr, -Rf, --recursive)
# Must be a standalone rm command, not a git subcommand (git rm is recoverable)
if echo "$SAFE_CMD" | grep -qE '(^|[;&|]\s*)(sudo\s+)?rm\b' && echo "$SAFE_CMD" | grep -qE '(^|\s)-[a-zA-Z]*[rR]|\s--recursive'; then
  MATCHED="rm -r (recursive delete)"

# git reset --hard
elif echo "$SAFE_CMD" | grep -qE '\bgit\s+reset\s+--hard\b'; then
  MATCHED="git reset --hard"

# git clean with -f flag (force)
elif echo "$SAFE_CMD" | grep -qE '\bgit\s+clean\b' && echo "$SAFE_CMD" | grep -qE '(^|\s)-[a-zA-Z]*f'; then
  MATCHED="git clean -f (deletes untracked files)"

# SQL: DROP TABLE / DROP DATABASE / DROP SCHEMA
elif echo "$CMD" | grep -qiE '\bDROP\s+(TABLE|DATABASE|SCHEMA)\b'; then
  MATCHED="SQL DROP (irreversible data destruction)"

# SQL: TRUNCATE TABLE
elif echo "$CMD" | grep -qiE '\bTRUNCATE\s+TABLE\b'; then
  MATCHED="SQL TRUNCATE (data loss)"

# dd with if= (low-level disk write)
elif echo "$SAFE_CMD" | grep -qE '\bdd\b.*\bif='; then
  MATCHED="dd if= (low-level disk operation)"

# chmod -R 777
elif echo "$SAFE_CMD" | grep -qE '\bchmod\b' && echo "$SAFE_CMD" | grep -qE '(^|\s)-[a-zA-Z]*[Rr]' && echo "$SAFE_CMD" | grep -qE '\b777\b'; then
  MATCHED="chmod -R 777"

# mkfs (filesystem format)
elif echo "$SAFE_CMD" | grep -qE '\bmkfs\.'; then
  MATCHED="mkfs (filesystem format)"
fi

if [ -n "$MATCHED" ]; then
  PREVIEW=$(echo "$CMD" | head -c 200)
  jq -n \
    --arg reason "Dangerous command blocked [$MATCHED]:
  $PREVIEW

Run this manually in your terminal if intentional." \
    '{
      "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": $reason
      }
    }'
fi

exit 0
