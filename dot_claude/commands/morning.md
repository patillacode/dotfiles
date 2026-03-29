Generate my start-of-day briefing.

Steps:
1. Read ~/assistant/inbox.md — surface any items dated yesterday or tagged [TOMORROW] or [URGENT]
2. Use the Slack MCP to read the last 10 messages from #vet-finance-core-team-internal (channel ID: C056QG6CEPN). Surface anything that: mentions me, needs a response, is a blocker, or is an incident/hot potato.
3. Use Linear MCP to fetch my assigned issues:
   - Overdue issues (past due date)
   - Issues in current sprint assigned to me
   - Issues I own that are blocked
3. Check the day of week:
   - Monday: note it's sprint start, suggest reviewing sprint goals
   - Friday: note it's end of week, suggest wrapping open items and writing EOW update
4. Use Google Calendar MCP to fetch today's events (timeMin = today 00:00, timeMax = today 23:59, timeZone = Europe/Madrid). List only events with a real start time (skip all-day blocks unless they're notable). For each event show: time, title, number of attendees if > 1.
5. Output this format:

---
**Good morning. Here's your day.** *(today's date, day of week)*

**From inbox (carry-overs):**
- [items from yesterday / flagged items, or "Inbox clear"]

**Team channel (#vet-finance-core-team-internal):**
- [anything that mentions me, needs a response, or is an incident — or "Nothing urgent"]

**Today's calendar:**
- [HH:MM — Event name (N attendees) — or "No meetings today"]

**Linear — focus for today:**
- [top 1-3 issues to work on, most urgent first]

**Watch / overdue:**
- [overdue or at-risk items, or "Nothing overdue"]

**Today's suggestion:**
[One sentence: what to tackle first and why, factoring in meetings]
---

Be brief. I don't need ticket descriptions restated — just the ID, title, and any urgency signal.
