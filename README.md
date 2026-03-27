# PatillaCode Dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io). Supports macOS (zsh), Debian/Ubuntu Linux, and Arch Linux with a profile-based system — one repo, multiple machines.

**Primary remote:** `ssh://git@forgejo.patilla.es:2223/patillacode/dotfiles.git`
**Mirror:** `https://github.com/patillacode/dotfiles`

---

## Machines

| Name          | OS           | Shell | Profile  | Starship   |
|---------------|--------------|-------|----------|------------|
| bars          | macOS        | zsh   | personal | simple     |
| nordhealth    | macOS        | zsh   | work     | (at init)  |
| totoro        | Debian       | bash  | server   | totoro     |
| archbook      | Arch Linux   | zsh   | personal | (at init)  |
| tops-staging  | Ubuntu       | bash  | server   | tops       |
| ushuaia       | Ubuntu       | bash  | server   | ushuaia    |

---

## Fresh Install

### One-liner (new machine)

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --source ~/dotfiles \
  ssh://git@forgejo.patilla.es:2223/patillacode/dotfiles.git
```

This installs chezmoi, clones the repo, runs the interactive setup, and applies everything.

### Manual (existing chezmoi install)

```bash
chezmoi init --source ~/dotfiles ssh://git@forgejo.patilla.es:2223/patillacode/dotfiles.git
chezmoi apply
```

### Migrating from the old Stow setup

If the machine currently has the old GNU Stow dotfiles, remove the symlinks first:

```bash
# From the old dotfiles directory
cd ~/dotfiles
stow --delete .

# Remove the old repo
cd ~
rm -rf ~/dotfiles
```

Then proceed with the normal fresh install one-liner below.

If the machine has an older chezmoi setup instead:

```bash
chezmoi purge   # removes ~/dotfiles source dir and ~/.config/chezmoi config
```

Then proceed with the fresh install one-liner.

---

### Prerequisites

- **Secrets:** A [KeePassXC](https://keepassxc.org) database with a `dotfiles/github-pat` entry (Password field = your GitHub PAT). The `keepassxc-cli` binary must be on your PATH — it ships with KeePassXC on macOS, and is installed automatically via packages on Linux developer profiles.
- **SSH key:** Your SSH key registered with the Forgejo instance to clone via SSH.

### What the setup wizard asks

When running `chezmoi init` for the first time you'll be prompted for:

1. **Machine name** — `bars`, `nordhealth`, `totoro`, `archbook`, or custom
2. **Profile** — `1` personal · `2` work · `3` server
3. **Shell** — `zsh` or `bash` (Linux only, auto-detected on macOS)
4. **Homebrew on Linux** — whether to install Homebrew alongside apt/pacman
5. **Starship theme** — choose from 13+ themes (default: `simple`)
6. **Git name & email** — used in `~/.config/git/config`
7. **KeePassXC database path** — full path to your `.kdbx` file
8. **Claude Code variant** — `personal`, `work`, or `none`
9. **Font family & size** — used in Ghostty and Zed

Answers are saved in `~/.config/chezmoi/chezmoi.toml` and reused on subsequent runs.

---

## Daily Usage

```bash
dotfiles sync          # pull latest changes + apply
dotfiles push [msg]    # commit source changes + push to remote
dotfiles apply         # apply configs to $HOME
dotfiles diff          # preview what would change
dotfiles status        # show machine, profiles, managed file count
dotfiles theme         # interactive Starship theme picker (requires fzf)
dotfiles doctor        # run chezmoi diagnostics
dotfiles edit <file>   # edit a managed file (opens in $EDITOR)
```

Or use chezmoi directly:

```bash
chezmoi apply
chezmoi diff
chezmoi edit ~/.zshrc
chezmoi doctor
```

---

## Profiles

Profiles are defined in `.chezmoidata.yaml`. Each profile is a fully-resolved flat list (ancestors included):

| Profile    | Gets                              |
|------------|-----------------------------------|
| `personal` | base + developer + personal files |
| `work`     | base + developer + work files     |
| `server`   | base + server files               |

Files are gated in `.chezmoiignore` — wrong-profile files are never deployed.

---

## Common Tasks

### Change your Starship theme

**Interactive** (recommended):
```bash
dotfiles theme
```

**Manual** — edit `~/.config/chezmoi/chezmoi.toml`:
```toml
[data.starship]
    theme = "catppuccin"
```
Then `chezmoi apply`.

Available themes: `simple` · `minimal` · `zenful` · `nerd-font-symbols` · `gruvbox` · `catppuccin` · `dracula` · `nord` · `tokyo-night` · `pastel` · `tops` · `totoro` · `ushuaia`

---

### Add a new alias

1. Create `dot_alias/<name>.sh` in the repo
2. Add it to the relevant profile(s) in `.chezmoidata.yaml` under `profile_aliases`
3. Run `chezmoi apply` or `dotfiles push "add <name> alias"`

---

### Add a new package to auto-install

Edit `.chezmoidata.yaml`:

```yaml
packages:
  brew_formulae:
    personal:          # or base / developer / work
      - new-tool
  apt:
    base:
      - new-tool
  pacman:
    base:
      - new-tool
```

The package will be installed automatically next time `chezmoi apply` runs (the script reruns when the package list hash changes).

---

### Add a new tool config

1. Create `dot_config/<tool>/` in the repo
2. If it should only appear on certain profiles, gate it in `.chezmoiignore`:
   ```
   {{ if not (has "personal" .profiles) -}}
   dot_config/<tool>/
   {{ end -}}
   ```
3. Run `chezmoi apply`

---

### Change font (Ghostty + Zed)

Edit `~/.config/chezmoi/chezmoi.toml`:
```toml
[data.font]
    family = "JetBrainsMono Nerd Font Propo"
    size = 16
```
Then `chezmoi apply` — both Ghostty and Zed pick up the change.

---

### Use a per-machine override

To include an alias or config outside your profile, edit `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    include_aliases = ["music"]   # pull in music.sh even on a work machine
    exclude_aliases = ["tv"]      # skip tv.sh on a personal machine
```

Then `chezmoi apply`.

---

## Repository Layout

```
dotfiles/
├── .chezmoi.toml.tmpl           # init wizard (prompts)
├── .chezmoidata.yaml            # shared data: profiles, packages
├── .chezmoiignore               # per-machine file exclusions (templated)
├── .chezmoiscripts/
│   ├── run_once_before_bootstrap.sh.tmpl
│   ├── run_onchange_install-packages.sh.tmpl   # brew / apt / pacman
│   ├── run_onchange_install-uv.sh.tmpl         # uv on Linux
│   ├── run_onchange_install-oh-my-zsh.sh.tmpl
│   ├── run_onchange_install-python-tools.sh.tmpl
│   ├── run_onchange_update-hosts.sh.tmpl       # /etc/hosts entries
│   └── run_after_apply-snapshot.sh.tmpl
│
├── dot_alias/                   # → ~/.alias/
├── dot_claude/                  # → ~/.claude/
├── dot_config/
│   ├── git/                     # config.tmpl + nordhealth work identity
│   ├── ghostty/                 # config.tmpl
│   ├── starship/                # 13 .toml themes
│   ├── zed/                     # settings.json.tmpl
│   └── atuin/ btop/ gh/ mpv/ nvim/ tmux/ yt-dlp/
├── dot_local/bin/
│   ├── executable_dotfiles      # → ~/.local/bin/dotfiles (CLI wrapper)
│   ├── executable_git-clean-branches
│   ├── executable_img-convert
│   ├── executable_vid2gif
│   ├── executable_ffmpeg-trim
│   ├── executable_tg-send
│   ├── executable_screen-cap
│   └── executable_download-urls
├── dot_oh-my-zsh/               # → ~/.oh-my-zsh/ (custom themes)
├── dot_vim/ + dot_vimrc         # vim config
├── dot_zshrc.tmpl               # → ~/.zshrc
├── dot_bashrc.tmpl              # → ~/.bashrc
└── private_dot_ssh/             # → ~/.ssh/ (0700/0600)
```

---

## Included Tools

**Shell:** zsh + oh-my-zsh (`bars` theme) + Starship prompt

**Editor:** Zed (primary) · Neovim/LazyVim · Vim

**Terminal:** Ghostty

**Git:** delta pager with custom `patilla` theme · git-lfs

**CLI:** atuin · bat · btop · duf · eza · fastfetch · fd · fzf · gh · ripgrep · tmux · uv

**Personal:** mpv · yt-dlp · ollama · streamlink · ffmpeg

**Scripts:** `git-clean-branches` · `img-convert` · `vid2gif` · `ffmpeg-trim` · `tg-send` · `screen-cap` · `download-urls`

**Secrets:** KeePassXC integration — secrets are injected at `chezmoi apply` time, never stored in the repo.
