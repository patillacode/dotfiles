# misc.sh — fun stuff and games

figlet_all_fonts() {
    for font in $(pyfiglet -l); do
        echo $font
        figlet -f $font "hello world" || true
    done
}
alias figlet-all='figlet_all_fonts'

alias kk='curl -sL http://bit.ly/1A0iNjU | ruby -'
alias ludo='slot-machine' # this is a custom command under ~/projects/slot-machine
alias mm='cmatrix -b -C magenta -u 9'
alias sudoku='sku'        # this is a go command under ~/go/bin
alias wordle='clidle'     # this is a go command under ~/go/bin

alias radio='mpv https://radio.patilla.es/stream'
alias radio-totoro='mpv https://radio.patilla.es/stream'
