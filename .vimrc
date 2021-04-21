set nocompatible
syntax on
set encoding=utf8

"Vundle stuff needs to go here
filetype off
call plug#begin(stdpath('data') . '/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

"Automatic completion for braces and other open/close characters
Plug 'townk/vim-autoclose'
Plug 'ryanoasis/vim-devicons'

"Color schemes
Plug 'dracula/vim',{'as':'dracula'}
Plug 'morhetz/gruvbox'
Plug 'ajh17/Spacegray.vim'
Plug 'junk-e/identity.vim'
Plug 'Mizux/vim-colorschemes'
Plug 'camgunz/amber'
Plug 'kyoto-shift/film-noir'
Plug 'pcostasgr/red_alert_vim_theme'
Plug 'abnt713/vim-hashpunk'
Plug 'TroyFletcher/vim-colors-synthwave'

Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'scrooloose/nerdtree'

"Git support
Plug 'jreybert/vimagit'
Plug 'airblade/vim-gitgutter'

"Go support
"Use :GoUpdateBinaries to install/update local go tools if needed
Plug 'fatih/vim-go'

"Rust support
Plug 'rust-lang/rust.vim'

"Julia support; also adds LaTex '\' completion with TAB to *.jl files
Plug 'JuliaEditorSupport/julia-vim'

"Tag browsing; assumes some flavor of ctags is installed
"Underwhelmed by this rn...
"Plug 'majutsushi/tagbar'

"fzf integration
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

"Adds :BufOnly to close all buffers except the current one
Plug 'schickling/vim-bufonly'

"Makes <Leader>b display a listing of all buffers
Plug 'jeetsukumaran/vim-buffergator'

"Comment/uncomment a line with 'gcc', or a selection with 'gc'
Plug 'tpope/vim-commentary'

"Minimize visual noise with :Goyo and :Limelight
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

Plug 'tpope/vim-markdown'
Plug 'neui/cmakecache-syntax.vim'
Plug 'tpope/vim-surround'
Plug 'cespare/vim-toml'
Plug 'dag/vim-fish'

"Have vim insert a matching 'end', 'endif', 'endfunction', etc.
Plug 'tpope/vim-endwise'

"Perform autocompletion with just TAB
Plug 'ervandew/supertab'

"Autocompletion plugins
"This autocompletion is a little heavy for me; I'm commenting out for now...
"Plug 'Shougo/deoplete.nvim'
"Plug 'Shougo/neco-syntax'
"Plug 'Shougo/deoplete-clangx'
"Plug 'Shougo/neoinclude.vim'

"Automatic linting
"Plug  'neomake/neomake'
Plug 'dense-analysis/ale'

"Lightweight personal vim wiki
Plug 'vimwiki/vimwiki'

call plug#end()
filetype plugin indent on

"Remove warnings when switching between buffers that have yet to be written
"out
set hidden

"Characters used to represent whitespace
"N.B. use the command ':set list' to see these
set list listchars=tab:>-,space:·,trail:○,eol:↲,nbsp:▯
set nolist

"Set the title of the window the the file being edited
set title

"Makes y and p commands use the global copy/paster buffer
set clipboard+=unnamed

"Use `K` to split a line; i.e. opposite of `J`.
"From https://gist.github.com/romainl/3b8cdc6c3748a363da07b1a625cfc666
function! BreakHere()
	s/^\(\s*\)\(.\{-}\)\(\s*\)\(\%#\)\(\s*\)\(.*\)/\1\2\r\1\4\6
	call histdel("/", -1)
endfunction
nnoremap K :<C-u>call BreakHere()<CR>

"Autocomplete configuration
" let g:deoplete#enable_at_startup = 1

"Automatic linting configuration
let g:ale_sign_error='❌'
let g:ale_sign_warning='⚠️'
let g:ale_set_balloons=1
let g:ale_floating_preview=1

"Color config
set t_Co=256
set background=dark

if(has("termguicolors"))
  set termguicolors
endif

let base16colorspace=256

colorscheme gruvbox

let g:spacegray_underline_search=1
let g:spacegray_italicize_comments=1

"Needed to make spacegray colorscheme utilize transparent background
hi Normal guibg=NONE ctermbg=NONE
hi LineNr guibg=NONE ctermbg=NONE

"Vim-airline config
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#ale#enabled=1
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
"map <C-m> :TagbarToggle<CR>

"GitGutter configuration
highlight GitGutterAdd      guifg=#00ff00 ctermfg=10
highlight GitGutterChange   guifg=#ffff00 ctermfg=11
highlight GitGutterDelete   guifg=#ff0000 ctermfg=9
let g:gitgutter_sign_added = '++'
let g:gitgutter_sign_modified = 'ΔΔ'
let g:gitgutter_sign_removed = '--'
let g:gitgutter_sign_removed_first_line = '^^'
let g:gitgutter_sign_modified_removed = '~x'

"Shortcut for FZF file finder
nnoremap <C-p>    :Files<CR>

"Use arrows to resize splits instead of for navigation
nnoremap <Up>     :resize -2<CR>
nnoremap <Down>   :resize +2<CR>
nnoremap <Left>   :vertical resize -2<CR>
nnoremap <Right>  :vertical resize +2<CR>

"Shortcut for magit
nnoremap <leader>m :Magit<CR>

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

"Mouse support
set mouse=a

"File types for rare extensions
au BufReadPost *.zsh-theme set syntax=sh
au BufReadPost .clang-format set syntax=yaml
au BufReadPost .gitmessage set syntax=gitcommit

"Run the :RustFmt command on the buffer when its saved
let g:rustfmt_autosave = 1

