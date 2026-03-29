Capture a quick note to ~/assistant/inbox.md.

Usage examples:
  /note Created QA ticket for VFC-649
  /note Reviewed !13685, left comments [STANDUP]
  /note Follow up with Pekka about MR review [TOMORROW]
  /note Decided to use signed URLs for S3 objects [DECISION]
  /note   ← no argument: infers from conversation

Steps:

**If an argument was provided:**
1. Take the text passed as the argument.
2. If no tag is present, default to [EOD].
3. Append to ~/assistant/inbox.md in this format:
   `- [TAG] YYYY-MM-DD — <note text>`
4. Reply with ONE line only: "Noted." — nothing else.

**If NO argument was provided:**
1. Review the current conversation for noteworthy items:
   - Decisions made or conclusions reached
   - Work completed or shipped
   - Things to follow up on
   - Blockers or open questions
   - Anything standup-worthy
2. Extract 1–3 concise bullet points (skip noise — only what's worth surfacing in /morning, /daily-status, or /eod).
3. Assign the most appropriate tag per item:
   - [EOD] — completed work, summaries
   - [DECISION] — architectural or technical choices made
   - [TOMORROW] — follow-ups, carry-overs
   - [BLOCKER] — blockers or unresolved issues
   - [STANDUP] — items worth mentioning in standup
4. Append each to ~/assistant/inbox.md:
   `- [TAG] YYYY-MM-DD — <inferred note>`
5. Reply listing what was noted, one line per item. Example:
   Noted:
   - [DECISION] decided to use X approach
   - [TOMORROW] follow up on Y

Valid tags and what they do:
- [EOD] — surfaces during /eod step 1 (today's work summary)
- [STANDUP] — surfaces during /daily-status as a "done" item
- [TOMORROW] — surfaces during /morning as a carry-over
- [DECISION] — surfaces during /eod step 2 (decisions to log)
- [BLOCKER] — surfaces in both /daily-status and /morning as urgent
