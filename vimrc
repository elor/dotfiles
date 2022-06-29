" Comments in Vimscript start with a `"`.

" If you open this file in Vim, it'll be syntax highlighted for you.

" Vim is based on Vi. Setting `nocompatible` switches from the default
" Vi-compatibility mode and enables useful Vim functionality. This
" configuration option turns out not to be necessary for the file named
" '~/.vimrc', because Vim automatically enters nocompatible mode if that file
" is present. But we're including it here just in case this config file is
" loaded some other way (e.g. saved as `foo`, and then Vim started with
" `vim -u foo`).
"set nocompatible
if has("nvim")
  set termguicolors
else
  set term=xterm-256color
endif

" Turn on syntax highlighting.
syntax on

" Disable the default Vim startup message.
set shortmess+=I

" Show line numbers.
set number

" This enables relative line numbering mode. With both number and
" relativenumber enabled, the current line shows the true line number, while
" all other lines (above and below) are numbered relative to the current line.
" This is useful because you can tell, at a glance, what count is needed to
" jump up or down to a particular line, by {count}k to go up or {count}j to go
" down.
set relativenumber

" Always show the status line at the bottom, even if you only have one window open.
set laststatus=2

" The backspace key has slightly unintuitive behavior by default. For example,
" by default, you can't backspace before the insertion point set with 'i'.
" This configuration makes backspace behave more reasonably, in that you can
" backspace over anything.
set backspace=indent,eol,start

" By default, Vim doesn't let you hide a buffer (i.e. have a buffer that isn't
" shown in any window) that has unsaved changes. This is to prevent "
"you from "
" forgetting about unsaved changes and then quitting e.g. via `:qa!`. We find
" hidden buffers helpful enough to disable this protection. See `:help hidden`
" for more information on this.
set hidden

" This setting makes search case-insensitive when all characters in the string
" being searched are lowercase. However, the search becomes case-sensitive if
" it contains any capital letters. This makes searching more convenient.
set ignorecase
set smartcase

" Enable searching as you type, rather than waiting till you press enter.
set incsearch

" t_u7 stops vim from startiing in REPLACE mode in WSL
set t_u7=

" exrc allows loading local executing local rc files.
" " secure disallows the use of :autocmd, shell and write commands in local
" .vimrc files.
set exrc
set secure

" Unbind some useless/annoying default key bindings.
nmap Q<Nop> " 'Q' in normal mode enters Ex mode. You almost never want this.

" Disable audible bell because it's annoying.
set noerrorbells visualbell t_vb =

" Enable mouse support. You should avoid relying on this too much, but it can
" sometimes be convenient.
"set mouse+=a

" Try to prevent bad habits like using the arrow keys for movement. This is
" not the only possible bad habit. For example, holding down the h/j/k/l keys
" for movement, rather than using more efficient movement commands, is also a
" bad habit. The former is enforceable through a .vimrc, while we don't know
" how to prevent the latter.
" Do this in normal mode...
nnoremap<Left> : echoe "Use h" <CR>
nnoremap<Right> : echoe "Use l"<CR>
nnoremap<Up> : echoe "Use k" <CR>
nnoremap<Down> : echoe "Use j"<CR>
nnoremap<End> : echoe "Use $" <CR>
nnoremap<Home> : echoe "Use 0 or ^" <CR>

set wildignore+=*/tmp/*,*.so,*.swp,*.pyc,*.png,*.plist,*.aux
set wildignore+=*/obj/*,*/.git/*,*/build/*,*/node_modules/*,*/bin/*,*/testbin/*

let g:ctrlp_custom_ignore = '\v.(aux|plist)$'

set tabstop=2 expandtab shiftwidth=2 autoindent smartindent

augroup ebriigisto

  autocmd!
  autocmd FileType python setlocal tabstop=4 expandtab shiftwidth=4
  autocmd FileType make set noexpandtab tabstop=2 shiftwidth=2 softtabstop=0

  autocmd BufEnter * set concealcursor-=in

  " Install and run vim-plug on first run
  if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif

  au VimEnter * RainbowParenthesesToggle
  au Syntax * RainbowParenthesesLoadRound
  au Syntax * RainbowParenthesesLoadSquare
  au Syntax * RainbowParenthesesLoadBraces
augroup END


let g:rbpt_colorpairs = [
    \ ['brown',       'RoyalBlue3'],
    \ ['Darkblue',    'SeaGreen3'],
    \ ['darkgray',    'DarkOrchid3'],
    \ ['darkgreen',   'firebrick3'],
    \ ['darkcyan',    'RoyalBlue3'],
    \ ['darkred',     'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown',       'firebrick3'],
    \ ['gray',        'RoyalBlue3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['Darkblue',    'firebrick3'],
    \ ['darkgreen',   'RoyalBlue3'],
    \ ['darkcyan',    'SeaGreen3'],
    \ ['darkred',     'DarkOrchid3'],
    \ ['red',         'firebrick3'],
    \ ]

so ~/.vim/plugins.vim

let ale_linters = {
\  'c': ['clangcheck', 'clangtidy'],
\  'cpp': ['clangcheck', 'clangtidy'],
\  'python': ['pylint'],
\  'json': ['jsonlint'],
\  'markdown': ['alex', 'proselint', 'vale', 'writegood'],
\  'sh': ['shellcheck'],
\  'tex': ['alex', 'chktex', 'lacheck', 'proselint', 'vale', 'writegood'],
\  'vim': ['vint'],
\  'xml': ['xmllint'],
\  }

let ale_fixers = {
\  '*': ['trim_whitespace'],
\  'c': ['clangtidy', 'clang-format'],
\  'cpp': ['clangtidy', 'clang-format'],
\  'json': ['prettier'],
\  'markdown': ['prettier', 'textlint'],
\  'python': ['autopep8'],
\  'xml': ['xmllint'],
\}

let g:ale_open_list = 1
let g:ale_list_window_size = 5
let g:ale_c_parse_makefile = 1
let g:ale_fix_on_save = 1
let g:ale_lint_on_enter = 0

let g:NERDTreeGitStatusIndicatorMapCustom = {
  \ 'Modified'  :'m',
  \ 'Staged'    :'s',
  \ 'Untracked' :'u',
  \ 'Renamed'   :'r',
  \ 'Unmerged'  :'M',
  \ 'Deleted'   :'d',
  \ 'Dirty'     :'~',
  \ 'Ignored'   :'i',
  \ 'Clean'     :' ',
  \ 'Unknown'   :'?',
\ }

let g:vimspector_enable_mappings = 'HUMAN'

let g:ycm_autoclose_preview_window_after_insertion = 1

nmap <F7> :TagbarToggle<CR>
nmap ]e :ALENextWrap<CR>
nmap [e :ALEPreviousWrap<CR>

let g:loclist_follow = 1
let g:loclist_follow_target = 'nearest'

if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

set concealcursor-=in

"let g:tex_conceal = ""

