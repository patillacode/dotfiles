#!/usr/bin/env bash
# tui.sh — shared TUI helpers for dotfiles scripts
# Source this file: source "${HOME}/.local/lib/tui.sh"

# ─── Layer 1: Style constants ────────────────────────────────
RESET=$'\e[0m'
BOLD=$'\e[1m'
DIM=$'\e[2m'
CYAN=$'\e[0;36m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
RED=$'\e[0;31m'
BOLD_CYAN=$'\e[1;36m'

# ─── Layer 2: Typography helpers ─────────────────────────────

_header() {
    printf "\n%s%s%s\n" "${BOLD_CYAN}" "$1" "${RESET}"
}

_section() {
    printf "%s%s%s\n" "${DIM}" "$1" "${RESET}"
}

_ok() {
    printf "%s✓ %s%s\n" "${GREEN}" "$1" "${RESET}"
}

_warn() {
    printf "%s! %s%s\n" "${YELLOW}" "$1" "${RESET}"
}

_fail() {
    printf "%s✗ %s%s\n" "${RED}" "$1" "${RESET}"
}

_item() {
    printf "%s%-16s%s %s\n" "${DIM}" "$1" "${RESET}" "$2"
}

_dim() {
    printf "%s%s%s\n" "${DIM}" "$1" "${RESET}"
}

_hr() {
    printf "%s%s%s\n" "${DIM}" "----------------------------------------" "${RESET}"
}

# ─── Layer 3: Gum theme env vars ─────────────────────────────

export GUM_CHOOSE_CURSOR_FOREGROUND="36"
export GUM_CHOOSE_SELECTED_FOREGROUND="36"
export GUM_CONFIRM_PROMPT_FOREGROUND="36"
export GUM_CONFIRM_SELECTED_BACKGROUND="36"
export GUM_INPUT_CURSOR_FOREGROUND="36"
export GUM_INPUT_PROMPT_FOREGROUND="36"
export GUM_SPIN_SPINNER_FOREGROUND="36"
export GUM_SPIN_SPINNER="dot"

# ─── Layer 3: Gum wrappers ───────────────────────────────────

_require_gum() {
    if ! command -v gum &>/dev/null; then
        _fail "gum is required. Install: brew install gum"
        exit 1
    fi
}

_menu() {
    local prompt="$1"
    shift
    gum choose --header="$prompt" "$@"
}

_confirm() {
    gum confirm "$1"
}

_input() {
    gum input --placeholder="${2:-}" --prompt="$1 > "
}

_password() {
    gum input --password --prompt="$1 > "
}

_spinner() {
    local msg="$1"
    shift
    gum spin --title="$msg" --spinner=dot -- "$@"
}
