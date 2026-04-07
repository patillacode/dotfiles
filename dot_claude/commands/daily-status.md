Generate my standup talking points for today's 2-minute live standup.

Steps:
1. Using glab CLI from ~/projects/nordhealth/provetcloud, get MRs that actually need my review:
   a. Run `glab mr list --reviewer=@me -F json` to get MR iids
   b. For each MR, call `glab api "projects/:id/merge_requests/<iid>/reviewers"` and find the entry where `user.username == "gonz-nh"`
   c. Only include MRs where my reviewer `state` is `"unreviewed"` — skip `"approved"` and `"requested_changes"` (those are waiting on the author, not me)
   If any glab command fails, skip this step silently.
2. Use the Linear MCP to query my assigned issues:
   - Issues with status "In Progress" or "In Review"
   - Issues with status "Done" or "Completed" that were updated in the last 2 days
3. Read ~/assistant/inbox.md and surface any lines tagged [STANDUP], [BLOCKER], or [EOD] from today — include these in the relevant sections
3. Output ONLY the following format — no preamble, no explanation, just the bullets (omit any section that has nothing to show):

---
**Done since last standup:**
- [bullet per completed/moved-to-review item]

**Working on today:**
- [bullet per in-progress item, most important first]

**Blockers / needs input:**
- [bullet per blocker, or "None" if clear]

**MRs waiting for my review:**
- [MR title + author + link, or omit section if none / glab unavailable]
---

Keep each bullet to one line. Use the ticket ID in brackets where relevant, e.g. "[VFC-123] Fixed X".
If Linear has no data, say so and suggest checking manually.
Do not add commentary after the bullets.
