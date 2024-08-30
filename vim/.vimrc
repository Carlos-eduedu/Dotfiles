" Desabilitar as setas do teclado no modo normal
nnoremap <Up> <Nop>
nnoremap <Down> <Nop>
nnoremap <Left> <Nop>
nnoremap <Right> <Nop>

" Desabilitar as setasa do teclado no modo de inserção
inoremap <Up> <Nop>
inoremap <Down> <Nop>
inoremap <Left> <Nop>
inoremap <Right> <Nop>

" Desabilitar as setas no modo visual
vnoremap <Up> <Nop>
vnoremap <Down> <Nop>
vnoremap <Left> <Nop>
vnoremap <Right> <Nop>

" Mostrar o numero de linhas
set number
set relativenumber

" Habilitar o syntax highlighting
syntax on
filetype plugin indent on

" Habilitar o vim-plug
call plug#begin()
Plug 'catppuccin/vim', {'as': 'catppuccin'}
Plug 'itchyny/lightline.vim'
call plug#end()

" Definir o tema do vim
set termguicolors
colorscheme catppuccin_macchiato

" Definir o tema do lightline.vim
set laststatus=2
set noshowmode
let g:lightline = {'colorscheme': 'catppuccin_macchiato'}
