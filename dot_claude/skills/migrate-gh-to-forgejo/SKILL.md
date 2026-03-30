---
name: migrate-gh-to-forgejo
description: "Use when the user wants to migrate a GitHub repo to Forgejo, move a repo from GitHub, or says 'migrate to forgejo'. Handles repo creation on forgejo.patilla.es, push of all refs, push mirror setup back to GitHub, and local remote reconfiguration."
---

You are helping the user migrate a GitHub repository to their personal Forgejo instance. Follow the 4-phase workflow below **exactly**. Do not skip phases.

---

## Non-Negotiable Conventions

These rules are absolute — no exceptions:

- Forgejo SSH URL format: `ssh://git@forgejo.patilla.es:2223/patillacode/<repo>.git`
- Forgejo HTTPS API base: `https://forgejo.patilla.es/api/v1`
- Forgejo organization: `patillacode`
- Push mirror interval: `0` with `sync_on_commit: true`
- Use full SSH URLs for git remotes (not `fg:` shortcut) — explicit in `git remote -v`
- Push mirror authenticates to GitHub via HTTPS using `GITHUB_TOKEN`

---

## Phase 1 — Pre-flight Checks

Run all checks automatically. If any fail, report clearly and stop.

### 1a. Tool availability

```bash
which tea            # tea CLI installed?
tea login list       # has forgejo login configured?
gh auth status       # gh CLI authenticated?
echo $GITHUB_TOKEN   # token available for push mirror?
echo $FORGEJO_TOKEN  # token available for API calls? (from ~/.env via 'dotfiles secrets')
```

If `tea` is not installed or not configured, print the **First-time Setup** section at the bottom and stop.

### 1b. Repository state

```bash
git remote -v                    # must have a github.com remote
git status --porcelain           # must be clean (no uncommitted changes)
git branch -r --list 'origin/*'  # count remote branches
git tag                          # count tags
```

### 1c. GitHub metadata

Extract via `gh api`:

```bash
gh api repos/{owner}/{repo} --jq '{name: .name, private: .private, description: .description, default_branch: .default_branch}'
```

Parse `{owner}` and `{repo}` from the GitHub remote URL.

### 1d. Forgejo collision check

Check if repo already exists on Forgejo. `FORGEJO_TOKEN` must be available in the environment (sourced from `~/.env` via `dotfiles secrets`):

```bash
curl -sf -H "Authorization: token $FORGEJO_TOKEN" \
  "https://forgejo.patilla.es/api/v1/repos/patillacode/<repo-name>"
```

If 200: repo exists — ask user whether to skip creation or abort.
If 404: safe to proceed.

Present a summary of all findings before moving to Phase 2.

---

## Phase 2 — Interview

Single round via `AskUserQuestion`. Present the migration summary:

- **Repo:** `{owner}/{repo}` → `patillacode/{repo}`
- **Visibility:** public / private (from GitHub)
- **Description:** from GitHub
- **Branches:** N branches
- **Tags:** N tags
- **Push mirror:** GitHub ← Forgejo (on commit)

Ask: "Proceed with migration?" with multi select options:
1. **Yes, proceed as shown** (recommended)
2. **Change visibility** — flip public/private
3. **Change repo name on Forgejo** — use a different name
4. **Skip push mirror** — don't set up GitHub mirror
5. Other

---

## Phase 3 — Migration

### 3a. Create repo on Forgejo

Try `tea` first:

```bash
tea repos create-from-args --login forgejo --name <repo-name> \
  --description "<description>" [--private]
```

If `tea` flags don't work, fall back to the REST API:

```bash
curl -sf -X POST "https://forgejo.patilla.es/api/v1/user/repos" \
  -H "Authorization: token $FORGEJO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "<repo-name>",
    "private": <true|false>,
    "description": "<description>",
    "default_branch": "<default-branch>"
  }'
```

### 3b. Push all refs

```bash
git remote add forgejo "ssh://git@forgejo.patilla.es:2223/patillacode/<repo-name>.git"
git push forgejo --all
git push forgejo --tags
```

### 3c. Configure push mirror (unless user skipped)

```bash
curl -sf -X POST "https://forgejo.patilla.es/api/v1/repos/patillacode/<repo-name>/push_mirrors" \
  -H "Authorization: token $FORGEJO_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "remote_address": "https://github.com/<owner>/<repo-name>.git",
    "remote_username": "<github-username>",
    "remote_password": "'"$GITHUB_TOKEN"'",
    "interval": "8h0m0s",
    "sync_on_commit": true
  }'
```

If `GITHUB_TOKEN` lacks push permissions, warn the user and provide instructions for creating a fine-grained PAT with `Contents: Read and write` scoped to the repo.

### 3d. Update local remotes

```bash
git remote set-url origin "ssh://git@forgejo.patilla.es:2223/patillacode/<repo-name>.git"
git remote remove forgejo
```

### 3e. Archive GitHub repo (optional)

Ask user: "Archive the GitHub repo? This marks it read-only on GitHub."

If yes:

```bash
gh repo archive <owner>/<repo-name> --yes
```

### 3f. Update self-referencing URLs in README

If the README contains clone URLs or badges pointing to `github.com/{owner}/{repo}`:
- Update self-referencing clone URLs to the Forgejo URL
- Leave external dependency URLs (other people's repos) unchanged

---

## Phase 4 — Verification

### 4a. Check remote

```bash
git remote -v              # should show Forgejo as origin
git ls-remote origin       # should return refs from Forgejo
```

### 4b. Count refs

Compare branch and tag counts against pre-migration values. All must match.

### 4c. Verify push mirror

```bash
curl -sf -H "Authorization: token $FORGEJO_TOKEN" \
  "https://forgejo.patilla.es/api/v1/repos/patillacode/<repo-name>/push_mirrors"
```

Should return a mirror entry pointing to GitHub.

### 4d. Summary

```
## Migration Complete

- **Source:** github.com/<owner>/<repo-name>
- **Destination:** forgejo.patilla.es/patillacode/<repo-name>
- **Visibility:** public / private
- **Branches:** N migrated
- **Tags:** N migrated
- **Push mirror:** Active (syncs every 8h + on commit) / Skipped
- **Local origin:** ssh://git@forgejo.patilla.es:2223/patillacode/<repo-name>.git
- **GitHub repo:** Archived / Active

## Verification
- [x] Forgejo remote accessible
- [x] All branches present (N/N)
- [x] All tags present (N/N)
- [x] Push mirror configured / skipped
- [x] GitHub repo archived / kept active
```

---

## First-time Setup (reference — not part of per-repo workflow)

If pre-flight checks fail, guide the user through these steps:

### 1. Install tea CLI

```bash
brew install tea
```

### 2. Generate Forgejo API token

1. Go to `https://forgejo.patilla.es/user/settings/applications`
2. Create token with scopes: `repo`, `admin:org`, `user`
3. Save the token value

### 3. Configure tea login

```bash
tea login add --name forgejo --url https://forgejo.patilla.es --token <token>
```

### 4. Verify

```bash
tea login list                              # should show forgejo entry
ssh -T git@forgejo.patilla.es -p 2223       # should greet you
```

### 5. Add token to dotfiles secrets

1. Create KeePassXC entry: `Code/dotfiles/forgejo-token` with the API token as Password
2. Run `dotfiles secrets` to inject `FORGEJO_TOKEN` into `~/.env`
3. Run `source ~/.env` or open a new shell
