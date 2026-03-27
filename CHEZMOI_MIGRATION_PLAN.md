# Chezmoi Migration Plan

Personal dotfiles migration from GNU Stow (branch-per-machine) to chezmoi (profile-based, single branch).

---

## Machines

| Name       | OS     | Shell | Profile  | Status     |
|------------|--------|-------|----------|------------|
| bars       | macOS  | zsh   | personal | primary    |
| nordhealth | macOS  | zsh   | work     | secondary  |
| totoro     | Debian | bash  | server   | fresh      |

---

## What Was Dropped

**Tools/configs removed:**
- kitty → replaced by ghostty
- newsboat, yazi, sketchybar — no longer used
- autoenv → replaced by uv
- iterm — long gone
- neofetch → replaced by fastfetch
- zoxide — not actively used
- qida references → now nordhealth

**Python tools (pipx → uv, pruned):**
- Dropped: bamp, aider-chat, shell-gpt, pip-tools, openai, ppieces, converter-cli, pyyt-cli, twine, django
- Kept: ruff, prek (via uv, developer profile), yt-dlp (personal profile)

**Infra removed:**
- `install.sh` → replaced by `chezmoi init` + run scripts
- `install-tools/` → absorbed into `.chezmoiscripts/`
- `.stow-local-ignore` → replaced by `.chezmoiignore`
- `backups/` → git is the rollback
- stow, pipx
- All machine branches → single branch, profiles handle it

---

## Repository Structure

```
dotfiles/
├── .chezmoi.toml.tmpl              # Interactive init (prompts on first run)
├── .chezmoidata.yaml               # Profiles, packages, alias lists
├── .chezmoiignore                  # Templated per-machine exclusions
│
├── dot_zshrc.tmpl                  # → ~/.zshrc (zsh machines)
├── dot_bashrc.tmpl                 # → ~/.bashrc (bash machines / totoro)
├── dot_vimrc                       # → ~/.vimrc
│
├── dot_alias/                      # → ~/.alias/
│   ├── ai.sh                       # Claude Code + ollama aliases
│   ├── atuin.sh
│   ├── docker.sh
│   ├── ghostty.sh                  # macOS GUI only
│   ├── git.sh
│   ├── misc.sh
│   ├── music.sh                    # personal only
│   ├── ssh.sh
│   ├── system.sh
│   ├── tmux.sh
│   ├── tv.sh                       # personal only
│   ├── twitch.sh                   # personal only
│   └── utils.sh
│
├── private_dot_env.tmpl            # → ~/.env (0600, secrets via KeePassXC)
├── private_dot_ssh/config.tmpl     # → ~/.ssh/config
│
├── dot_config/
│   ├── atuin/
│   ├── btop/
│   ├── gh/
│   ├── ghostty/config.tmpl         # font/size from chezmoi data
│   ├── git/
│   │   ├── config.tmpl             # user identity from chezmoi data
│   │   └── nordhealth              # work identity (work profile only)
│   ├── mpv/                        # personal only
│   ├── nvim/                       # developer only (LazyVim)
│   ├── starship/                   # 13 themes
│   ├── tmux/
│   ├── yt-dlp/                     # personal only
│   └── zed/settings.json.tmpl      # font from chezmoi data
│
├── dot_claude/                     # → ~/.claude/ (developer only)
│   ├── settings.json.tmpl
│   ├── CLAUDE.md.tmpl
│   └── rules/
│       ├── base.md
│       ├── personal.md             # personal profile only
│       └── work.md                 # work profile only
│
├── dot_oh-my-zsh/custom/themes/    # zsh only
│   ├── bars.zsh-theme
│   └── nordhealth.zsh-theme        # work only
│
├── dot_vim/
│
├── dot_local/bin/executable_dotfiles  # → ~/.local/bin/dotfiles
│
└── .chezmoiscripts/
    ├── run_once_before_bootstrap.sh.tmpl       # Homebrew / apt essentials
    ├── run_onchange_install-packages.sh.tmpl   # brew/apt packages per profile
    ├── run_onchange_install-oh-my-zsh.sh.tmpl  # oh-my-zsh + plugins (zsh only)
    ├── run_onchange_install-python-tools.sh.tmpl  # uv + Python tools
    └── run_after_apply-snapshot.sh.tmpl        # save snapshot after apply
```

---

## Profile System

Profiles are **flat resolved lists** — selecting `personal` gives you base + developer + personal.

| Profile    | Includes              | Gets                                              |
|------------|-----------------------|---------------------------------------------------|
| `base`     | —                     | core shell, git, atuin, docker, tmux, ghostty     |
| `developer`| base                  | ai aliases, zed, nvim, claude                     |
| `personal` | developer             | music, tv, twitch, mpv, yt-dlp, ssh               |
| `work`     | developer             | ssh, nordhealth git identity                      |
| `server`   | base                  | docker, tmux (bash shell, no GUI)                 |

Defined in `.chezmoidata.yaml` → `profile_aliases` and `profile_configs`.

---

## Interactive Setup (`.chezmoi.toml.tmpl`)

Running `chezmoi init` prompts for:

1. **Machine name** — bars / nordhealth / totoro / custom
2. **Profile** — personal / work / server
3. **Shell** — auto-detected, confirm on Linux
4. **Is GUI machine** — auto-yes on macOS, no on server
5. **Starship theme** — choose from 13 themes (default: simple)
6. **Git name & email** — used in `~/.config/git/config`
7. **KeePassXC database path** — full path to your `.kdbx` file
8. **Claude Code variant** — personal / work / none
9. **Font family & size** — used in Ghostty and Zed

All answers saved to `~/.config/chezmoi/chezmoi.toml` via `promptStringOnce`.

---

## Secrets via KeePassXC

**Security model:** Secrets are NEVER in git. The source template (`private_dot_env.tmpl`) contains only `{{ keepassxcAttribute "..." "Password" }}` calls. At `chezmoi apply` time, chezmoi reads from the local `.kdbx` database (synced via Syncthing) and injects values into `~/.env` (0600 permissions). Git never sees the actual values.

**Required KeePassXC entries:**

| Entry name           | Field    | Maps to          |
|----------------------|----------|------------------|
| `dotfiles/github-pat`| Password | `$GITHUB_TOKEN`  |

**Setup steps:**
1. Open KeePassXC → create group `dotfiles`
2. Add entry `github-pat` with your GitHub personal access token as the Password
3. Set `keepassxc.database` in `~/.config/chezmoi/chezmoi.toml` to the full path of your `.kdbx` file
4. Run `chezmoi apply` — `~/.env` is created with the token injected

**Adding a new secret:**
1. Add entry in KeePassXC under `dotfiles/` group
2. Add line to `private_dot_env.tmpl`:
   ```
   export MY_KEY="{{ keepassxcAttribute "dotfiles/my-entry" "Password" }}"
   ```
3. Run `chezmoi apply`

---

## Starship Themes

13 themes available in `dot_config/starship/`:

| Theme              | Style                     |
|--------------------|---------------------------|
| `simple`           | Minimal, no icons         |
| `minimal`          | Ultra-minimal             |
| `zenful`           | Calm, muted colors        |
| `nerd-font-symbols`| Icon-heavy                |
| `gruvbox`          | Warm earth tones          |
| `catppuccin`       | Soft pastels (Mocha)      |
| `dracula`          | Purple/pink on dark       |
| `nord`             | Arctic blue palette       |
| `tokyo-night`      | Tokyo Night Storm         |
| `pastel`           | Soft pastel palette       |
| `totoro`           | Server: no icons, fast    |
| `tops`             | topstopstops project theme|
| `ushuaia`          | Trip laptop theme         |

**Change theme interactively:** `dotfiles theme` (requires fzf + bat for preview)

**Change theme manually:**
```toml
# ~/.config/chezmoi/chezmoi.toml
[data.starship]
    theme = "catppuccin"
```
Then `chezmoi apply`.

---

## `dotfiles` CLI Commands

Installed to `~/.local/bin/dotfiles`:

| Command              | Action                                           |
|----------------------|--------------------------------------------------|
| `dotfiles sync`      | Pull latest from git + apply                     |
| `dotfiles push [msg]`| Commit source changes + push                     |
| `dotfiles apply`     | Apply configs to $HOME                           |
| `dotfiles apply --dry-run` | Preview what would change                  |
| `dotfiles diff`      | Show pending changes (chezmoi diff)              |
| `dotfiles edit <file>` | Edit a managed file in $EDITOR                 |
| `dotfiles theme`     | Interactive Starship theme picker (fzf)          |
| `dotfiles info`      | Show active aliases, configs, tools, settings    |
| `dotfiles rollback`  | Restore a previous snapshot (fzf)                |
| `dotfiles status`    | Machine info, profiles, managed file count       |
| `dotfiles doctor`    | Run chezmoi diagnostics                          |

---

## Snapshot System

`run_after_apply-snapshot.sh.tmpl` runs automatically after every `chezmoi apply`:
- Saves all managed files to `~/.local/share/chezmoi-snapshots/<timestamp>/`
- Also copies `chezmoi.toml`
- Keeps last 10 snapshots (older ones deleted automatically)
- Snapshots are local — never synced or committed

**Restore a snapshot:** `dotfiles rollback` (interactive fzf picker)

---

## Bootstrap: Fresh Machine

```bash
# Install chezmoi + clone + prompt + apply in one step
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply patillacode/dotfiles
```

Answer the setup wizard. Then automatically:
1. Homebrew (macOS) or apt essentials (Linux) installed
2. Packages for your profile installed
3. oh-my-zsh + plugins installed (zsh machines)
4. Python tools via uv installed
5. All configs deployed
6. First snapshot saved

---

## Bootstrap: Existing Machine (bars)

```bash
# 1. Preview all changes without touching anything
chezmoi diff

# 2. Dry run
chezmoi apply --dry-run

# 3. Apply
chezmoi apply

# 4. Verify
source ~/.zshrc
dotfiles status
git config user.name
```

---

## Common Tasks

### Add a new alias

1. Create `dot_alias/myalias.sh`:
   ```bash
   alias foo='echo bar'
   ```

2. Add to the relevant profile(s) in `.chezmoidata.yaml`:
   ```yaml
   profile_aliases:
     personal:
       - ... existing ...
       - myalias
   ```

3. Apply: `chezmoi apply` (or `dotfiles push "add myalias"`)

### Remove an alias

```bash
git rm dot_alias/oldthing.sh
rm ~/.alias/oldthing.sh
# Remove from .chezmoidata.yaml
git commit -m "remove: drop oldthing alias"
```

### Add a new package

Edit `.chezmoidata.yaml`:
```yaml
packages:
  brew_formulae:
    personal:
      - new-tool
```
Then `chezmoi apply` — the install script reruns when the package list hash changes.

### Per-machine override (include/exclude)

Edit `~/.config/chezmoi/chezmoi.toml`:
```toml
[data]
    include_aliases = ["music"]   # pull in even on work machine
    exclude_aliases = ["tv"]      # skip even on personal machine
```
Then `chezmoi apply`.

### Add a new secret

1. Add entry in KeePassXC under `dotfiles/` group
2. Add to `private_dot_env.tmpl`:
   ```
   export MY_API_KEY="{{ keepassxcAttribute "dotfiles/my-entry" "Password" }}"
   ```
3. `chezmoi apply`

### Edit a managed config

```bash
# Opens source file in $EDITOR
dotfiles edit ~/.zshrc
chezmoi apply

# Or directly
$EDITOR ~/dotfiles/dot_zshrc.tmpl
chezmoi apply
```

### Change font (Ghostty + Zed)

Edit `~/.config/chezmoi/chezmoi.toml`:
```toml
[data.font]
    family = "JetBrainsMono Nerd Font Propo"
    size = 16
```
Then `chezmoi apply`.

---

## Verification Checklist

### bars (macOS, personal)
- [ ] `chezmoi diff` shows expected changes only
- [ ] `chezmoi apply --dry-run` succeeds
- [ ] `chezmoi apply` deploys all files
- [ ] New shell: aliases load, starship renders, fzf works
- [ ] `git config user.name` → PatillaCode
- [ ] `dotfiles status` shows correct machine/profile
- [ ] `dotfiles theme` → interactive picker works
- [ ] `dotfiles info` → shows aliases/configs/tools
- [ ] `dotfiles rollback` → lists snapshots
- [ ] `~/.env` created with GITHUB_TOKEN (after KeePassXC setup)
- [ ] No kitty/newsboat/yazi/sketchybar files present

### totoro (Debian, server)
- [ ] One-command bootstrap completes
- [ ] Bash prompt with starship works
- [ ] vim configured, docker aliases available
- [ ] tmux session persistence works
- [ ] No zsh/oh-my-zsh/ghostty/GUI files present
- [ ] `dotfiles status` shows server profile

### nordhealth (macOS, work)
- [ ] `chezmoi init` with work profile
- [ ] `git config user.email` → nordhealth address
- [ ] No music/tv/twitch aliases (unless include_aliases set)
- [ ] `~/.claude/settings.json` has work variant
- [ ] Work SSH hosts in `~/.ssh/config`

---

## Old Branch Cleanup

After verifying on all machines:

```bash
# Tag old branches for reference
git tag archive/nh-laptop nh-laptop
git tag archive/archbook archbook
git tag archive/free-laptop free-laptop

# Delete old branches
git branch -d nh-laptop archbook free-laptop

# Push tags and deletions
git push origin --tags
git push origin --delete nh-laptop archbook free-laptop
```
