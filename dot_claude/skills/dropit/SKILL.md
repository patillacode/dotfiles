---
name: dropit
description: Use when the user invokes /dropit to upload one or more HTML files to dropit.patilla.es and get shareable public URLs.
---

# dropit

Upload HTML files to dropit.patilla.es and return shareable public URLs with a chosen expiry.

## Step 1 — Check token

Source `~/.env` and verify `DROPIT_TOKEN` is set:

```bash
source ~/.env 2>/dev/null
```

If `DROPIT_TOKEN` is empty or unset, stop immediately:

> `DROPIT_TOKEN not set — run: dotfiles secrets`

## Step 2 — Resolve files

The user provides a path argument. Expand to a list of `.html` files:

- **Single file** (`report.html`) → one file
- **Glob** (`docs/*.html`) → all glob matches
- **Directory** (`docs/`) → top-level `.html` files only:
  ```bash
  find docs/ -maxdepth 1 -name "*.html"
  ```

Fail with a clear message if no HTML files are found.

## Step 3 — Ask TTL

Use `AskUserQuestion` with header `"TTL"`:

| Label | Description |
|-------|-------------|
| `24h` (Recommended) | Expires in 24 hours |
| `7d` | Expires in 7 days |
| `1h` | Expires in 1 hour |
| `forever` | Never expires |

Users can type `6h` or `48h` via the auto-provided Other option.

## Step 4 — Upload

For each resolved file:

```bash
source ~/.env 2>/dev/null
curl -s -X POST "https://dropit.patilla.es/upload?ttl=<TTL>" \
  -H "Authorization: Bearer $DROPIT_TOKEN" \
  -F "file=@<filepath>"
```

Parse URL and expiry from the JSON response:

```bash
python3 -c "import sys,json; r=json.load(sys.stdin); print(r['url'], r.get('expires_at',''))"
```

## Step 5 — Report

Print one line per file:

```
filename.html → https://dropit.patilla.es/p/xxxxx  (expires: 2026-05-24T10:00:00)
```

For `forever` uploads, omit the expiry note.
