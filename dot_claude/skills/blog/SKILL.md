---
name: blog
description: Use when the user invokes /blog or asks to turn the current session into a blog post. Interviews the user (angle, title, visuals), then drafts a post in their voice, English or Spanish, into the Obsidian vault at projects/blog/ as an unpublished draft, with generated SVG/chart/screenshot images.
argument-hint: "[es|en] [topic hint]"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

# /blog: session -> blog post

Turn what happened in this session into a post for the user's blog (patilla.es/blog). Posts are
vault notes under `projects/blog/` that the site renders when they say `publish: true`.

**Core rules**
- Nothing is written to disk before the user approves a full preview.
- Posts are always written with `publish: false`. Only the user flips it, after reviewing in Obsidian.
- Never touch `eros/`. Never touch `~/assistant`. One post per run.
- Ask with `AskUserQuestion` (options + a recommendation first), one round at a time.

## 0. Resolve the vault
```bash
if [ -d ~/syncthing/obsidian ]; then echo ~/syncthing/obsidian
elif [ -d /mnt/services/syncthing/data/obsidian ]; then echo /mnt/services/syncthing/data/obsidian; fi
```
Store as **VAULT** (stop and ask if empty). `BLOG=$VAULT/projects/blog`, images go in `$BLOG/_resources/`.

## 1. Language (first question)
Argument `es` or `en` settles it. Otherwise ask first: English (default) or Spanish.
Spanish means es-ES, informal *tú*, `lang: es`, title and summary in Spanish too. Tech terms stay in
English (Spanglish is fine), in *italics*.

## 2. Load the voice
- Read `$BLOG/_voice.md`. If missing, interview the user with 4 `AskUserQuestion`s (audience,
  typical length, register/swearing/emojis, how posts end), show the resulting file, write it after a `y`.
- Read up to 3 recent real posts as tone samples: notes in `$BLOG/*.md` with `publish: true`, newest
  `date:` first, skipping `Lorem Ipsum.md`. Use them for rhythm and humour, never copy lines.

## 3. Mine the session
From this conversation, list the beats: the problem, dead ends, the fix, surprises, quotable errors,
commands and snippets worth showing. An optional topic hint in the arguments steers this. If the session
is thin or unrelated to anything postable, say so and ask what the post should be about.

## 4. Interview (3 rounds, then draft)
1. **Angle**: 3-4 options drawn from the beats (war story / how-to / lesson learned / hot take / "what
   I'd do differently"), one-line pitch each, recommended one first.
2. **Title + hook**: 3 title options, each with its opening line. Also ask what must be included and
   what to skip (private stuff, boring detours), and the length (suggest 400-800 words).
3. **Visuals**: propose concrete items to keep or drop, e.g. "SVG: request flow diagram", "chart:
   before/after timings", "screenshot of the final page", "snippet: the 6-line fix". Offer only what
   the session can actually back up.

## 5. Make the visuals
Work in the scratchpad dir, copy finals to `$BLOG/_resources/`.
File names: `<post-slug>-<what>.svg|png`, lowercase-kebab, **no spaces**, flat (no subfolders).

- **SVG** (default for diagrams, flows, sketches): hand-written, self-contained, no scripts or external
  refs/fonts. An SVG shown via `<img>` does **not** inherit page colours, and the site has several
  themes, so give every SVG an opaque background `<rect>` and explicit colours. Set `viewBox`, no fixed
  width/height; text >= 14 units; check it by reading the file back.
- **Charts**: `uv run --with matplotlib python <script>`, explicit `facecolor`, save `.svg` or `.png` (dpi 150).
- **Screenshots**: Playwright MCP tools (load them with ToolSearch) if available, save `.png`; view the
  result with Read before including it. No tool or no page to shoot -> skip and say so.
- Every image gets real alt text.

## 6. Draft: what the renderer supports
The site renders CommonMark + tables + strikethrough + syntax-highlighted fences. Raw HTML is stripped.

- Frontmatter first, body after. **No `# H1`** (the title comes from `title`). Use `##`/`###`.
- OK: paragraphs, lists, `> quotes`, **bold**, *italic*, `code`, ~~strike~~, tables, `[text](url)`,
  fenced code **with a language tag** (` ```bash `), images `![alt](_resources/file.svg)`.
- Images must be written exactly `_resources/<file>` (not `./_resources`, not absolute) so both Obsidian
  and the site resolve them.
- NOT supported (renders as junk): `[[wikilinks]]`, callouts `> [!note]`, footnotes, task lists `- [ ]`,
  math, Mermaid, bare-URL autolinking, HTML. Use SVG instead of Mermaid.
- Redact secrets in snippets and screenshots (API keys, tokens, passwords, private keys) as
  `<redacted>`. Hostnames, IPs and paths stay as they are.

**Frontmatter** (match `Lorem Ipsum.md`; `date` must be an **unquoted** ISO date or the site falls
back to the file's mtime; `publish` must be a real boolean):
```yaml
---
tags: [projects/blog]
type: doc
created: <date +%F>
updated: <date +%F>
source: <git repo path of the session, else conversation>
publish: false
title: <title>
date: <date +%F>
lang: en|es
summary: <one sentence, shown on the blog index>
---
```

**Voice**: follow `_voice.md`. Open with the hook, no throat-clearing. Short, well-defined paragraphs.
Jargon and foreign words in *italics*. End on a short takeaway or punchline, not a recap. Avoid LLM
tells: "in today's world", "let's dive in", "delve", "it's worth noting", rule-of-three lists, tidy
moral paragraphs, em-dash chains, headings on every paragraph. Funny only where it's true.

## 7. Preview and revise (mandatory gate)
Show in chat: target path, the post URL (`/blog/` + slug, where slug = title lowercased with every run of
non `a-z0-9` characters turned into `-`; accents split words, so flag an ugly slug), the full note
(frontmatter + body), the image list, and the word count (`wc -w` on the body).
Then loop: apply tweaks ("shorter", "funnier intro", "more code", "different ending") and re-preview
until the user says `y`. If a tweak is about tone, offer to append it to `_voice.md` under
`## Learned rules`.

## 8. Write
Before writing, run the checks:
- Slug collision: another note in `$VAULT` (excluding `eros/`, `.trash/`) with `publish: true` and the
  same slug wins over this one, so pick a different title.
- Target `$BLOG/<Title Case Name>.md` must not already exist (ask before touching an existing file).

Then `mkdir -p $BLOG/_resources`, write the images and the note. Skip `_index.md`: the site is the index.
Finish with: path, image files, and "Review it in Obsidian, then set `publish: true`; the site picks it up
within ~10 minutes of syncthing delivering it."
