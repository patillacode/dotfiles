# music.sh — mpv playlists and YouTube music

alias xx="mpv https://youtu.be/65-r8BYWSjU https://youtu.be/Sl3xiIlNY3s"
alias ml="cd $HOME/media/music/ && mpv --no-video --shuffle ."

# alias fm="fzf --preview \"bat --color=always {}\" --bind 'enter:become(mpv {})'"
alias fm="fzf --preview \"bat --color=always {}\" --bind 'enter:become(echo {} && mpv {})'"

# YT Music
declare -A music
music=(
    ["local"]=""
    ["chill"]="https://youtu.be/EXXMtKPfuzY"
    ["hit"]="https://youtu.be/XnSdiCynPyk"
    ["01"]="https://www.youtube.com/playlist?list=PLD5EE8D3CF4FD749C"
    ["02"]="https://www.youtube.com/playlist?list=PL81CC6D5C5D20DDF1"
    ["03"]="https://www.youtube.com/playlist?list=PLOr27fEnfYc4aTRvo9f1irWIwCmhwR9re"
    ["04"]="https://www.youtube.com/playlist?list=PLOr27fEnfYc5beNIu1-eQQFbkKILhKvwW"
    ["05"]="https://www.youtube.com/playlist?list=PLOr27fEnfYc4z8sgyXqabmkBVA2PUfMtv"
    ["06"]="https://www.youtube.com/playlist?list=PLOr27fEnfYc7Og9bUULezaw1oYo6W-SsV"
    ["07"]="https://www.youtube.com/playlist?list=PLOr27fEnfYc4wE4iqgfMkmVPXYHJ2JOGU"
    ["08"]="https://www.youtube.com/playlist?list=PLOr27fEnfYc65Bp3VmDyyT22WT0dx8_s0"
    ["09"]="https://www.youtube.com/playlist?list=PLOr27fEnfYc4vo4uNDOKeWt3HUwaOJ_eL"
    ["10"]="https://www.youtube.com/playlist?list=PLOr27fEnfYc5a6p1auEgwWxGiGbe55rHR"
    ["11"]="https://www.youtube.com/playlist?list=PLOr27fEnfYc4clyejP7oZicst0x_Zi_jW"
    ["12"]="https://www.youtube.com/playlist?list=PLOr27fEnfYc6LSMYRbfgvcltV6vTI5QsX"
    ["13"]="https://www.youtube.com/playlist?list=PLOr27fEnfYc4t410HXh8Wkz-2EbCFuZ-u"
    ["14"]="https://www.youtube.com/playlist?list=PLOr27fEnfYc63bVpVJGkrfMUv8RPBPIaY"
    ["15"]="https://www.youtube.com/playlist?list=PLOr27fEnfYc45ZExrqQQD3vbjIK97KnYm"
    ["16"]="https://www.youtube.com/playlist?list=PLOr27fEnfYc6OTY26vdhgjFpkT-91T280"
)

# Function to play a random yt playlist
play_random_music() {
    local keys=("${(@k)music}")
    local random_key="${keys[(RANDOM % ${#keys[@]})+1]}"

    echo "Playing music from playlist: music $random_key"
    mpv --no-video --shuffle "${music[$random_key]}"
}

# Function to play a specific yt playlist
play_music() {
    echo "play_music $1"
    local playlist="$1"
    if [[ -z "${music[$playlist]}" ]]; then
        echo "Unknown playlist: $playlist"
        return 1
    fi
    mpv --no-video --shuffle "${music[$playlist]}"
}

# Music aliases
alias m="play_random_music"

alias chill="play_music chill"
alias hit="play_music hit"

alias music01="play_music 01"
alias music02="play_music 02"
alias music03="play_music 03"
alias music04="play_music 04"
alias music05="play_music 05"
alias music06="play_music 06"
alias music07="play_music 07"
alias music08="play_music 08"
alias music09="play_music 09"
alias music10="play_music 10"
alias music11="play_music 11"
alias music12="play_music 12"
alias music13="play_music 13"
alias music14="play_music 14"
alias music15="play_music 15"
alias music16="play_music 16"

alias hello='mpv --loop "$HOME/media/music/Music/Unknown Artist/BEST INSTRUMENTALS/Hello_beat.wav"'
