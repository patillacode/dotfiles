# ghostty.sh — terminal shaders and utilities

function enable_shader() {
    shader_name=$1
    config_file="$HOME/.config/ghostty/config"
    config_line="custom-shader = shaders/$shader_name.glsl"
    if ! grep -q "^$config_line" "$config_file"; then
        echo "$config_line" >> "$config_file"
    fi
    echo -e "\n${YELLOW}󰚩${CYAN} $shader_name shader enabled (reload config with cmd+shift+R) ${YELLOW}󰚩${NC}"
}
function disable_shader() {
    shader_name=$1
    config_file="$HOME/.config/ghostty/config"
    config_line="custom-shader = shaders\/$shader_name.glsl"
    if grep -q "^$config_line" "$config_file"; then
        echo "Disabling $shader_name"
        sed -i '' "/^$config_line/d" "$config_file"
    fi
    echo -e "\n${YELLOW}󰚩${CYAN} $shader_name shader disabled (reload config with cmd+shift+R) ${YELLOW}󰚩${NC}"
}

alias glow-on="enable_shader bloom"
alias glow-off="disable_shader bloom"
alias matrix-on="enable_shader matrix-hallway"
alias matrix-off="disable_shader matrix-hallway"
alias scanline-on="enable_shader scanline"
alias scanline-off="disable_shader scanline"


function ghostty_find() {
  osascript -e 'tell application "System Events" to keystroke "cat "'
  osascript -e 'tell application "System Events" to keystroke "j" using {command down, option down, shift down}'
  osascript -e 'tell application "System Events" to keystroke " | fzf --wrap"'
  osascript -e 'tell application "System Events" to key code 36'
}

# zle -N ghostty_find
# bindkey '^g' ghostty_find

alias ff=ghostty_find
