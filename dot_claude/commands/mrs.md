Retrieve all open MR links relevant to me.

Run both commands from ~/projects/nordhealth/provetcloud:

1. `glab mr list --author=@me` — MRs I authored
2. `glab mr list --reviewer=@me` — MRs waiting for my review

Output ONLY this format, no preamble:

---
**My MRs:**
- !<iid> — <title> — <url>
[or "None"]

**Waiting for my review:**
- !<iid> — <title> — <url>
[or "None"]
---

If glab fails, say so in one line and suggest running `glab auth login`.
