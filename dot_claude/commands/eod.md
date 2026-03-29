Run my end-of-day wrap-up. This is an interactive process — go step by step, wait for my input at each step.

## Step 1: What got done today

1. Use Linear MCP to fetch issues I moved to Done/In Review today (updated_at = today)
2. Read ~/assistant/inbox.md and include any lines tagged [EOD] or [STANDUP] from today

Show me the combined list. Ask: "Anything I'm missing from this list?"

## Step 2: Decisions to log

First check ~/assistant/inbox.md for any [DECISION] tags from today and pre-populate the prompt with those.
Ask me: "Did you make any technical decisions today worth logging? (e.g. approach chosen, library picked, architecture tradeoff settled)"

If yes: collect the details interactively (what was decided, why, what was the alternative) and append to ~/assistant/decisions/log.md in this format:

```
## [DATE] — [Short title]

**Decision:** [what was decided]
**Context:** [why this came up]
**Alternatives considered:** [what else was on the table]
**Reasoning:** [why this was chosen]
```

If no: move on.

## Step 3: Captures for tomorrow

Ask me: "Anything you want to make sure you don't forget tomorrow?"

For each item I give you, append to ~/assistant/inbox.md:
```
- [TOMORROW] [DATE] — [item]
```

## Step 4: Wins

Look at the "done" list from Step 1. If anything stands out as a meaningful win (shipped a feature, fixed a hard bug, unblocked someone, got positive feedback), offer to append it to ~/assistant/brag.md:

```
## Week of [DATE]
- [win description]
```

Ask me: "Anything from today worth adding to the brag doc?" before appending.

## Step 5: Summary

Output a brief wrap-up:
---
**EOD Summary — [DATE]**
- Completed: [count] items
- Decisions logged: [yes/no]
- Inbox items for tomorrow: [count]
- Brag doc updated: [yes/no]

See you tomorrow.
---
