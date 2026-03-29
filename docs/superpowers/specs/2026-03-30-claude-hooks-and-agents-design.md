# Design: Destructive Command Guard Hook

**Date:** 2026-03-30
**Status:** Approved

---

## Context

Claude Code can execute arbitrary Bash commands. A single misfire — `rm -rf` on the wrong path, `git reset --hard` mid-session — can cause irreversible damage. This hook adds a safety net: any command matching a known-dangerous pattern is blocked before execution, with a clear message to Claude and the user.

---

## What it does

A `PreToolUse` shell script that intercepts dangerous Bash commands. When matched, exits 2 (block) with a descriptive message. Claude reports the block and asks the user how to proceed — no silent failures, no accidents.

---

## Dangerous patterns

| Pattern | Risk |
|---------|------|
| `rm -rf`, `rm -fr`, `rm -r` | Recursive file deletion |
| `git reset --hard` | Irreversible working tree destruction |
| `git clean -f`, `git clean -fd` | Untracked file deletion |
| `DROP TABLE`, `DROP DATABASE` | Database destruction |
| `TRUNCATE` (SQL context) | Data loss |
| `dd if=` | Low-level disk overwrite |
| `chmod -R 777` | Permission destruction |
| `mkfs.` | Filesystem formatting |

---

## Implementation

- **File:** `dot_claude/hooks/executable_guard-destructive.sh`
- **Hook type:** `command`
- **Event:** `PreToolUse`, matcher `Bash`
- **Exit codes:** 0 = allow, 2 = block
- **Registration:** Added to `settings.json.tmpl` as a second entry in the existing `PreToolUse` hooks array. RTK runs first (rewrites), guard runs second (safety check).

### Block message format

```
Blocked: dangerous command detected.
  Command: rm -rf ./tmp
  Pattern: rm -rf

Run this manually in your terminal if intentional.
```

Claude sees this, reports it to the user, and suggests safer alternatives.

### Non-goals

- Does not block `rm` on single files (too noisy)
- Does not try to rewrite or fix the command
- No LLM evaluation — pure shell, zero latency

---

## File Paths

| File | Action |
|------|--------|
| `dot_claude/hooks/executable_guard-destructive.sh` | New file |
| `dot_claude/settings.json.tmpl` | Add guard to PreToolUse hooks array |

---

## Verification

```bash
# After chezmoi apply, in a Claude session:
# Ask Claude to run: rm -rf /tmp/test-dir
# Expected: blocked with message, Claude asks how to proceed

chezmoi apply
ls ~/.claude/hooks/   # should show both rtk-rewrite.sh and guard-destructive.sh
```
