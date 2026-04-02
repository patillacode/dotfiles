#!/bin/bash
# Pick a catppuccin yazi theme with fzf and apply it

THEMES_DIR="$(dirname "$0")"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/yazi/theme.toml"

chosen=$(ls "$THEMES_DIR"/*.toml | xargs -n1 basename | fzf --prompt="yazi theme > " --preview="cat $THEMES_DIR/{}")

[ -z "$chosen" ] && exit 0

cp "$THEMES_DIR/$chosen" "$TARGET"
echo "Applied: $chosen"
