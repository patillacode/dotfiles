Print a concise reference of all my daily driver commands. No preamble, just output this exactly:

---
**Daily Driver — Command Reference**

**Daily loop:**
`/morning`          Start-of-day briefing — inbox + team channel + calendar + Linear priorities
`/daily-status`     Standup talking points — done / working on / blockers / MRs to review
`/eod`              End-of-day wrap — what got done, decisions, captures, wins (interactive)
`/weekly-update`    Draft weekly update from Linear + brag doc (interactive, publish to Notion/Slack)

**Capture:**
`/note <text>`      Quick capture to inbox. Tags: [EOD] [STANDUP] [TOMORROW] [DECISION] [BLOCKER]
                    Default tag is [EOD] if none specified.
`/triage`           Process inbox.md — route items to Linear, Notion, decisions log, or delete

**Tickets & code:**
`/work-on-ticket`   Research a Linear ticket and produce an implementation plan
`/review`           Code review for current branch or a named branch
`/resolve-code-review`  Pull MR review comments and create a resolution plan
`/mrs`              List all my open MRs + MRs waiting for my review (with links)

**Context files** (edit these to keep Claude up to date):
`~/assistant/context/projects.md`   Current focus, active projects
`~/assistant/context/team.md`       Team members, who owns what
`~/assistant/context/style.md`      Your writing style (used when drafting messages)
`~/assistant/decisions/log.md`      Technical decision log
`~/assistant/brag.md`               Weekly wins
`~/assistant/inbox.md`              Capture pad

**Tip:** Run `/morning` from ~/assistant/ each day to start with full context.
---
