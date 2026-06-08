---
name: obsidian
description: Use when the user invokes /obsidian, or asks to save / document / note / write up something to their Obsidian vault — a finding, fix, runbook, decision, research result, project doc, recipe, or any durable knowledge from a finished task. Creates, edits, and soft-deletes notes in the user's Obsidian vault (path resolved at runtime) with consistent metadata, links, and navigation.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Obsidian vault manager

Turn finished work into durable, connected knowledge in the user's Obsidian vault
(path resolved in Step 0 below, synced via syncthing across machines).

**Core principle: never write, edit, or delete without showing a preview and getting one
explicit `y`.** Every file operation is gated by confirmation. This is what makes proactive
offering safe.

## The vault is self-describing

`$VAULT/_meta/vault-guide.md` is the source of truth for folder routing, naming,
frontmatter, linking, and deletion policy. **Always read it first** — the user edits it from
inside Obsidian, so it can change. This SKILL only describes the *process*; the guide describes
the *rules*.

If the guide is missing, bootstrap it from `patterns/vault-guide-template.md` (confirm folder
purposes with the user first), then continue.

## Privacy

`eros/` is private. **Never read, search, route into, or index it.** Skip it in every step,
including MOC generation. If the user explicitly asks to save there, do it without reading
existing contents.

## Workflow

### 0. Resolve vault path
Run:
```bash
if [ -d ~/syncthing/obsidian ]; then
  echo ~/syncthing/obsidian
elif [ -d /mnt/services/syncthing/data/obsidian ]; then
  echo /mnt/services/syncthing/data/obsidian
fi
```
Store the result as **VAULT**. If both paths are absent, stop and tell the user:
"Vault not found at `~/syncthing/obsidian` or `/mnt/services/syncthing/data/obsidian`. Please confirm the correct path."
Do not proceed until the user provides a valid path.

### 1. Load the rulebook
Read `$VAULT/_meta/vault-guide.md`. Use its routing table, frontmatter standard,
and conventions for every decision below. (Missing → bootstrap, see above.)

### 2. Classify the content
Decide two things:
- **`type`**: `note` | `reference` | `runbook` | `decision` | `doc` | `recipe`. Pick the body
  skeleton from `patterns/note-templates.md`.
- **target folder**: from the routing table. If genuinely ambiguous, ask; the fallback is
  `banana/` (miscellaneous catch-all). Never default into `eros/`.

Capture **`source`** now while you have context: the repo path, Linear ticket, URL, or
`conversation`. This provenance is the most valuable field — don't skip it.

### 3. Search first (consolidate, don't fragment)
Before creating anything, search the vault for related notes:
```
Grep/Glob over $VAULT (EXCLUDING eros/ and .trash/) by title keywords and body
```
- **Strong match** → propose updating `[[That Note]]` (append a section or merge) instead of a
  new file. Show what you'd add.
- **No match** → propose a new note with a Title-Case-With-Spaces name.
Let the user pick append-vs-new.

### 4. Compose
Build the note per the guide:
- **Frontmatter** (standard 5 fields): `tags`, `type`, `created`, `updated`, `source`. Use
  today's date (run `date +%F` if unsure). Tags are hierarchical (`tech/docker`, `work/efsta`).
- **Body** from the matching template in `patterns/note-templates.md`.
- **Wikilinks**: add `[[absolute links]]` to clearly-related existing notes you found in step 3.
  Don't invent links to notes that don't exist; don't over-link.
- **HTML / attachments**: the note itself is always markdown. If the task produced an HTML
  artifact or other binary, write it to `<folder>/_resources/` and link it from the note body
  (e.g. `[report](_resources/report.html)`). Markdown is the knowledge; artifacts are secondary.

### 5. Preview + confirm  ← MANDATORY GATE
Show the user, in the chat:
- the target path (and whether it's **new** or an **edit**),
- the frontmatter,
- the body — for an edit, show a **diff** of just what changes.

Ask once: `Write this? [y/n]`. Do nothing to disk until `y`.

### 6. Write, then update the MOC
- `Write` (new) or `Edit` (append/merge) the `.md`.
- On edit, bump `updated:` in frontmatter to today.
- Update the folder's `_index.md` (Map of Content): add or refresh the note's `[[wikilink]]`
  entry, grouped as the existing `_index.md` does. Create `_index.md` if the folder lacks one.

### 7. Delete = soft-delete (never destroy)
When asked to delete a note:
1. Show the file's path and a snippet.
2. Confirm: `Move to .trash? [y/n]`.
3. On `y`: `mkdir -p $VAULT/.trash` and `mv` the file there (preserve the basename;
   if a name collision, suffix with a counter).
4. Prune its entry from the folder's `_index.md`.
Recoverable from Obsidian, and a move (not a delete) is safe under syncthing. Never `rm`.

## Guardrails
- One note per run by default. Don't bulk-rewrite many files in a single invocation (syncthing
  conflict risk, and harder to review).
- Match the vault's existing style: Title Case names with spaces, Spanish characters preserved,
  absolute `[[wikilinks]]`, attachments in `_resources/`.
- This skill is **fully separate** from `~/assistant` (inbox / note / triage). Never touch it.
