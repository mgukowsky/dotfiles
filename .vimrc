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
Plug 'wadackel/vim-dogrun'
Plug 'joshdick/onedark.vim'
Plug 'arcticicestudio/nord-vim'
Plug 'Rigellute/rigel'
Plug 'sainnhe/edge'
Plug 'cocopon/iceberg.vim'
Plug 'sainnhe/gruvbox-material'
Plug 'sickill/vim-monokai'

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

"Tag browsing/code outlining
" Plug 'liuchengxu/vista.vim'

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

"Makes y and p commands use the global copy/paster buffer.
"
"N.B. this probably won't play well with vim sessions over SSH. To copy in
"such scenarios, either X11 forward hold SHIFT while click-dragging the mouse
"to select and then copy-paste (can also enter `:set nonumber` to remove line
"numbers first)
set clipboard+=unnamedplus

"Use `K` to split a line; i.e. opposite of `J`.
"From https://gist.github.com/romainl/3b8cdc6c3748a363da07b1a625cfc666
function! BreakHere()
	s/^\(\s*\)\(.\{-}\)\(\s*\)\(\%#\)\(\s*\)\(.*\)/\1\2\r\1\4\6
	call histdel("/", -1)
endfunction
nnoremap K :<C-u>call BreakHere()<CR>

"Easy buffer navigation
nnoremap <C-h>  :bp<CR>
nnoremap <C-l>  :bn<CR>

"Searches for the word under the cursor; requires FZF
"Mappings are based on default vim bindings
nnoremap <leader>w  yw:Rg <C-r>"<CR>
nnoremap <leader>a  yW:Rg <C-r>"<CR>

"Autocomplete configuration
" let g:deoplete#enable_at_startup = 1

"Automatic linting configuration
let g:ale_sign_error='!!'
let g:ale_sign_warning='??'
let g:ale_set_balloons=1
let g:ale_floating_preview=1
let g:ale_completion_enabled=1
let g:ale_fix_on_save=1

let g:ale_fixers = {
\  '*': ['trim_whitespace'],
\  'javascript': ['eslint'],
\  'cpp': ['clang-format'],
\  'rust': ['rustfmt'],
\}

"Use C-k and C-j to navigate between ALE errors
" nmap <silent> <C-k> <Plug>(ale_previous_wrap)
" nmap <silent> <C-j> <Plug>(ale_next_wrap)

"Use ALE's symbol lookup instead of ctags
nnoremap <C-]>  :ALEGoToDefinition<CR>

"TODO: make these automatically pop up when hovering the cursor
nnoremap <leader>]  :ALEHover<CR>
nnoremap <leader>i  :ALEDetail<CR>
"N.B. use :lopen to view the loclist/quickfix list in a new window
"i.e.: https://dmerej.info/blog/post/lets-have-a-pint-of-vim-ale/#the-location-list

"Don't run the linters at all; I find them too noisy.
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_enter = 0
let g:ale_lint_on_filetype_changed = 0
let g:ale_lint_on_save = 0

"ALE will still have autocompletion, but it will take 5 seconds to kick in.
"This prevents having to hit escape twice to return to normal mode from insert
"mode while typing (i.e. once to exit autocompletion, again to exit insert mode).
let g:ale_completion_delay = 5000

"Color config
set t_Co=256
set background=dark

if(has("termguicolors"))
  set termguicolors
endif

let base16colorspace=256

colorscheme dracula

let g:spacegray_underline_search=1
let g:spacegray_italicize_comments=1

"Needed to make spacegray colorscheme utilize transparent background
hi Normal guibg=NONE ctermbg=NONE
hi LineNr guibg=NONE ctermbg=NONE

"Make limelight OK with our transparent background
let g:limelight_conceal_ctermfg="DarkGray"
let g:limelight_conceal_guifg="DarkGray"

"Invoke Limelight as part of Goyo
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

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

"Outline configuration
"map <C-m> :Vista!!<CR>
""Prefer ale integration over ctags
"let g:vista_default_executive = 'ale'
"let g:vista#renderer#enable_icon = 1
"let g:vista_sidebar_width = 60
"let g:vista_echo_cursor_strategy = 'both'

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
set exrc
set secure

"Mouse support
set mouse=a

"File types for rare extensions
au BufReadPost *.manifest set syntax=xml
au BufReadPost *.zsh-theme set syntax=sh
au BufReadPost .clang-format set syntax=yaml
au BufReadPost .gitmessage set syntax=gitcommit

"Run the :RustFmt command on the buffer when its saved
let g:rustfmt_autosave = 1

