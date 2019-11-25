"""""" Notes
" 1. If in trouble, you can run :checkhealth for a health check.
" 2. Don't forget to install pynvim.
" 3. Run :PlugInstall to install plugins.
" 4. Run :messages to see all warning/error messages.
" 5. The :h command has a 'hint' feature. Try :h ctrl-y<Ctrl-D>.
" 6. Don't use Alt to map keys. <Alt-(key)> will be interpreted by many
"    terminals as <Esc>(key), and the interpretation is not unified across
"    terminals. The 'cat' command can be used to check how the terminal
"    interprets <Alt-(key)> (or any other key code).
" 7. Use local.plugin.vim and local.config.vim to add local settings.


"""""" Mapleader
" mapleader has to be set at the beginning. See :h mapleader.
let g:mapleader = "\<Space>"


"""""" Options for this script
""" Set to 1 to enable debug output.
let s:debug = 0

""" Set to 0 to disable sourcing local config files.
let s:source_local_config = 1

""" External dependencies
" Dependencies listed here will be check for existence. A warning is issued if
" not exist.
"   - ctags: Universal-ctags. It is required for tagbar to work correctly.
"   - pyls: Language server for Python.
"   - rg: ripgrep, a fast grep-like tool written in rust.
"   - fzf: A fuzzy search tool.
let s:external_dependencies = ['ctags', 'fzf', 'rg']

""" Optional External dependencies
" Dependencies listed here will only be check if debug is enabled. These are
" mostly language servers.
"   - clangd: Langauge server for C++.
let s:optional_external_dependencies = ['clangd', 'pyls', 'yapf']


"""""" Helper functions
""" Echo message with extra info
" Get current script name, <sfile> is the current script or funcion name, :t
" means to get the filename only, not full path.
let s:this_file_name = expand('<sfile>:t')

function! s:AsString(msg)
    " This is how you test a variable's type:
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

""" Create local.plugin.vim and local.config.vim if not exists.
" This is how you check whether a file exists:
let s:local_plugin_file = stdpath('config') . '/local.plugin.vim'
let s:local_config_file = stdpath('config') . '/local.config.vim'
if empty(glob(s:local_plugin_file))
    call system('touch ' . s:local_config_file)
    call system('touch ' . s:local_plugin_file)
endif


"""""" Plugin list (using vim-plug as plugin manager)
call plug#begin(stdpath('data') . '/plugged')

""" Syntax highlighting and indent
Plug 'sheerun/vim-polyglot'

""" Color scheme
Plug 'liuchengxu/space-vim-dark'

" Plug 'joshdick/onedark.vim'

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

""" Function signature viewer
Plug 'Shougo/echodoc.vim'

" Plug 'ncm2/float-preview.nvim'

""" Fuzzy finder
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'Yggdroot/LeaderF'

" Plug 'ctrlpvim/ctrlp.vim'

""" Snippet
Plug 'SirVer/ultisnips'

" This project has a lot of snippet examples.
" Plug 'honza/vim-snippets'

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
" Python
Plug 'google/yapf', { 'rtp': 'plugins/vim', 'for': 'python' }
Plug 'davidhalter/jedi-vim'

""" Misc
" Show key-bindings in popup window
Plug 'liuchengxu/vim-which-key'

""" Load local plugin list
if s:source_local_config
    execute 'source ' . s:local_plugin_file
endif

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

" Use <Tab>/<S-Tab> to select the popup menu
" But we have more complex tab handling logic below, so we comment this out.
" inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Make popup delay shorter
let ncm2#popup_delay = 5
" This fuzzy matcher seems to be better
let g:ncm2#matcher = 'substrfuzzy'
let g:ncm2#complete_length=[[1,2],[7,1]]

""" ultisnips
let g:UltiSnipsEditSplit = 'vertical'
let g:UltiSnipsSnippetDirectories=['UltiSnips']
let g:UltiSnipsJumpForwardTrigger = "<C-j>"
let g:UltiSnipsJumpBackwardTrigger = "<C-k>"

" We have to set g:UltiSnipsExpandTrigger to some key other than the default
" <Tab>, otherwise user-defined <Tab> mapping will be overridden.
let g:UltiSnipsExpandTrigger = "<Plug>(ultisnips_expand)"

" This function defines the <Tab> handling logic:
" 1. If there's a ultisnips snippet, expand it.
" 2. If popup is visible, ask ncm2_ultisnips whether it has something to
"    expand.
" 3. If popup is visible, select the first entry.
" 4. If none of the above is true, insert a literal <Tab>.
function! s:TabHandler()
    call UltiSnips#ExpandSnippet()
    if g:ulti_expand_res > 0
        return ""
    endif
    if pumvisible()
        " ncm2_ultisnips will only expand if both pumvisible() and the
        " following completed_is_snippet() check is true. (This is learned
        " from its code, so may be subject to change.)
        if ncm2_ultisnips#completed_is_snippet()
            call s:Debug('ncm2 completed_is_snippet')
            " The argument of this function will be pass to feedkeys() if
            " ncm2_ultisnips has nothing to expand.
            return ncm2_ultisnips#expand_or("")
        else
            return "\<C-n>"
        endif
    else
        return "\<Tab>"
    endif
endfunction

inoremap <silent> <Tab> <C-r>=<SID>TabHandler()<CR>

""" echodoc
let g:echodoc#enable_at_startup = 1
let g:echodoc#type = 'floating'

""" LanguageClient-neovim
" List all language servers. Add more if needed.
let g:LanguageClient_serverCommands = {
            \ 'python': ['pyls'],
            \ 'cpp': ['clangd'],
            \ }

let g:LanguageClient_hasSnippetSupport = 1

" Too many messages. Let's set it to error for now.
let g:LanguageClient_diagnosticsMaxSeverity = 'Error'

"let g:LanguageClient_loggingFile = '/tmp/lc.log'
"let g:LanguageClient_loggingLevel = 'DEBUG'

" Define shortcuts for LanguageClient
function SetLSPShortcuts()
    " Jump to definition.
    nnoremap <buffer> <Leader>ld :call LanguageClient#textDocument_definition()<CR>
    " Jump to places where the symbol under cursor is used.
    nnoremap <buffer> <Leader>lx :call LanguageClient#textDocument_references()<CR>
    " List all symbols in current buffer.
    nnoremap <buffer> <Leader>ls :call LanguageClient#textDocument_documentSymbol()<CR>
    " List all available actions.
    nnoremap <buffer> <Leader>lm :call LanguageClient_contextMenu()<CR>

    " Not tested yet:
    nnoremap <buffer> <Leader>li :call LanguageClient#textDocument_implementation()<CR>
    nnoremap <buffer> <Leader>lt :call LanguageClient#textDocument_typeDefinition()<CR>
    nnoremap <buffer> <Leader>lr :call LanguageClient#textDocument_rename()<CR>
    nnoremap <buffer> <Leader>lh :call LanguageClient#textDocument_hover()<CR>
    nnoremap <buffer> <Leader>lf :call LanguageClient#textDocument_formatting()<CR>
    nnoremap <buffer> <Leader>la :call LanguageClient#workspace_applyEdit()<CR>
endfunction()

augroup LSP
  autocmd!
  autocmd FileType * call SetLSPShortcuts()
augroup END

""" vim-workspace
" Where to save the sessions
"let g:workspace_session_directory = stdpath('data') . '/workspace_sessions/'
let g:workspace_session_name = '.session.vim'
" Disable the autosave feature.
let g:workspace_autosave = 0
" Disable the persist undo history feature. It is not as useful as it seems.
let g:workspace_persist_undo_history = 0
let g:workspace_undodir='.undodir.vim'

""" vim-multiple-cursors
let g:multi_cursor_use_default_mapping = 0

""" nerdtree
nnoremap <Leader>j :NERDTreeToggle<CR>
nnoremap <Leader>n :NERDTreeFind<CR>
"nnoremap <Leader>m :tabe %<CR>:NERDTreeFind<CR>

" Close nerdtree after opening a file by default
let g:NERDTreeQuitOnOpen = 1

""" tagbar
nnoremap <Leader>k :TagbarToggle<CR>
let g:tagbar_sort = 0

""" fzf
nnoremap <Leader>F :FZF<CR>

""" yapf
autocmd FileType python nnoremap <buffer> <Leader>Y :YAPF<CR>

""" jedi-vim
" We are using ncm2 as completion framework, so jedi-vim's completions should
" be disabled.
let g:jedi#auto_initialization = 0
let g:jedi#auto_vim_configuration = 0
let g:jedi#completions_enabled = 0

" pyls's rename does not work yet, use jedi's instead.
autocmd FileType python nnoremap <buffer> <Leader>lr :call jedi#rename()<CR>

""" vim-gitgutter
let g:gitgutter_override_sign_column_highlight = 0

""" vim-which-key
let g:space_key_map = {
            \ 'g': 'lgrep',
            \ 'ld': '[language server] jump to definition',
            \ 'lx': '[language server] find references',
            \ }

call which_key#register('<Space>', "g:space_key_map")
nnoremap <silent> <leader> :WhichKey '<Space>'<CR>


"""""" Config for unused plugins

" These plugins are currently not used anymore. We keep their configs here for
" a while, in case we need them in the future.

""" deoplete
let g:deoplete#enable_at_startup = 1

""" float-preview
let g:float_preview#docked = 1

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

" More reliable synctax highlighting
autocmd BufEnter * syntax sync fromstart

set backspace=indent,eol,start

" Add gb18030 after utf-8 for better Chinese support
set fileencodings=ucs-bom,utf-8,gb18030,default,latin1

" Always show the signcolumn
set signcolumn=yes
" Except in tagbar and nerdtree
autocmd FileType tagbar,nerdtree setlocal signcolumn=no

" The default of completeopt is 'menu,preview'.
set completeopt=menuone
" The following is recommended by ncm2:
autocmd User Ncm2PopupOpen set completeopt=noinsert,menuone,noselect
autocmd User Ncm2PopupClose set completeopt=menuone

" Timeout for key mappings.
set timeoutlen=500

" This will surpass some ins-completion-menu messages. Also recommended by
" ncm2.
set shortmess+=c

" Don't save and restore empty windows in session. Without this vim-workspace
" does not work well with nerdtree.
set sessionoptions-=blank

" Adjust the format options (used for comment etc.)
" n: recognize numbered lists
" m: allow to break at a multi-byte character above 255
" M: don't insert a space before or after a multi-byte character
" o: automatically insert the comment leader after hitting 'o'
" r: automatically insert the comment leader after hitting <Enter>
set formatoptions+=nmMor

""" Color scheme
set background=dark

" Enalbe 24-bit true color support. Some terminal may not support it. Tmux
" before version 2.2 does not support it, either.
if (has("termguicolors"))
    set termguicolors
endif

" Load a colorscheme.
colorscheme space-vim-dark

" Reset background color to pure black no matter what color scheme is used.
" This line has to be put after colorscheme and syntax settings.
highlight Normal guibg=NONE ctermbg=NONE

" Do the same for signcolumn and the line numer column.
highlight SignColumn ctermbg=NONE guibg=NONE
highlight LineNr ctermbg=NONE guibg=NONE

""" Grep settings
" Use ripgrep as grep command
if executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
endif

nnoremap <Leader>g :silent lgrep<Space>''<Left>

" Move through location list. 'l' for location list.
nnoremap <silent> [l :lprevious<CR>
nnoremap <silent> ]l :lnext<CR>

""" Key mappings
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

" Use <C-a> to move to the start of line, like in bash
cnoremap <C-a> <C-b>

""" Load local config file
if s:source_local_config
    execute 'source ' . s:local_config_file
endif
