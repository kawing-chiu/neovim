"""""" Notes
" 1. If in trouble, you can run :checkhealth for a health check.
" 2. Don't forget to install pynvim.
" 3. Run :PlugInstall to install plugins.
" 4. Run :messages to see all warning/error messages.


"""""" Options for this script
""" Set to 1 to enable debug output.
let s:debug = 0

""" External dependencies
" Dependencies listed here will be check for existence. A warning is issued if
" not exist.
"   - ctags: Universal-ctags. This is required for tagbar to work correctly.
"   - pyls: Language server for Python.
let s:external_dependencies = ['ctags', 'pyls']

""" Optional External dependencies
" Dependencies listed here will only be check if debug is enabled. These are
" mostly language servers.
"   - clangd: Langauge server for C++.
let s:optional_external_dependencies = ['clangd']


"""""" Helper functions
""" Echo message with extra info
" Get current script name, <sfile> is the current script or funcion name, :t
" means to get the filename only, not full path.
let s:this_file_name = expand('<sfile>:t')

function! s:AsString(msg)
    " This is the right way to test a variable's type:
    if type(a:msg) != v:t_string
        let l:msg = string(a:msg)
    else
        let l:msg = a:msg
    endif
    return l:msg
endfunction

function! s:Warning(msg)
    let l:msg = '[' . s:this_file_name . '][warning] ' . s:AsString(a:msg)
    echohl WarningMsg | echom l:msg  | echohl None
endfunction

function! s:Debug(msg)
    if s:debug
        let l:msg = '[' . s:this_file_name . '][debug] ' . s:AsString(a:msg)
        echom l:msg
    endif
endfunction
call s:Debug('debug on')

""" Show more meaningful messages when some call fails.
let s:warned_msgs = {}
function! s:SafeCall(func, msg)
    " func:
    "   Funcref, the function to be called.
    " msg:
    "   String, a user-friendly message. Each message will only be printed
    "   once.
    try
        call a:func()
    catch
        let l:warned = get(s:warned_msgs, a:msg)
        if !l:warned
            let l:msg = 'Calling ' . s:AsString(a:func) . ' failed. '
                        \ . s:AsString(a:msg)
            call s:Warning(l:msg)
            let s:warned_msgs[a:msg] = 1
        endif
    endtry
endfunction


"""""" Environmental checks
""" Check external dependencies
for s:d in s:external_dependencies
    if !executable(s:d)
        call s:Warning('Missing external dependency: ' . s:d)
    endif
endfor

""" Check whether ctags is universal-ctags
" This is how you check an element is in a list:
if index(s:external_dependencies, 'ctags') >= 0 && executable('ctags')
    let s:d = system('ctags --version')
    " !~? means regex not match, ignore case
    if s:d !~? 'universal ctags'
        call s:Warning('Your ctags is not universal ctags.
                    \ Install universal ctags instead.')
    endif
endif

""" Check optional external dependencies
for s:d in s:optional_external_dependencies
    if !executable(s:d)
        call s:Debug('Missing optional external dependency: ' . s:d)
    endif
endfor


"""""" Plugin list (using vim-plug as plugin manager)
call plug#begin(stdpath('data') . '/plugged')

""" Syntax highlighting and indent
Plug 'sheerun/vim-polyglot'

""" Statusline / tabline
Plug 'itchyny/lightline.vim'

""" Language server
Plug 'autozimu/LanguageClient-neovim', {
            \ 'branch': 'next',
            \ 'do': 'bash install.sh',
            \ }

" Plug 'neoclide/coc.nvim', {'branch': 'release'}

""" Auto completion
Plug 'ncm2/ncm2'
" This is a requirement of ncm2
Plug 'roxma/nvim-yarp'

" ncm2 completion sources
Plug 'ncm2/ncm2-ultisnips'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-vim' | Plug 'Shougo/neco-vim'

" deoplete's documentation is bad. That's the reason I don't use it.
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" Plug 'deoplete-plugins/deoplete-jedi'
" Plug 'davidhalter/jedi-vim'

""" Function signature viewer
" Plug 'ncm2/float-preview.nvim'
" Plug 'Shougo/echodoc.vim'

""" Fuzzy finder
Plug 'Yggdroot/LeaderF'
Plug 'ctrlpvim/ctrlp.vim'

""" Snippet
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

""" Session manager
Plug 'tpope/vim-obsession'
Plug 'thaerkh/vim-workspace'

" Plug 'dhruvasagar/vim-prosession'

""" Editing enhancement
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'

""" File explorer 
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

""" Code structure viewer
Plug 'majutsushi/tagbar'
Plug 'liuchengxu/vista.vim'

""" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

""" Language-specific plugins
" Python auto-formatter
Plug 'google/yapf', { 'rtp': 'plugins/vim', 'for': 'python' }

""" Misc
" Show key-bindings in popup window
Plug 'liuchengxu/vim-which-key'

call plug#end()


"""""" Config for each plugin

""" lightline
" Show full file path in the statusline, instead of only the file name.
let g:lightline = {
            \   'component': {
            \       'filename': '%F',
            \   }
            \ }

""" ncm2
let s:warn_msg_ncm2 = 'Have you correctly installed the ncm2 plugin?'
" Enable ncm2 for all buffers
autocmd BufEnter * call s:SafeCall(function('ncm2#enable_for_buffer'),
            \ s:warn_msg_ncm2)

" Enable auto complete for `<backspace>`, `<c-w>` keys.
autocmd TextChangedI * call s:SafeCall(function('ncm2#auto_trigger'),
            \ s:warn_msg_ncm2)

" When the <Enter> key is pressed while the popup menu is visible, it only
" hides the menu. Use this mapping to close the menu and also start a new
" line.
inoremap <expr> <CR> pumvisible() ? "\<C-y>\<CR>" : "\<CR>"

" Use <Tab> to select the popup menu:
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Make popup delay shorter
let ncm2#popup_delay = 5
" This fuzzy matcher seems to be better
let g:ncm2#matcher = 'substrfuzzy'

""" ultisnips
let g:UltiSnipsEditSplit = 'vertical'
let g:UltiSnipsSnippetDirectories=['UltiSnips']
let g:UltiSnipsJumpForwardTrigger = "<C-j>"
let g:UltiSnipsJumpBackwardTrigger = "<C-k>"

" We have to set g:UltiSnipsExpandTrigger to some key other than the default
" <Tab>, otherwise user-defined <Tab> mapping will be overridden.
let g:UltiSnipsExpandTrigger = "<Plug>(ultisnips_expand)"

""" LanguageClient-neovim
" List all language servers. Add more if needed.
let g:LanguageClient_serverCommands = {
            \ 'python': ['pyls'],
            \ 'cpp': ['clangd'],
            \ }
" Too many messages. Let's set it to error for now.
let g:LanguageClient_diagnosticsMaxSeverity = 'Error'
"let g:LanguageClient_loggingFile = '/tmp/lc.log'
"let g:LanguageClient_loggingLevel = 'DEBUG'

" Define shortcuts for LanguageClient
function SetLSPShortcuts()
  nnoremap <leader>ld :call LanguageClient#textDocument_definition()<CR>
  nnoremap <leader>lr :call LanguageClient#textDocument_rename()<CR>
  nnoremap <leader>lf :call LanguageClient#textDocument_formatting()<CR>
  nnoremap <leader>lt :call LanguageClient#textDocument_typeDefinition()<CR>
  nnoremap <leader>lx :call LanguageClient#textDocument_references()<CR>
  nnoremap <leader>la :call LanguageClient_workspace_applyEdit()<CR>
  nnoremap <leader>lc :call LanguageClient#textDocument_completion()<CR>
  nnoremap <leader>lh :call LanguageClient#textDocument_hover()<CR>
  nnoremap <leader>ls :call LanguageClient_textDocument_documentSymbol()<CR>
  nnoremap <leader>lm :call LanguageClient_contextMenu()<CR>
endfunction()

augroup LSP
  autocmd!
  autocmd FileType * call SetLSPShortcuts()
augroup END

""" vim-workspace
" Where to save the sessions
"let g:workspace_session_directory = stdpath('data') . '/workspace_sessions/'
let g:workspace_session_name = '.session.vim'
" Disable the persist undo history function. It is not as useful as it seems.
let g:workspace_persist_undo_history = 0
let g:workspace_undodir='.undodir.vim'

""" vim-multiple-cursors
let g:multi_cursor_use_default_mapping = 0

""" nerdtree
nnoremap <M-j> :NERDTreeToggle<CR>
nnoremap <M-n> :NERDTreeFind<CR>
"nnoremap <M-m>t :tabe %<CR>:NERDTreeFind<CR>

" Close nerdtree after opening a file by default
let g:NERDTreeQuitOnOpen = 1

""" tagbar
nnoremap <M-k> :TagbarToggle<CR>
let g:tagbar_sort = 0

""" vim-gitgutter
let g:gitgutter_override_sign_column_highlight = 0


"""""" Config for unused plugins

" These plugins are currently not used anymore. We keep their configs here for
" a while, in case we need them in the future.

""" deoplete
let g:deoplete#enable_at_startup = 1

""" float-preview
let g:float_preview#docked = 1

""" echodoc
let g:echodoc#enable_at_startup = 1
let g:echodoc#type = 'floating'

""" jedi-vim
let g:jedi#auto_initialization = 0
" We use jedi-vim through deoplete-jedi, so jedi-vim's completions should be
" disabled.
let g:jedi#completions_enabled = 0
let g:jedi#auto_vim_configuration = 0

""" coc.nvim
let g:coc_global_extensions = ['coc-python', 'coc-tsserver', 'coc-omnisharp',
            \ 'coc-yaml', 'coc-json', 'coc-html', 'coc-css', 'coc-vimlsp']


"""""" Config for neovim per se

""" General settings
" Set python path explicitly, so that we can use virtualenv without installing
" pynvim in it. See :h python-virtualenv.
let g:python3_host_prog = '/usr/bin/python3'

" Search options
set hlsearch ignorecase smartcase incsearch

" Always expand tab into spaces
set tabstop=4 shiftwidth=4 expandtab

" Enable syntax highlighting and filetype plugin
filetype plugin indent on
syntax enable

autocmd BufEnter * syntax sync fromstart

set backspace=indent,eol,start

set timeoutlen=500

" Add gb18030 after utf-8 for better Chinese support
set fileencodings=ucs-bom,utf-8,gb18030,default,latin1

" Always show the signcolumn
set signcolumn=yes
" Except in tagbar and nerdtree
autocmd FileType tagbar,nerdtree setlocal signcolumn=no
" But make it black
highlight clear SignColumn

" The default of completeopt is 'menu,preview'.
set completeopt=menuone
" The following is recommended by ncm2:
autocmd User Ncm2PopupOpen set completeopt=noinsert,menuone,noselect
autocmd User Ncm2PopupClose set completeopt=menuone

" This will surpass some ins-completion-menu messages. Also recommended by
" ncm2.
set shortmess+=c

" Don't save and restore empty windows in session. Without this vim-workspace
" does not work well with nerdtree.
set sessionoptions-=blank

""" Key mappings
" Mapleader
let mapleader = " "

" Switch to previous/next tab
nnoremap = gt
nnoremap K gt
nnoremap J gT

" Open current file in new tab
nnoremap _ <C-w>v<C-w>T

" Make Y more like some other commands
nnoremap Y y$

" Scroll left/right
nnoremap <C-h> 25zh
nnoremap <C-l> 25zl

" Use 'display' line movement by default
nnoremap j gj
vnoremap j gj
nnoremap gj j
vnoremap gj j
nnoremap k gk
vnoremap k gk
nnoremap gk k
vnoremap gk k
" Synonym for j, k, mainly for ipad
nnoremap <C-j> gj
vnoremap <C-j> gj
nnoremap <C-k> gk
vnoremap <C-k> gk

" Use :tjump instead of :tag by default
nnoremap <C-]> g<C-]>
vnoremap <C-]> g<C-]>
nnoremap g<C-]> <C-]>
vnoremap g<C-]> <C-]>

" Toggle some common options
nnoremap -p :set paste! paste?<CR>
nnoremap -n :setl nu! nu?<CR>
nnoremap -l :setl list! list?<CR>
