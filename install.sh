#!/usr/bin/env bash
# install.sh — bootstrap dotfiles on a fresh machine
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/patillacode/dotfiles/main/install.sh)
# Or after cloning: bash install.sh

set -e

DOTFILES_REPO="https://github.com/patillacode/dotfiles.git"

# ── Step 1: Detect OS ─────────────────────────────────────────

if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

echo "Detected OS: $OS"

# ── Step 2: Install Homebrew ──────────────────────────────────

if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ "$OS" == "macos" ]]; then
        if [[ "$(uname -m)" == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
else
    echo "Homebrew already installed."
fi

# ── Step 3: Install gum ───────────────────────────────────────

if ! command -v gum &>/dev/null; then
    echo "Installing gum..."
    brew install gum
else
    echo "gum already installed."
fi

# ── Step 4: Welcome screen ────────────────────────────────────

_ok()   { gum style --foreground 2 "  ✓ $1"; }
_step() { gum style --foreground 36 --bold "→ $1"; }
_dim()  { gum style --foreground 8 "  $1"; }

gum style \
    --border double \
    --border-foreground 36 \
    --padding "1 4" \
    --margin "1 2" \
    --bold \
    "dotfiles installer" \
    "" \
    "This will set up your development environment." \
    "Homebrew + chezmoi + all tools + configs."

gum confirm "Ready to begin?" || { echo "Aborted."; exit 0; }

# ── Step 5: Install chezmoi ───────────────────────────────────

_step "Checking chezmoi..."
if ! command -v chezmoi &>/dev/null; then
    _dim "Installing chezmoi..."
    brew install chezmoi
    _ok "chezmoi installed"
else
    _ok "chezmoi already installed"
fi

# ── Step 6 + 7: chezmoi init --apply ─────────────────────────

_step "Initialising chezmoi..."
_dim "You will be prompted for machine configuration."
_dim "Follow the prompts — press Enter to accept defaults."
echo ""
chezmoi init --apply "$DOTFILES_REPO"

# ── Step 8: Summary ───────────────────────────────────────────

gum style \
    --border rounded \
    --border-foreground 2 \
    --padding "1 3" \
    --margin "1 2" \
    "$(gum style --foreground 2 --bold '✓ dotfiles installed!')" \
    "" \
    "Open a new terminal to activate your shell config." \
    "Run 'dotfiles status' to verify everything is set up."
