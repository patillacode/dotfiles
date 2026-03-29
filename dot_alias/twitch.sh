# twitch.sh — Twitch and YouTube live streams

stream_twitch_channel() {
    streamlink --player mpv $1 best
}

alias frencho='streamlink --player mpv https://www.twitch.tv/frencho_13 best'
alias ibai='streamlink --player mpv https://www.twitch.tv/ibai best'
alias lec='mpv https://www.youtube.com/channel/UCWWZjhmokTbezUQr1kbbEYQ/live'
alias lvp='streamlink --player mpv https://www.twitch.tv/lvpes best'
alias pokerstars='mpv https://www.youtube.com/channel/UCGWkDcYbDKP9r--ym28YwAQ/live'
alias rito='streamlink --player mpv https://www.twitch.tv/riotgames best'
alias twitch='stream_twitch_channel'
alias twtv='stream_twitch_channel'
alias xokas='streamlink --player mpv https://www.twitch.tv/elxokas best'
