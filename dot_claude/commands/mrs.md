---
allowed-tools: ["Bash(glab api:*)"]
---

Retrieve all open MR links relevant to me across multiple repos.

Use `--repo` flag for all commands. Do NOT `cd`. Do NOT use bash loops, python, or compound commands — only simple `glab` commands that are individually auto-approved.

Repos to check:
- `nordhealth/projects/veterinary/provet-cloud/provetcloud` (ProvetCloud)
- `nordhealth/projects/veterinary/integrations/kraken-tentacles/efsta-fiscalization` (EFSTA tentacle)

**Step 1 — My authored MRs (run in parallel):**
```
glab mr list --author=@me --repo nordhealth/projects/veterinary/provet-cloud/provetcloud
glab mr list --author=@me --repo nordhealth/projects/veterinary/integrations/kraken-tentacles/efsta-fiscalization
```

**Step 2 — Reviewer MRs (run in parallel):**
```
glab mr list --reviewer=@me --repo nordhealth/projects/veterinary/provet-cloud/provetcloud -F json
glab mr list --reviewer=@me --repo nordhealth/projects/veterinary/integrations/kraken-tentacles/efsta-fiscalization -F json
```
From the JSON, extract each MR's `iid`, `title`, `author.name`, `web_url`, and `source_branch`.

**Step 3 — Reviewer state (one call per MR, run in parallel where possible):**
For each MR iid from step 2, call:
```
glab api "projects/<url-encoded-repo>/merge_requests/<iid>/reviewers"
```
URL-encoded repo paths:
- ProvetCloud: `nordhealth%2Fprojects%2Fveterinary%2Fprovet-cloud%2Fprovetcloud`
- EFSTA: `nordhealth%2Fprojects%2Fveterinary%2Fintegrations%2Fkraken-tentacles%2Fefsta-fiscalization`

Find the entry where `user.username == "gonz-nh"` and read the `state` field: `"unreviewed"`, `"approved"`, or `"requested_changes"`.

**Step 4 — Extract ticket ID:**
From each MR's `source_branch` or `title`, extract a ticket ID matching the pattern `[A-Z]+-[0-9]+` (case-insensitive, uppercase the result). Build the Linear link as `https://linear.app/nordhealth/issue/<TICKET-ID>`. Omit if not found.

**Step 5 — Format output.** No preamble, no section headers. One card per MR, two lines each:

```
**<author-name>** — [<ticket-id>](linear-url) — [!<iid>](mr-url) (repo-label)
<title> — `<status>`
```

Status labels (use inline code formatting):
- For my authored MRs: `my MR`
- For reviewer state "unreviewed": `needs review`
- For reviewer state "approved": `approved`
- For reviewer state "requested_changes": `changes requested`

Order MRs by status priority:
1. `needs review` first (action needed from me)
2. `my MR` second
3. `changes requested` third (waiting on author)
4. `approved` last (waiting on author/merge)

Separate each card with a blank line. Omit ticket link if no ticket ID found. Omit repo label if all MRs are from the same repo.
If glab fails, say so in one line and suggest running `glab auth login`.
