# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io) — one repo, macOS and Debian Linux, multiple machines.

**Primary remote:** `https://forgejo.patilla.es/patillacode/dotfiles.git`

**Mirror:** `https://github.com/patillacode/dotfiles`

---

## Fresh Install

### One-liner (new machine)

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --source ~/dotfiles https://forgejo.patilla.es/patillacode/dotfiles.git
```

This installs chezmoi, clones the repo, runs the interactive setup, and applies everything.

### What the setup wizard asks

When running `chezmoi init` for the first time you'll be prompted for:

1. **Machine name** — used throughout configs and prompts
2. **Shell** — `zsh` or `bash` (Linux only; macOS always uses zsh)
3. **Personal or work machine?** — sets `personal` or `work` trait
4. **Does it have a GUI / screen?** — sets `gui` trait; skips desktop-only packages on headless machines
5. **Starship theme** — choose from 13+ themes (default: `simple`)
6. **Git name & email** — used in `~/.config/git/config`
7. **KeePassXC database path** — full path to your `.kdbx` file
8. **Font family & size** — used in Ghostty and Zed (GUI machines only)

Answers are saved in `~/.config/chezmoi/chezmoi.toml` and reused on subsequent runs.

### Migrating from old setups

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

## How It Works

### The trait system

Each machine selects a set of independent traits. Traits compose — a machine just has whichever apply.

| Trait | Question | Gets |
|-------|----------|------|
| `base` | Does this machine exist? | All CLI tools, dev tools, git, SSH, nvim, claude |
| `gui` | Does it have a screen? | Ghostty, Zed, GUI-only apps |
| `personal` | Is it mine for fun? | Personal identity, SSH keys, entertainment tools |
| `work` | Is it for work? | Work git identity, work rules |

`personal + gui` together also add entertainment: music/tv/twitch aliases, mpv, yt-dlp.

Each trait only lists what it adds — no duplication. The full set is resolved at template time by iterating all active traits.

Files are gated in `.chezmoiignore` — wrong-trait files are never deployed to disk.

### OS differences

chezmoi handles macOS/Linux automatically:

- **Packages:** brew (+ casks on macOS) vs apt
- **Shell:** zsh on macOS; bash or zsh on Linux (your choice at init)
- **GUI-only packages** (casks) are skipped on Linux machines without the `gui` trait

### Per-machine overrides

To include an alias or config outside your traits without changing trait membership, edit `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    include_aliases = ["music"]   # pull in music.sh even on a work machine
    exclude_aliases = ["tv"]      # skip tv.sh
    include_configs = ["mpv"]     # deploy mpv config on a non-personal machine
    exclude_configs = ["zed"]     # skip zed config
```

Then `chezmoi apply`.

---

## Quick Reference

### dotfiles CLI (`dt` / `dots`)

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

`chezmoi apply`, `chezmoi diff`, and `chezmoi edit ~/.zshrc` all work directly too.

---

## How To

### Add a new managed file

chezmoi tracks source files, not symlinks — add a file to the source directory and it deploys on `apply`.

```bash
# Copy an existing file into the source dir
chezmoi add ~/.config/tool/config

# Or create it manually in the source dir
# dot_config/tool/config → ~/.config/tool/config
chezmoi apply
```

### Check if a file is tracked

```bash
chezmoi status ~/.config/tool/config   # shows status code if tracked, nothing if not
chezmoi managed | grep <filename>      # search across all tracked files
```

Status codes: `A` added · `M` modified · `D` deleted · `R` re-added.

### Modify an existing managed file

Edits go to the source directory; `apply` deploys them.

```bash
chezmoi edit ~/.zshrc   # opens source file in $EDITOR
chezmoi apply
```

Or edit the source file directly in `~/dotfiles/` and run `chezmoi apply`.

### Add a package

Packages are auto-installed when the list hash changes on `chezmoi apply`.

Edit `.chezmoidata/packages.yaml` — add to the right trait:

```yaml
trait_packages:
  base:           # or gui / personal / work
    - new-tool
    - { name: x, apt: x-dev }             # different name on apt
    - { name: y, type: cask }             # brew cask (macOS only)
    - { name: z, type: cask, apt: z-app } # cask on macOS, apt name on Linux
```

Then `chezmoi apply`.

### Remove a package

The install script only adds — it doesn't uninstall. Remove the line from `.chezmoidata/packages.yaml`, then uninstall manually with `brew remove` or `apt remove`.

### Add a new alias file

Alias files live in `dot_alias/` and are sourced based on active traits.

1. Create `dot_alias/<name>.sh` in the repo
2. Add `<name>` to the right trait in `.chezmoidata/aliases.yaml` under `trait_aliases`
3. `chezmoi apply`

### Add an alias to an existing file

The alias files are plain shell files — just edit them.

```bash
chezmoi edit ~/.alias/git.sh
chezmoi apply
```

### Remove an alias

Delete or comment out the line from the relevant file in `dot_alias/`, then `chezmoi apply`. The shell will stop sourcing it on the next session.

### Set up a new machine

Run the one-liner from Fresh Install. The wizard asks the right questions and handles everything else.

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --source ~/dotfiles https://forgejo.patilla.es/patillacode/dotfiles.git
```

Once packages are installed, run the interactive configuration wizard for a polished setup experience:

```bash
dotfiles setup
```

This reads all current values as defaults (safe to re-run at any time to reconfigure).

### Update an existing machine after a repo change

Pull and re-apply — chezmoi diffs against deployed state and only touches what changed.

```bash
dotfiles sync
# or
git -C ~/dotfiles pull && chezmoi apply
```

### Switch Starship theme

The prompt theme is set in `chezmoi.toml` and re-applied by chezmoi.

```bash
dotfiles theme   # interactive fzf picker
```

Or manually edit `~/.config/chezmoi/chezmoi.toml`:

```toml
[data.starship]
    theme = "catppuccin"
```

Then `chezmoi apply`.

Available themes: `simple` · `minimal` · `zenful` · `nerd-font-symbols` · `gruvbox` · `catppuccin` · `dracula` · `nord` · `tokyo-night` · `pastel` · `tops` · `totoro` · `ushuaia`

### Inject secrets from KeePassXC

Secrets are pulled on demand into `~/.env` — they're never part of normal apply.

```bash
dotfiles secrets   # prompts for master password once, writes ~/.env
```

### Change font (Ghostty + Zed)

Both apps read font settings from `chezmoi.toml` via templates — one change updates both.

Edit `~/.config/chezmoi/chezmoi.toml`:

```toml
[data.font]
    family = "JetBrainsMono Nerd Font Propo"
    size = 16
```

Then `chezmoi apply`.

---

## Repository Structure

```
dotfiles/
├── .chezmoi.toml.tmpl           # init wizard (prompts)
├── .chezmoidata/                # split data files:
│   ├── profiles.yaml            #   trait definitions
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

## Trait Reference

What each trait deploys:

| | `base` | `gui` | `personal` | `work` |
|-|--------|-------|------------|--------|
| **aliases** | ai, atuin, docker, fzf, git, misc, ssh, system, tmux, utils | ghostty | music, tv, twitch (`personal+gui` only) | — |
| **configs** | atuin, btop, claude, gh, git, nvim, starship, tmux | ghostty, zed | mpv, yt-dlp (`personal+gui` only) | — |
| **packages** | atuin, bat, btop, chezmoi, duf, eza, fastfetch, fd, fzf, gcc, gh, git-delta, git-lfs, glow, gum, jq, n, neovim, prek, ripgrep, rtk, ruff, starship, tmux, uv, wget | ghostty, keepassxc, raycast, rectangle, sf-symbols, stats | cmatrix, ffmpeg, ffmpegthumbnailer, figlet, imagemagick, mpv, ollama, poppler, streamlink, yt-dlp, firefox, jordanbaird-ice, nextcloud, telegram, transmission, vlc, zen | zen |

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
