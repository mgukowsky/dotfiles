set nocompatible
syntax on
set encoding=utf8

"Vundle stuff needs to go here
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

"Automatic completion for braces and other open/close characters
Plugin 'townk/vim-autoclose'
Plugin 'ryanoasis/vim-devicons'
Plugin 'airblade/vim-gitgutter'
Plugin 'ajh17/Spacegray.vim'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'scrooloose/nerdtree'

"Tag browsing; assumes some flavor of ctags is installed
Plugin 'majutsushi/tagbar'

"Perform autocompletion with just TAB
Plugin 'ervandew/supertab'
Plugin 'tpope/vim-markdown'
Plugin 'neui/cmakecache-syntax.vim'
Plugin 'tpope/vim-surround'
Plugin 'cespare/vim-toml'
Plugin 'dag/vim-fish'

call vundle#end()
filetype plugin indent on

"Characters used to represent whitespace
"N.B. use the command ':set list' to see these
set list listchars=tab:>-,trail:·,eol:↲
set nolist

"Color config
set t_Co=256
set background=dark

if(has("termguicolors"))
  set termguicolors
endif

let base16colorspace=256

colorscheme spacegray

let g:spacegray_underline_search=1
let g:spacegray_italicize_comments=1

"Needed to make spacegray colorscheme utilize transparent background
hi Normal guibg=NONE ctermbg=NONE
hi LineNr guibg=NONE ctermbg=NONE

"Vim-airline config
let g:airline#extensions#tabline#enabled=1
let g:airline_powerline_fonts=1
let g:airline_theme='hybrid'
let g:hybrid_custom_term_colors=1
let g:hybrid_reduced_contrast=1

"Enable better searching and tab completion for files
set path+=**
set wildmenu

"NERDTree configuration
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1

"Tagbar configuration
map <C-m> :TagbarToggle<CR>

"GitGutter configuration
highlight GitGutterAdd      guifg=#00ff00 ctermfg=10
highlight GitGutterChange   guifg=#ffff00 ctermfg=11
highlight GitGutterDelete   guifg=#ff0000 ctermfg=9
let g:gitgutter_sign_added = '++'
let g:gitgutter_sign_modified = '~~'
let g:gitgutter_sign_removed = '--'
let g:gitgutter_sign_removed_first_line = '^^'
let g:gitgutter_sign_modified_removed = '~-'

"Use arrows to resize splits instead of for navigation
nnoremap <Up>     :resize -2<CR>
nnoremap <Down>   :resize +2<CR>
nnoremap <Left>   :vertical resize -2<CR>
nnoremap <Right>  :vertical resize +2<CR>

"Set the timeout for keycode delays (i.e. for quick ESC responses)
"See https://www.johnhawthorn.com/2012/09/vi-escape-delays/
set timeoutlen=1000 ttimeoutlen=10

"Have vim update buffers every second (allows GitGutter to refresh) 
set updatetime=1000

"Tab configuration
set shiftwidth=2
set softtabstop=2
set tabstop=2
set autoindent
set expandtab
set nosmartindent
set nocindent

"Rulers
set colorcolumn=100

"Misc
set number
set showcmd
set cursorline
set showmatch
set incsearch
set hlsearch

"File types for rare extensions
au BufReadPost *.zsh-theme set syntax=sh
au BufReadPost .clang-format set syntax=yaml
au BufReadPost .gitmessage set syntax=gitcommit

"Run clang-format before saving
au BufWrite *.c,*.cpp,*.cxx,*.h,*.hpp,*.hxx %!clang-format

