---
name: review
description: "/review [branch-name] — code review for current branch, or a different branch via temporary worktree."
---

# Code Review Skill

## Phase 1 — Setup

**Step 1.** Parse arguments. If a branch name was provided, store it as `TARGET_BRANCH`.

**Step 2.** Run `git branch --show-current` → store as `CURRENT_BRANCH`.

**Step 3 — Worktree mode** (TARGET_BRANCH is set and differs from CURRENT_BRANCH):

```bash
git worktree remove .worktrees/<TARGET_BRANCH> --force 2>/dev/null || true
git worktree add .worktrees/<TARGET_BRANCH> <TARGET_BRANCH>
```

Run all subsequent git commands from inside `.worktrees/<TARGET_BRANCH>/`.

**Step 3 — Normal mode** (no TARGET_BRANCH, or already on that branch):

Run all git commands from the repo root.

**Step 4.** Collect changed files and their diffs:

```bash
git diff main...HEAD --name-only          # → CHANGED_FILES
git diff main...HEAD -- <file>            # for each file in CHANGED_FILES
```

Read the **full content** of every changed file, not just the diff.

---

## Phase 2 — Run both reviews

**CRITICAL: Both Step 5a and Step 5b must fully complete before moving to Phase 3.
Do NOT return to the user, do NOT produce any output until both are done.**

### Step 5a — Manual review

With each file's full content and diff in context, perform a thorough manual review.
Check for (non-exhaustive):

- N+1 queries, missing `select_related` / `prefetch_related`
- Security issues: injection, XSS, broken auth, insecure defaults
- Logic errors and incorrect Django / DRF patterns
- Missing or wrong type annotations
- Dead code, unreachable branches
- Performance anti-patterns

For each issue found, record internally:

```
title:       short label for the issue
severity:    HIGH | MEDIUM | LOW
file:        path relative to repo root
lines:       start_line-end_line (or single line)
explanation: detailed description
fix:         concrete suggestion
source:      manual
```

### Step 5b — CodeRabbit (run in parallel with Step 5a)

If any `.py` files are in `CHANGED_FILES`, run:

```bash
coderabbit --prompt-only $(git diff main...HEAD --name-only | grep -E '\.py$')
```

**Do NOT set a timeout. Wait however long it takes for CodeRabbit to finish.**

Parse every finding from CodeRabbit's output into the same internal structure as
Step 5a, with `source: coderabbit`.

If no Python files changed, skip this step gracefully with a note in the final output.

---

## Phase 3 — Merge and deduplicate

**Step 6.** Combine all findings from Step 5a and Step 5b into one list.

**Deduplication rule:** Two findings are duplicates if they share the same file,
overlapping line range, and the same class of issue. When merging duplicates:

- Keep the most detailed explanation (usually the manual one)
- Append `*(flagged by both)*` to the title

**Sort order:** HIGH → MEDIUM → LOW. Within the same severity level, manual
findings come before CodeRabbit-only findings.

---

## Phase 4 — Output

**Step 7.** For every finding in the merged, sorted list, output **exactly** this
structure — no deviations, no extra sections, no missing sections:

```
### <title> [*(flagged by both)* if applicable] — <SEVERITY>
`<filepath>:<start_line>-<end_line>`

**Summary:** <1–2 sentences: what the issue is and why it matters.>

**Explanation:** <Thorough description of the problem. Include code snippets from
the diff or file to make it concrete. Explain the failure mode and its impact,
not just the symptom. Be specific about what line/pattern is wrong and why.>

**MR comment** *(copy/paste this):*

*<Friendly, colleague-tone comment — 2–4 sentences. Must be self-contained: file,
line, problem, and suggestion all in one. Lead with context, end with a concrete
next step. Use natural openers like "I noticed", "one thing that caught my eye",
"might be worth". Never sound like an automated tool or a linter.>*
```

**Tone rules for the MR comment:**
- Write as a direct, friendly colleague reviewing a teammate's PR
- Lead with what you observed, not with a verdict
- End with a concrete, actionable suggestion
- It's fine (encouraged) to use "I think", "might be worth", "one thing I noticed"
- The comment must be self-contained — someone reading only that comment should
  understand the issue and know what to do
- Render it in italics (`*...*`) so it visually pops in the output

**Good MR comment openers:**
- *"I noticed this queryset doesn't have a `select_related`…"*
- *"One thing that caught my eye — this method…"*
- *"Might be worth double-checking this condition, since…"*
- *"This looks like it could produce an extra query for each…"*

---

## Constraints

- DO NOT apply any code changes or fixes
- DO NOT create any Linear tickets
- DO NOT produce any output before both Step 5a and Step 5b are fully complete
- After the worktree cleanup (if applicable), output a brief summary line:
  `Review complete — N findings (X high, Y medium, Z low)`

---

## Reference output example

```
### Missing select_related on payment queryset — HIGH
`app/pcloud/provet/billing/utils.py:42-48`

**Summary:** The queryset fetches payments without pre-fetching payment methods,
causing one extra DB query per row every time the result set is iterated.

**Explanation:** In `get_due_sum_at_date`, the queryset is built as:

    payments = InvoicePayment.objects.filter(invoice=invoice)

Each time the caller accesses `payment.payment_method`, Django fires a separate
SELECT. On an EOD report covering hundreds of invoices this produces 200+ extra
queries. A single `.select_related('payment_method')` on the queryset eliminates
them entirely with no change to call-site code.

**MR comment** *(copy/paste this):*

*I noticed this queryset is missing a `select_related('payment_method')` — every
time we iterate and touch `payment.payment_method` we're firing an extra DB query.
On large EOD reports that could add up fast. I think adding it to the queryset on
line 42 would sort this out without any other changes needed.*
```
