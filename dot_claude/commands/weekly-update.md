Generate a draft weekly update I can share with my team.

This is an interactive command — collect context before drafting.

## Step 1: Gather data (run in parallel)

1. **Linear:** fetch issues I completed or moved to "In Review" this week (updatedAt >= last Monday)
2. **Linear:** fetch issues still in progress assigned to me
3. **Google Calendar:** fetch this week's events (Monday to today) — identify any notable meetings (planning, retros, design reviews, 1:1s with notable outcomes)
4. **Read** ~/assistant/brag.md — look for entries from this week
5. **Read** ~/assistant/decisions/log.md — look for entries from this week

## Step 2: Ask me two questions

Ask both at once:

1. "Anything notable that happened this week that won't show up in Linear? (e.g. helped someone, unblocked a team, had an important conversation)"
2. "Any blockers or risks to flag for next week?"

Wait for my answers before drafting.

## Step 3: Draft the update

Use my writing style from ~/assistant/context/style.md.

Format:

---
**Week of [Monday date] — Weekly Update**

**Shipped / In Review:**
- [bullet per completed or in-review ticket — ticket ID + one line on what it does/why it matters]

**In Progress:**
- [bullet per active ticket — where it's at, what's next]

**Other notable things:**
- [anything from step 2 that's worth mentioning]

**Next week:**
- [top 1-2 focus items based on what's in progress + anything Riaan flagged in the team channel]

**Blockers / needs input:**
- [from step 2, or "None"]
---

## Step 4: Offer to publish

After showing the draft, ask:
"Want me to post this to Notion or copy it for Slack?"
- If Notion: create a new Notion page titled "Weekly Update — [week of date]"
- If Slack: format it for pasting (no markdown headers, just clean text with line breaks)
