# PatillaCode Dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io).

Supports macOS (zsh) and Debian/Ubuntu Linux with a trait-based system — one repo, multiple machines.

**Primary remote:** `https://forgejo.patilla.es/patillacode/dotfiles.git`

**Mirror:** `https://github.com/patillacode/dotfiles`

---

## Fresh Install

### One-liner (new machine)

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --source ~/dotfiles https://forgejo.patilla.es/patillacode/dotfiles.git
```

This installs chezmoi, clones the repo, runs the interactive setup, and applies everything.

### Manual

Install chezmoi

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
# or
brew install chezmoi
````

Then initialize the repo and run the setup wizard:

```bash
chezmoi init --source ~/dotfiles https://forgejo.patilla.es/patillacode/dotfiles.git
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

Then proceed with the normal fresh install one-liner above.

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

1. **Machine name** — `bars`, `nordhealth`, `totoro`, or custom
2. **Profile preset** — `1` personal · `2` work · `3` server · `4` custom (pick individual traits)
3. **Shell** — `zsh` or `bash` (Linux only, auto-detected on macOS)
4. **Homebrew on Linux** — whether to install Homebrew alongside apt
5. **Starship theme** — choose from 13+ themes (default: `simple`)
6. **Git name & email** — used in `~/.config/git/config`
7. **KeePassXC database path** — full path to your `.kdbx` file
8. **Claude Code variant** — `personal`, `work`, or `none`
9. **Font family & size** — used in Ghostty and Zed

Answers are saved in `~/.config/chezmoi/chezmoi.toml` and reused on subsequent runs.

---

## Daily Usage

Aliases: `dt` and `dots` are shorthand for `dotfiles`.

```bash
# Sync & deploy
dotfiles sync              # pull latest changes + apply
dotfiles push [msg]        # commit source changes + push to remote
dotfiles apply [--dry-run] # apply configs to $HOME
dotfiles diff              # preview what would change
dotfiles edit <file>       # edit a managed file (opens in $EDITOR)

# Customization
dotfiles theme             # interactive Starship theme picker (fzf)
dotfiles secrets           # inject secrets from KeePassXC into ~/.env

# Info
dotfiles status            # machine info, traits, managed file count
dotfiles info              # active aliases, configs, tools
dotfiles utils             # list all utility scripts and fzf functions
dotfiles doctor            # run chezmoi diagnostics

# Recovery
dotfiles rollback          # restore a previous snapshot (fzf)
```

Or use chezmoi directly: `chezmoi apply`, `chezmoi diff`, `chezmoi edit ~/.zshrc`.

---

## Traits

Traits are defined in `.chezmoidata/profiles.yaml`. Each trait is independent and answers one question:

| Trait       | Question                    | Machines            |
|-------------|-----------------------------|---------------------|
| `base`      | Does this machine exist?    | all                 |
| `desktop`   | Does it have a screen?      | bars, nordhealth    |
| `developer` | Do I code on it?            | bars, nordhealth    |
| `personal`  | Is it mine for fun?         | bars                |
| `work`      | Is it for work?             | nordhealth          |

Each trait only lists what it **adds** — no duplication. The full set is resolved at
template time by iterating all active traits.

Files are gated in `.chezmoiignore` — wrong-trait files are never deployed.

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
2. Add it to the right trait in `.chezmoidata/aliases.yaml` under `trait_aliases`
3. Run `chezmoi apply` or `dotfiles push "add <name> alias"`

---

### Add a new package to auto-install

Edit `.chezmoidata/packages.yaml` — add to the right trait:

```yaml
trait_packages:
  developer:         # or base / desktop / personal / work
    - new-tool                             # formula, same name on brew & apt
    - { name: x, apt: x-dev }             # different name on apt
    - { name: y, type: cask }             # brew cask (macOS only)
    - { name: z, type: cask, apt: z-app } # cask on macOS, apt name on Linux
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

To include an alias or config outside your traits, edit `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    include_aliases = ["music"]   # pull in music.sh even on a work machine
    exclude_aliases = ["tv"]      # skip tv.sh on a personal machine
    include_configs = ["mpv"]     # deploy mpv config on a non-personal machine
    exclude_configs = ["zed"]     # skip zed config on a developer machine
```

Then `chezmoi apply`.

---

## Repository Layout

```
dotfiles/
├── .chezmoi.toml.tmpl           # init wizard (prompts)
├── .chezmoidata/                # split data files:
│   ├── profiles.yaml            #   trait definitions + presets
│   ├── aliases.yaml             #   trait_aliases (delta per trait)
│   ├── configs.yaml             #   trait_configs (delta per trait)
│   └── packages.yaml            #   unified cross-platform packages
├── .chezmoiignore               # per-machine file exclusions (templated)
├── .chezmoiscripts/
│   ├── run_once_before_bootstrap.sh.tmpl
│   ├── run_onchange_install-packages.sh.tmpl   # brew / apt
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
├── dot_local/bin/               # → ~/.local/bin/ (all executable)
│   ├── executable_dotfiles      # CLI wrapper for chezmoi
│   ├── executable_bak           # timestamped file backup
│   ├── executable_extract       # universal archive extractor
│   ├── executable_json-fmt      # pretty-print JSON (jq wrapper)
│   ├── executable_myip          # show public + local IP
│   ├── executable_port-check    # check if host:port is open
│   ├── executable_vid-compress  # shrink video file size
│   ├── executable_vid-convert   # convert video formats
│   ├── executable_vid2gif       # convert video to GIF
│   ├── executable_ffmpeg-trim   # trim a video clip
│   ├── executable_img-convert   # convert image formats
│   ├── executable_screen-cap    # screen recording
│   ├── executable_git-clean-branches
│   ├── executable_tg-send       # send Telegram messages
│   └── executable_download-urls # batch yt-dlp downloader
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

---

## Secrets

Secrets are injected on demand via `dotfiles secrets` — never during normal `apply`/`diff`/`sync`. The command prompts for your KeePassXC master password once, then pulls all configured secrets into `~/.env`.

Currently managed secrets:
- **GitHub token** — from `Code/dotfiles/github-pat` (Password field)
- **Telegram bots** — auto-discovered from `Code/dotfiles/tg-*` entries

### Telegram bot setup

1. Create a KeePassXC entry `Code/dotfiles/tg-<botname>` with the bot token as Password
2. In the Notes field, define chats (one per line):
   ```
   chat-family: -1002457345563
   chat-personal: 789012345
   ```
3. Run `dotfiles secrets` to inject into `~/.env`
4. Send messages: `tg-send <bot> <chat> <message>`

Use `tg-send --discover <bot>` to find chat IDs — send a message to the bot first, then discover will list recent chats with their IDs.

---

## Utility Scripts & Functions

All scripts are in `~/.local/bin/` (on `$PATH`), available on every machine. Run any script with `-h` for detailed usage. Run `dotfiles utils` for a full list.

### Files & system

| Command | Description |
|---------|-------------|
| `bak <file>` | Timestamped backup (`file.bak.20260329-110000`) |
| `extract <archive>` | Universal extractor (tar/zip/gz/bz2/xz/7z/rar/zst) |
| `mkcd <dir>` | Create directory and cd into it (shell function) |
| `json-fmt [file]` | Pretty-print JSON from file or stdin |
| `myip` | Show public and local IP addresses |
| `port-check <host> <port>` | Check if host:port is reachable |

### Media

| Command | Description |
|---------|-------------|
| `vid-convert <in> <out>` | Convert video formats (tries stream copy first) |
| `vid-compress <in> [out]` | Shrink video keeping reasonable quality |
| `vid2gif [-s width] <in> <out>` | Convert video to GIF |
| `ffmpeg-trim <in> <start> <end>` | Trim a video clip |
| `img-convert` | Convert image formats (macOS sips) |
| `screen-cap` | Screen recording (macOS) |

### Messaging & downloads

| Command | Description |
|---------|-------------|
| `tg-send <bot> <chat> <msg>` | Send Telegram message via named bot and chat |
| `tg-send --discover <bot>` | List recent chats a bot can see |
| `download-urls <file>` | Batch download URLs with yt-dlp |

### Git & dev

| Command | Description |
|---------|-------------|
| `git-clean-branches` | Delete all non-protected local branches |

### fzf functions

Interactive fzf-powered helpers sourced from `~/.alias/fzf.sh` (all machines).

| Function | Description |
|----------|-------------|
| `fbr` | Switch git branch (sorted by recent, includes remotes) |
| `flog` | Browse git log with diff preview |
| `fga` | Stage changed files interactively |
| `dexec [shell]` | Exec into a running docker container |
| `dstop` | Stop docker containers (multi-select) |
| `dlogs` | Tail docker container logs |
| `drmi` | Remove docker images (multi-select) |
| `fkill [signal]` | Kill processes (multi-select) |
| `fcd [dir]` | cd into subdirectories with preview |
| `fssh` | SSH into a host from `~/.ssh/config` |
| `fenv` | Browse environment variable values |
| `fedit` | Edit config files in `~/.config/` or `~/.alias/` |
