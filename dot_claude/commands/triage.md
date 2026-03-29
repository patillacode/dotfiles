Process my inbox. Read ~/assistant/inbox.md and triage each item one by one.

For each item in inbox.md:

1. Show me the item
2. Ask what to do with it — use AskUserQuestion with these options:
   - "Create Linear ticket" — collect title + description, create via Linear MCP, remove from inbox
   - "Save to Notion" — collect page title, create Notion page, remove from inbox
   - "Log as decision" — collect context, append to ~/assistant/decisions/log.md, remove from inbox
   - "Keep for later" — leave it in inbox, move to bottom
   - "Done / delete" — remove from inbox

After all items are processed:
- Rewrite inbox.md with only the "kept" items remaining
- Report: "Triaged X items. Y created in Linear, Z saved to Notion, N deleted, M kept."

If inbox.md is empty, say so and exit.

Rules:
- Don't process more than 10 items without checking if I want to continue
- Don't create Linear tickets with placeholder text — always confirm the title before creating
- Don't modify inbox.md until all triage decisions are made (do it in one write at the end)
