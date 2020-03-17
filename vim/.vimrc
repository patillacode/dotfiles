syntax enable
colorscheme monokai

set number relativenumber   " set both current line number and realtive ones

" tabs/spaces
set softtabstop=4
set tabstop=4
set expandtab

set cursorline              " highlight current line
set showmatch               " highlight matching [{()}]
set wildmenu                " visual autocomplete for command menu

set incsearch               " search as characters are entered
set hlsearch                " highlight matches
" turn off search highlight
nnoremap <leader><space> :nohlsearch<CR>

" remove trailing spaces
nnoremap tr :%s/\s\+$//

