# music.sh — local and Navidrome (Subsonic API) music playback

_nav_check() {
    if [[ -z "$NAVIDROME_USER" || -z "$NAVIDROME_PASS" ]]; then
        echo "Navidrome credentials not set — run: dotfiles secrets"
        return 1
    fi
}

_nav() {
    curl -sf "https://navidrome.patilla.es/rest/$1?u=${NAVIDROME_USER}&p=${NAVIDROME_PASS}&v=1.16.1&c=dotfiles&f=json${2:+&$2}"
}

_nav_play() {
    local tmp count=0
    tmp=$(mktemp /tmp/music-XXXXX.m3u)
    while IFS= read -r id; do
        [[ -z "$id" ]] && continue
        printf 'https://navidrome.patilla.es/rest/stream?id=%s&u=%s&p=%s&v=1.16.1&c=dotfiles\n' \
            "$id" "$NAVIDROME_USER" "$NAVIDROME_PASS" >> "$tmp"
        (( count++ ))
    done
    echo "Playing $count songs"
    mpv --no-video --shuffle "$tmp"
    rm -f "$tmp"
}

music-random() {
    _nav_check || return 1
    _nav getRandomSongs "size=50" \
        | python3 -c 'import sys,json; [print(s["id"]) for s in json.load(sys.stdin)["subsonic-response"]["randomSongs"].get("song",[])]' \
        | _nav_play
}
alias mr=music-random

music-playlists() {
    _nav_check || return 1
    _nav getPlaylists \
        | python3 -c 'import sys,json; [print(p["name"]) for p in json.load(sys.stdin)["subsonic-response"]["playlists"].get("playlist",[])]'
}
alias mpl=music-playlists

music-genres() {
    _nav_check || return 1
    _nav getGenres \
        | python3 -c 'import sys,json; [print(g["value"]) for g in sorted(json.load(sys.stdin)["subsonic-response"]["genres"].get("genre",[]), key=lambda x: -x.get("songCount",0))]'
}
alias mgl=music-genres

music-playlist() {
    _nav_check || return 1
    local selection playlist_id name
    selection=$(_nav getPlaylists \
        | python3 -c 'import sys,json; [print(p["name"]+"\t"+p["id"]) for p in json.load(sys.stdin)["subsonic-response"]["playlists"].get("playlist",[])]' \
        | fzf --with-nth=1 --delimiter=$'\t' --prompt="Playlist: ")
    [[ -z "$selection" ]] && return 0
    playlist_id=$(printf '%s' "$selection" | cut -f2)
    name=$(printf '%s' "$selection" | cut -f1)
    echo "Loading playlist: $name"
    _nav getPlaylist "id=$playlist_id" \
        | python3 -c 'import sys,json; [print(s["id"]) for s in json.load(sys.stdin)["subsonic-response"]["playlist"].get("entry",[])]' \
        | _nav_play
}
alias mp=music-playlist

music-genre() {
    _nav_check || return 1
    local genre encoded
    genre=$(music-genres | fzf --prompt="Genre: ")
    [[ -z "$genre" ]] && return 0
    encoded=$(printf '%s' "$genre" | python3 -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))')
    echo "Loading genre: $genre"
    _nav getSongsByGenre "genre=${encoded}&count=100" \
        | python3 -c 'import sys,json; [print(s["id"]) for s in json.load(sys.stdin)["subsonic-response"]["songsByGenre"].get("song",[])]' \
        | _nav_play
}
alias mg=music-genre

music-search() {
    _nav_check || return 1
    local query encoded selection type_id type id
    printf "Search: "
    read -r query
    [[ -z "$query" ]] && return 0
    encoded=$(printf '%s' "$query" | python3 -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))')
    selection=$(_nav search3 "query=${encoded}&artistCount=10&albumCount=10&songCount=30" \
        | python3 -c '
import sys,json
d=json.load(sys.stdin)["subsonic-response"]["searchResult3"]
for a in d.get("artist",[]):
    print("[artist] "+a["name"]+"\tartist:"+a["id"])
for a in d.get("album",[]):
    print("[album]  "+a["name"]+" — "+a.get("artist","")+"\talbum:"+a["id"])
for s in d.get("song",[]):
    print("[song]   "+s.get("title","")+" — "+s.get("artist","")+"\tsong:"+s["id"])
' | fzf --with-nth=1 --delimiter=$'\t' --prompt="Select: ")
    [[ -z "$selection" ]] && return 0
    type_id=$(printf '%s' "$selection" | cut -f2)
    type="${type_id%%:*}"
    id="${type_id#*:}"

    case "$type" in
        artist)
            local album_selection album_id album_name
            album_selection=$(_nav getArtist "id=$id" \
                | python3 -c '
import sys,json
albums=json.load(sys.stdin)["subsonic-response"]["artist"].get("album",[])
for a in albums:
    year=" ("+str(a["year"])+")" if a.get("year") else ""
    print(a["name"]+year+"\t"+a["id"])
' | fzf --with-nth=1 --delimiter=$'\t' --prompt="Album: ")
            [[ -z "$album_selection" ]] && return 0
            album_id=$(printf '%s' "$album_selection" | cut -f2)
            album_name=$(printf '%s' "$album_selection" | cut -f1)
            echo "Loading album: $album_name"
            _nav getAlbum "id=$album_id" \
                | python3 -c 'import sys,json; [print(s["id"]) for s in json.load(sys.stdin)["subsonic-response"]["album"].get("song",[])]' \
                | _nav_play
            ;;
        album)
            local name
            name=$(printf '%s' "$selection" | cut -f1)
            echo "Loading album: $name"
            _nav getAlbum "id=$id" \
                | python3 -c 'import sys,json; [print(s["id"]) for s in json.load(sys.stdin)["subsonic-response"]["album"].get("song",[])]' \
                | _nav_play
            ;;
        song)
            printf '%s\n' "$id" | _nav_play
            ;;
    esac
}
alias ms=music-search

music-local() {
    mpv --no-video --shuffle "$HOME/media/music/"
}
alias ml=music-local

music-browse() {
    fzf --preview "bat --color=always {}" --bind 'enter:become(echo {} && mpv {})'
}
alias fm=music-browse
