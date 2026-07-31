---
name: review
description: "/review [branch-name] — code review for current branch, or a different branch via temporary worktree."
---

# Code Review Skill

## Phase 1 — Setup

**Step 1.** Parse arguments. If a branch name was provided, store it as `TARGET_BRANCH`.

**Step 2.** Run `git branch --show-current` → store as `CURRENT_BRANCH`.
Compute `SAFE_BRANCH` now = reviewed branch name with `/` replaced by `-`
(`TARGET_BRANCH` if set, else `CURRENT_BRANCH`). The worktree path, the report
filename, and the cleanup path all use it.

**Step 3 — Worktree mode** (TARGET_BRANCH is set and differs from CURRENT_BRANCH):

```bash
# Fetch FIRST. Without this you review whatever the remote-tracking ref happened
# to be at the last fetch — silently stale code and line numbers that don't match
# what the reviewer sees in the MR.
git fetch origin "<TARGET_BRANCH>" main || echo "WARNING: fetch failed — reviewing possibly stale local refs"

grep -qxF '.worktrees/' .gitignore 2>/dev/null || echo '.worktrees/' >> .gitignore

git worktree remove ".worktrees/<SAFE_BRANCH>" --force 2>/dev/null || true
git worktree add --detach ".worktrees/<SAFE_BRANCH>" "origin/<TARGET_BRANCH>"
```

- `origin/<TARGET_BRANCH>`, not `<TARGET_BRANCH>` — pins the review to the remote
  tip instead of a stale local branch that happens to share the name.
- `--detach` — without it, `worktree add` creates a local branch that **survives
  `worktree remove --force`** and pollutes the branch list.
- If the fetch fails (offline), continue against the local refs, but keep the
  warning and repeat it in the Step 11 summary. Degrade, don't hard-fail.

Run all subsequent git commands from inside `.worktrees/<SAFE_BRANCH>/`.

**Step 3 — Normal mode** (no TARGET_BRANCH, or already on that branch):

Run all git commands from the repo root, after `git fetch origin main`.

**Both modes — always diff against `origin/main`, never local `main`.** Local `main` is routinely
behind, and the obvious repair (`git fetch origin main:main`) is *fatal* in the most
common case — reviewing someone else's branch while sitting on `main`:

```
fatal: refusing to fetch into branch 'refs/heads/main' checked out at '…'
```

so it cannot be relied on. `origin/main` is always current after the fetch above and
is correct regardless of what is checked out.

**Step 3b — Record provenance.** From inside the reviewed checkout:

```bash
REVIEWED_SHA=$(git rev-parse --short HEAD)
BASE_SHA=$(git merge-base origin/main HEAD | cut -c1-7)
```

Carry both into the report meta (Step 10) and the summary line so a stale report
is self-evident without re-running the review.

**Step 4.** Collect changed files and their diffs, against the `origin/main` freshly
fetched in Step 3:

```bash
git diff origin/main...HEAD --name-only          # → CHANGED_FILES
git diff origin/main...HEAD -- <file>            # for each file in CHANGED_FILES
```

Read the **full content** of every changed file, not just the diff.

**Step 4b — Build the changed-lines index.** Run once and keep it for Phase 2:

```bash
git diff origin/main...HEAD --unified=0 | awk '
  /^\+\+\+ b\// { f=substr($0,7); next }
  /^@@/ { split($3,h,","); s=substr(h[1],2)+0; n=(h[2]==""?1:h[2]+0);
          if (n>0) printf "%s:%d-%d\n", f, s, s+n-1 }'
```

→ `CHANGED_RANGES`, e.g. `src/efr/views/transaction_views.py:66-97`. At
`--unified=0` each hunk is one contiguous change and the `+c,d` header gives
exact **new-file** coordinates — no manual offset counting, so these ranges are
authoritative. Deletion-only hunks (`d=0`) are skipped; they anchor nothing.

**Line numbers (do this for every finding).** Both checks must pass before a
finding is recorded:

1. **Content check** — `sed -n '<line>p' <file>` (or
   `git show <REVIEWED_SHA>:<file> | sed -n '<line>p'`) must display the code the
   finding describes. Catches off-by-N.
2. **Membership check** — the cited line must fall inside a `CHANGED_RANGES` entry
   for that file. Catches anchoring on untouched code.

**When the root cause is outside the diff.** A finding whose mechanism lives in an
unchanged file is still valid — the MR newly exposes it — but it must be labelled,
never silently anchored on whichever changed line is nearest:

- Anchor `file`/`lines` on the changed line that **introduces the exposure**, so
  the membership check passes.
- Begin `explanation` with `Root cause: <file>:<line> (not in this diff).`
- Repeat that pointer in `mrComment`, so the reader isn't sent to a line that looks
  innocent.
- Do **not** auto-downgrade severity — a pre-existing root cause is not lower impact.

Worked example: "`document_type` forced to `INVOICE` on the Z-Bon" anchors on
`src/efr/actions/z_report_actions.py:42` (inside `CHANGED_RANGES` `1-43`), and its
explanation opens
`Root cause: src/efr/serializers/gateway/requests.py:538 (not in this diff).`

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
summary:     1–2 sentence what/why
explanation: detailed description
snippet:     { code, lang } — the relevant code excerpt + its language (e.g. "python"), or null
fix:         concrete suggestion
mrComment:   the copy/paste comment (see Phase 4 tone rules)
source:      manual
```

### Step 5b — CodeRabbit (run in parallel with Step 5a)

If any `.py` files are in `CHANGED_FILES`, run (from inside the reviewed
worktree/branch — CodeRabbit reviews the git diff itself, not file arguments):

```bash
coderabbit review --agent --base origin/main
```

`--base origin/main` for the same reason as Step 4 — verified accepted by the CLI,
which echoes `"baseBranch":"origin/main"` in its `review_context` event. Passing
plain `main` would silently review against a stale local base.

`--agent` emits newline-delimited JSON events to stdout. The stream ends with a
`{"type":"complete","findings":N,"reviewedFiles":[...]}` line; individual issues
arrive as their own JSON objects before it. Parse each finding object into the
same internal structure as Step 5a, with `source: coderabbit`. `findings: 0` +
no issue objects means CodeRabbit found nothing.

**Do NOT set a timeout. Wait however long it takes for CodeRabbit to finish.**
The CLI can take a few minutes. Run it in the background and poll its output
file rather than blocking a single foreground call.

If the CLI hangs at startup with no output (even `coderabbit --version` never
returns), it is broken/unauthenticated — reinstall
(`curl -fsSL https://cli.coderabbit.ai/install.sh | sh`) and
`coderabbit auth login`, then retry. `--prompt-only` and positional file
arguments are from an older CLI and no longer exist.

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

---

## Phase 5 — HTML report

After the terminal output above, **additionally** write a self-contained interactive
HTML report. This never replaces the terminal output — it is an extra artifact.

**Step 8.** Reuse `SAFE_BRANCH` from Step 2 — do not recompute it.

**Step 9.** Build a JSON array of the merged, sorted findings — one object per finding
using the exact field names: `title`, `severity` (`"HIGH"|"MEDIUM"|"LOW"`), `file`,
`lines`, `summary`, `explanation`, `snippet` (`{ "code": ..., "lang": ... }` or `null`),
`mrComment`, `source` (`"manual"|"coderabbit"|"both"`).

**Step 10.** Read the template `~/.claude/skills/review/template.html` and produce the
report by replacing its three placeholders:

- `<!--__TITLE__-->` (appears twice) → `Code review — <SAFE_BRANCH>`
- `<!--__META__-->` → `<SAFE_BRANCH> · <REVIEWED_SHA> vs <BASE_SHA> · N findings · <today's date>`
  (the SHAs from Step 3b — `main...HEAD` alone records nothing falsifiable, so a
  stale report can't be spotted later)
- `/*__FINDINGS__*/[]` → the JSON array from Step 9

```bash
mkdir -p ~/assistant/reviews
```

Write the result to `~/assistant/reviews/<SAFE_BRANCH>.html` (overwrite if it exists).

**Step 11.** Open it and print the path:

```bash
open ~/assistant/reviews/<SAFE_BRANCH>.html
```

Then print: `📄 HTML report: ~/assistant/reviews/<SAFE_BRANCH>.html`

---

## Constraints

- DO NOT apply any code changes or fixes
- DO NOT create any Linear tickets
- DO NOT produce any output before both Step 5a and Step 5b are fully complete
- The HTML report is **in addition to** the terminal output, never a replacement
- After the worktree cleanup (if applicable), output a brief summary line:
  `Review complete — N findings (X high, Y medium, Z low) · reviewed <REVIEWED_SHA> vs <BASE_SHA>`
  If a fetch failed in Step 3, append the stale-ref warning to this line.

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
