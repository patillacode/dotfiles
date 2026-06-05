# Vault guide

> **This file is the source of truth the `/obsidian` skill reads.** Edit it here (in Obsidian)
> to change how notes are routed, named, and formatted — the skill picks up your changes on its
> next run. The skill never overwrites this file on its own.

## Folder routing

Where each kind of note lands. When a note doesn't clearly fit, the fallback is `banana/`.

| Folder | Purpose | What lands here |
|---|---|---|
| `work/` | Job / nordhealth | Work notes, specs, findings (subfolders: nordhealth, typecode, qida) |
| `tech/` | Dev & sysadmin knowledge | References, runbooks, gotchas, tool configs |
| `projects/` | Personal code projects | Project docs, specs, decisions (e.g. topstopstops, patillarr) |
| `letras/` | Music | Lyrics, song ideas, audio (`_resources/`) |
| `recetas/` | Cooking | Recipes |
| `inversión/` | Personal finance | Investment notes, research, accounts |
| `banana/` | Miscellaneous | Random / out-of-theme / anything that fits nowhere else. **Default fallback.** |
| `drawings/` | Visual | Excalidraw / sketches |
| `eros/` | **PRIVATE** | Personal private notes. The skill **never reads, searches, routes into, or indexes** this folder. Managed by hand. |

## Naming

- `Title Case With Spaces.md` — matches the existing vault.
- Spanish characters preserved (á, é, ñ, ü…). No ASCII-only restriction.
- **No date prefix** in filenames — dates live in frontmatter.

## Frontmatter standard

Every skill-created note carries these five fields:

```yaml
---
tags: [area/subarea]    # hierarchical: tech/docker, work/efsta, inversión/etf
type: note              # note | reference | runbook | decision | doc | recipe
created: 2026-06-05
updated: 2026-06-05     # bumped on every edit
source: conversation    # repo path, Linear ticket, URL, or "conversation" — provenance
---
```

`source` is the most valuable field: months later you can tell whether a note came from real
work, a specific repo/ticket, or a passing chat.

## Linking & navigation

- Use **absolute `[[wikilinks]]`** (matches `newLinkFormat: absolute`).
- Each populated folder has an `_index.md` (Map of Content) listing its notes. The skill adds
  or refreshes an entry there on every save, and prunes it on delete.
- Link new notes to clearly-related existing notes — but don't invent links or over-link.

## Attachments

- Per-folder `_resources/` for non-markdown artifacts (matches the vault's existing convention
  and `attachmentFolderPath: ./_resources`).
- HTML and other generated artifacts go in `_resources/` and are linked from the markdown note.
  The markdown is the knowledge; the artifact is secondary.

## Deletion

- **Soft-delete only.** Files move to `~/syncthing/obsidian/.trash/` (recoverable in Obsidian,
  safe under syncthing). The skill never permanently removes a file.

## Boundary

This vault and the `/obsidian` skill are **separate** from `~/assistant` (the work
inbox / note / triage system). Durable cross-life knowledge lives here; fast work capture lives
there.
