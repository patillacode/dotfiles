#!/bin/bash
# Download all catppuccin mocha and macchiato yazi themes

BASE="https://raw.githubusercontent.com/catppuccin/yazi/refs/heads/main/themes"
COLORS=(blue flamingo green lavender maroon mauve pink red rosewater sapphire sky teal yellow)

for color in "${COLORS[@]}"; do
    for variant in mocha macchiato; do
        file="catppuccin-${variant}-${color}.toml"
        echo "Downloading $file..."
        curl -s "$BASE/$variant/$file" -o "$file"
    done
done

echo "Done. $(ls ./*.toml | wc -l) themes downloaded."
