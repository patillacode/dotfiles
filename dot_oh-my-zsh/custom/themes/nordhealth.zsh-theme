end_symbol=""
# venv_symbol=""
venv_symbol="󰌠 "
# initial_symbol="∫"
# initial_symbol="λ"
# initial_symbol="∞"
initial_symbol="• "
# initial_symbol=" "
# initial_symbol=""
# initial_symbol="Đ"
# initial_symbol=" "
# initial_symbol=" "
git_symbol=" "
# git_symbol=""
# git_symbol=""
# git_symbol=""
# git_symbol=""
git_dirty_symbol=""
# git_dirty_symbol="⨯"
# git_dirty_symbol="✗"
# git_dirty_symbol=""
# git_dirty_symbol=""
# git_dirty_symbol="☠"
home_symbol=" "
projects_symbol=" "
# projects_symbol=" "
# projects_symbol=" "
media_symbol=" "
torrents_symbol=" "



prompt_segment () {
    local bg fg
    [[ -n $1 ]] && bg="%K{$1}"  || bg="%k"
    [[ -n $2 ]] && fg="%F{$2}"  || fg="%f"
    if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]
    then
        echo -n "%{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%}"
    else
        echo -n "%{$bg%}%{$fg%}"
    fi
    CURRENT_BG=$1
    [[ -n $3 ]] && echo -n $3
}

prompt_virtualenv () {
    local virtualenv_path="$VIRTUAL_ENV"
    if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]
    then
        prompt_segment transparent yellow $venv_symbol
    # else
    #     prompt_segment transparent white $initial_symbol
    fi
}

prompt_directory() {
    current_dir=$(pwd)

    if [[ "$current_dir" == "$HOME" ]]; then
        prompt_segment transparent cyan $home_symbol
    elif [[ $current_dir == "$HOME/projects" ]]; then
        prompt_segment transparent cyan $projects_symbol
    elif [[ $current_dir == "$HOME/media" ]]; then
        prompt_segment transparent cyan $media_symbol
    elif [[ $current_dir == "$HOME/media/torrents" ]]; then
        prompt_segment transparent cyan $torrents_symbol
    else
        current_dir=$(basename "$current_dir")
        prompt_segment transparent cyan "$current_dir "
    fi
}

build_prompt() {
    # Call all the prompt functions to build the actual prompt
    prompt_virtualenv
    prompt_directory
    # prompt_segment transparent yellow ""
}

# Assign the PROMPT variable with the function, so bash call it everytime
# Single quotes are important here, else you will get a fixed PROMPT
# Without single quotes, the function will be called once and evaluated value
# will be assigned
PROMPT='$(build_prompt)'
PROMPT+='$(git_prompt_info)%{$reset_color%}'
PROMPT+='%F{cyan}$end_symbol%f '

ZSH_THEME_GIT_PROMPT_PREFIX="%F{red}$git_symbol%F{red}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{blue}%f%F{yellow} $git_dirty_symbol%f "
ZSH_THEME_GIT_PROMPT_CLEAN=""
