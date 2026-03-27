# Base Coding Rules

Applies on all machines and profiles.

## Python

- Use `uv` for tool installation (`uv tool install`), never `pip install` globally
- Use `ruff` for linting and formatting
- Use `ty` for type checking in Zed
- Virtual environments: `python -m venv venv` in project root

## Shell

- zsh on macOS, bash on Linux servers
- Alias files live in `~/.alias/`, sourced by `.zshrc`
- Keep aliases in domain-specific files (git.sh, docker.sh, etc.)

## Git

- Default branch name: `development`
- URL shortcuts: `gh:` for github.com, `pc:` for github.com/patillacode/
- Delta pager for diffs with the `patilla` theme

## Dotfiles

- Managed by chezmoi from `~/dotfiles` (source dir)
- Apply changes: `chezmoi apply`
- Edit managed file: `chezmoi edit <file>`
- Source dir: `~/dotfiles`
