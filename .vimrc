" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set backup		" keep a backup file
set backupdir=~/.vim/backupdir,. " put the backup out of the way
set confirm             " confirm dangerous actions instead of asking for a !
set exrc                " Allow a .vimrc file in the current directory
set patchmode=".orig"	" Only backup the original
set history=10000	" keep lots of command-line history
set textwidth=72
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set hlsearch            " Turn on search highlighting
set shiftwidth=4	" Indent amount = 4 spaces
set softtabstop=4	" <tab> is the same, but doesn't affect real tabs.
set expandtab		" Arrg! Python finally bit me!
set splitright splitbelow " Make new windows come up idiosyncronously.
set number relativenumber " Line numbering--Oh!
set hidden		" Buffers prefer to be hidden, instead of inactive
set scrolloff=2		" Number of lines to keep above or below the cursor onscreen
set linebreak		" word-wrap long lines instead of char-wrapping
set laststatus=1        " Status line only for multiple windows
                        " This is the default in Vim, but not NeoVim
set gdefault            " %s/// replaces all matches; /g turns it back off
"set tildeop		" ~ command accepts a motion (like delete or change do)
set display=lastline,uhex " A few display settings
set ttyfast             " More performant scrolling, but with heavier
                        " tty usage
set wildmenu            " Enhanced command-line completion
set wildmode=longest:full,full
"   longest     First, complete the longest common match
"   :full       But, also show the wildmenu
"   full        If user pressses <Tab> again, match the first full
"               string in the list, instead of longest common substring

" Prefer UTF-8 encoding
set encoding=utf-8
" As I understand it, encoding is variable is only used if none of the
" encodings in 'fileencodings' works; Loading a file with utf-8 encoding
" will not corrupt it, even it it is from a different encoding.

" Doesn't UTF-16 files, fails for ASCII.
" set fileencodings=ucs-bom,utf-16le,utf-8

set formatoptions=tcqjroqn
"   t   autowrap text
"   c   autowrap comments
"   j   remove comment leader (e.g. //) when joining lines
"   r   auto insert comment leader with i<Enter>
"   o   auto insert comment leader with o or O
"   q   format comments with gq, too
"   n   wrap lists (e.g. "1.", "1)") (Uses 'formatlistpat')

let &formatlistpat="^\s*\d\+[\]:.)}\t ]\s*\|^\s*[-*]\s+"
let &formatlistpat=string(&formatlistpat)
" Pattern used to find lists for set fo+=n, above. This adds bullet
" lists (beginning with * or -) to the default numbered lists


" What gets saved with ':mksession' command?
set sessionoptions=blank,buffers,curdir,folds,help,localoptions,options,resize,tabpages,winpos,winsize
" blank     empty windows
" buffers   hidden/unloaded buffers (those not in a window currently)
" curdir    current dir
" folds     Manually created folds, as well as open/close state
" help      Help window(s)
" locaoptions Local options (e.g. lcd)
" options   Global options/mappings
" resize    Size of Vim
" tabpages  All tabs; without this, you can (must) save each tab separately
" winpos    Window position of Vim
" winsize   Size of windows

" NeoVim-only settings
if has("nvim")
    set nrformats=bin,octal,hex " Which number formats work with ^A and ^X?
    set shada=!,'1000,f1,<500,s100,h
    "   !       Store certain global variables (ALL_CAPS)
    "   'n      Save marks (a-z) for n files
    "   f1      Save global marks
    "   <n      Save up to n lines from each register
    "   sn      Items bigger than n KiB are not saved
    "   h       Disable hlsearch highlighting
end

""
" Mappings

" Note: When mapping special keys, like <F1>, it's better to type it out
" than to try entering ^V<F1> (literally "<F1>"), because it works
" differently in Vim than GVim

" Don't use Ex mode, use Q for formatting
map Q gq

" NOTE: F4-F6, F8 reserved for per-filetype definitions

" Redefine the help binding to be more useful
" Unfortunately, this doesn't work in Gnome Terminal, which overrides <F1>
map <silent> <F1> :vertical help
map <silent> <S-F1> :help
map <silent> <C-F1> :tabe \| set buftype=help \| help

" Clear search pattern with <F2>
map <silent> <F2> :let @/ = ""

" Toggle spell checking
map <silent> <F7> :set spell!

" Make errors
map <silent> <F9> :cnext
map <silent> <S-F9> :cprevious

" Open/Close tagbar
map <silent> <F10> :TagbarToggle
" Refresh tags list
map <silent> <S-F10> :!ctags -R

" Delete extra spaces at the end of lines
map <silent> <F11> :%s/\v\s+$//
" Search for (git/svn) merge conflicts
map <silent> <S-F11> /^\v[<=\|>]{7}

" Open the .vimrc file for editing
map <silent> <F12> :tabe ~/.vimrc

fun! HaskellMappings ()
    " Set up keymappings for Haskell code
    " Run via autocommand later

    " Clear type highlighting
    map <buffer> <silent> <S-F2> :GhcModTypeClear
    " Display expresion type (and highlight the expression) 
    map <buffer> <F5> :GhcModType!
    " Insert the expression type
    map <buffer> <S-F5> :GhcModTypeInsert!
    " Display expression Info
    map <buffer> <C-F5> :GhcModInfo!
    " Use hasktags instead of ctags
    map <silent> <S-F10> :!hasktags -c .
endfun


" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
if &t_Co > 2 || has("gui_running")
  syntax on
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 72 characters.
  autocmd FileType text setlocal textwidth=72
  " au FileType text setlocal formatoptions+=a " Auto-reshape paragraphs (more often)

  " For HTML files, change textwidth and shiftwidth
  autocmd FileType html setlocal textwidth=0 shiftwidth=2

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  autocmd BufReadPost *.nut setfiletype cpp
  au BufReadPre *.coffee setfiletype coffee
  au BufReadPost *.md setfiletype markdown

  au BufReadPost * :GitGutterEnable

  autocmd BufEnter .less setfiletype less

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif



" Installs VAM if it is missing
fun! EnsureVamIsOnDisk(plugin_root_dir)
  let vam_autoload_dir = a:plugin_root_dir.'/vim-addon-manager/autoload'
  if isdirectory(vam_autoload_dir)
    return 1
  else
    if 1 == confirm("Clone VAM into ".a:plugin_root_dir."?","&Y\n&N")
      " I'm sorry having to add this reminder. Eventually it'll pay off.
      call confirm("Remind yourself that most plugins ship with ".
                  \"documentation (README*, doc/*.txt). It is your ".
                  \"first source of knowledge. If you can't find ".
                  \"the info you're looking for in reasonable ".
                  \"time ask maintainers to improve documentation")
      call mkdir(a:plugin_root_dir, 'p')
      execute '!git clone --depth=1 git://github.com/MarcWeber/vim-addon-manager '.
                  \       shellescape(a:plugin_root_dir, 1).'/vim-addon-manager'
      " VAM runs helptags automatically when you install or update
      " plugins
      exec 'helptags '.fnameescape(a:plugin_root_dir.'/vim-addon-manager/doc')
    endif
    return isdirectory(vam_autoload_dir)
  endif
endfun

fun! SetupVAM()
  " Set advanced options like this:
  " let g:vim_addon_manager = {}
  " let g:vim_addon_manager.key = value
  "     Pipe all output into a buffer which gets written to disk
  " let g:vim_addon_manager.log_to_buf =1

  " Example: drop git sources unless git is in PATH. Same plugins can
  " be installed from www.vim.org. Lookup MergeSources to get more control
  " let g:vim_addon_manager.drop_git_sources = !executable('git')
  " let g:vim_addon_manager.debug_activation = 1

  " VAM install location:
  let c = get(g:, 'vim_addon_manager', {})
  let g:vim_addon_manager = c
  let c.plugin_root_dir = expand('$HOME', 1) . '/.vim/vim-addons'


  " Force your ~/.vim/after directory to be last in &rtp always:
  " let g:vim_addon_manager.rtp_list_hook = 'vam#ForceUsersAfterDirectoriesToBeLast'

  " if !EnsureVamIsOnDisk(c.plugin_root_dir)
  "   echohl ErrorMsg | echomsg "No VAM found!" | echohl NONE
  "   return
  " endif

  " most used options you may want to use:
  " let c.log_to_buf = 1
  " let c.auto_install = 0
  let &rtp.=(empty(&rtp)?'':',').c.plugin_root_dir.'/vim-addon-manager'
  " If VAM is missing, download and install it
  if !isdirectory(c.plugin_root_dir.'/vim-addon-manager/autoload')
    execute '!git clone --depth=1 git://github.com/MarcWeber/vim-addon-manager '
        \       shellescape(c.plugin_root_dir.'/vim-addon-manager', 1)
  endif

  " Tell VAM which plugins to fetch & load:
  call vam#ActivateAddons([], {'auto_install' : 0})
  " sample: call vam#ActivateAddons(['pluginA','pluginB', ...], {'auto_install' : 0})

  " Addons are put into plugin_root_dir/plugin-name directory
  " unless those directories exist. Then they are activated.
  " Activating means adding addon dirs to rtp and do some additional
  " magic

  " How to find addon names?
  " - look up source from pool
  " - (<c-x><c-p> complete plugin names):
  " You can use name rewritings to point to sources:
  "    ..ActivateAddons(["github:foo", .. => github://foo/vim-addon-foo
  "    ..ActivateAddons(["github:user/repo", .. => github://user/repo
  " Also see section "2.2. names of addons and addon sources" in VAM's documentation
endfun

call SetupVAM()

" ACTIVATING PLUGINS

" OPTION 1, use VAMActivate
" VAMActivate PLUGIN_NAME PLUGIN_NAME ..

" OPTION 2: use call vam#ActivateAddons
 call vam#ActivateAddons(["surround"], {})
" 'Windows_PowerShell_Syntax_Plugin'
" use <c-x><c-p> to complete plugin names

" OPTION 3: Create a file ~/.vim-srcipts putting a PLUGIN_NAME into each line
" See lazy loading plugins section in README.md for details
"call vam#Scripts('~/.vim-scripts', {'tag_regex': '.*'})



" experimental [E1]: load plugins lazily depending on filetype, See
" NOTES
" experimental [E2]: run after gui has been started (gvim) [3]
" option1:  au VimEnter * call SetupVAM()
" option2:  au GUIEnter * call SetupVAM()
" See BUGS sections below [*]
" Vim 7.0 users see BUGS section [3]

""
" Lazy filetype plugin loading

" Add an entry here for each filetype you want to match:
"   The key is the filetype pattern (as used by filter())
"   The value is the list of plugins to load on a match
let g:lazyPlugins = {
    \   '^\%(c\|cpp\)$' :   [ 'c%213' ]
    \ , 'haskell' :         [ 'vim2hs', 'ghcmod', 'neco-ghc' ]
    \ , 'hamlet\|cassius\|lucius\|julius' : [ 'html-template-syntax' ]
    \ , 'lojban' :          [ 'lojban' ]
    \ , 'rfc' :             [ 'rfc-syntax' ]
    \ , 'ps1' :             [ 'vim-ps1' ]
    \ , 'ubs' :             [ 'unibasic' ]
    \ }
"    \ , 'ps1' :             [ 'Windows_PowerShell_Syntax_Plugin' ]
" call vam#Scripts([{
"     \   'name' : 'Windows_PowerShell_Syntax_Plugin'
"     \ , 'filename_regex' : '\.ps1$'
"     \ }], { 'tag_regex' : '.*'})

fun! LoadLazyPlugins()
    " TODO: Remove an entry when the rule fires, and store the list of
    " plugins for reuse; this way, we only activate an addon once per
    " run, not once per file.
    let l:plugins = filter(copy(g:lazyPlugins)
        \               , string(expand('<amatch>')) . ' =~ v:key')

    for plugs in values(l:plugins)
        call vam#ActivateAddons(plugs, {'force_loading_plugins_now' : 1})
    endfor
endfun

au FileType * call LoadLazyPlugins ()

au BufReadPre *.cmm setfiletype c
au BufReadPre *.hamlet setfiletype hamlet

" Manually loaded plugins: these are for all files
ActivateAddons neocomplcache
ActivateAddons fugitive vcscommand surround
ActivateAddons Tagbar
ActivateAddons snipmate

""
" Haskell-specific settings

" This lets neco-ghc work with YouCompleteMe via omni
" setlocal omnifunc=necoghc#omnifunc

let g:ghcmod_max_preview_size = 20

let warnings = "incomplete-patterns overlapping-patterns"
let nowarnings = "missing-signatures type-defaults unused-binds unused-imports unused-matches orphan-instances"
let language = "MultiWayIf OverloadedStrings RecordWildCards"
let nolanguage = "MonomorphismRestriction"

" Create language/nolanguage command line arguments
let exts = split(join(extend([''], split(language)), " -X"))
call extend(exts, split(join(extend([''], split(nolanguage)), " -XNo")))

" Create warnings/nowarnings command line arguments
let warns = [ '-Wall' ]
call extend(warns, split(join(extend([''], split(warnings)), ' -fwarn-')))
call extend(warns, split(join(extend([''], split(nowarnings)), ' -fno-warn-')))

let g:ghcmod_ghc_options = warns + exts +
        \ [ '-user-package-db', '-fno-code', '-fdefer-type-errors' ]

if isdirectory('cabal-dev')
    let g:ghcmod_ghc_options += ['-package-db=cabal-dev/packages-7.6.2.conf']
endif

"au FileType haskell au BufWritePost <buffer> GhcModCheckAndLintAsync
au FileType haskell call HaskellMappings()

let g:haskell_autotags = 1
let g:haskell_tags_generator = "hasktags -c ."
let g:ghcmod_hlint_options = [ "--ignore=Use camelCase" ]

" neocomplcache settings

    " Use neocomplcache.
    let g:neocomplcache_enable_at_startup = 0
    " Use smartcase.
    " let g:neocomplcache_enable_smart_case = 1

    " Set minimum syntax keyword length.
    let g:neocomplcache_min_syntax_length = 4

    " Automatically choose the first completion while displaying the
    " pop-up menu
    "let g:neocomplcache_enable_auto_select = 1

    " Experimental
    " These are setting we're not sure about yet
    let g:neocomplcache_enable_auto_delimiter = 1

    " Enable heavy features. These slow things down a bit
    " Use camel case completion.
    " let g:neocomplcache_enable_fuzzy_case_completion = 1
    " Use underbar completion.
    "let g:neocomplcache_enable_underbar_completion = 1

    " Define dictionary.
    let g:neocomplcache_dictionary_filetype_lists = {
        \ 'default' : './.completions',
        \ }

    " Define keyword.
    if !exists('g:neocomplcache_keyword_patterns')
        let g:neocomplcache_keyword_patterns = {}
    endif
    let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

    " Plugin key-mappings.
    inoremap <expr><C-g>     neocomplcache#undo_completion()
    inoremap <expr><C-l>     neocomplcache#complete_common_string()


fun! HaskellMappings ()
    " Set up keymappings for Haskell code
    " Run via autocommand later

    " Clear type highlighting
    map <buffer> <silent> <S-F2> :GhcModTypeClear
    " Display expresion type (and highlight the expression) 
    map <buffer> <F5> :GhcModType!
    " Insert the expression type
    map <buffer> <S-F5> :GhcModTypeInsert!
    " Display expression Info
    map <buffer> <C-F5> :GhcModInfo!
    " Use hasktags instead of ctags
    map <silent> <S-F10> :!hasktags -c .
endfun


" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to create a new undo point,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
if &t_Co > 2 || has("gui_running")
  syntax on
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 72 characters.
  autocmd FileType text setlocal textwidth=72
  " au FileType text setlocal formatoptions+=a " Auto-reshape paragraphs (more often)

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  autocmd BufReadPost *.nut setfiletype cpp
  autocmd BufEnter .less setfiletype less

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif



""
" Vim Addon Manager

" With the following settings, we can install VAM + all needed plugins
" on a new system automagically, just by copying the .vimrc file from a
" working system

" Installs VAM if it is missing; works great wne
fun! EnsureVamIsOnDisk(plugin_root_dir)
  let vam_autoload_dir = a:plugin_root_dir.'/vim-addon-manager/autoload'
  if isdirectory(vam_autoload_dir)
    return 1
  else
    if 1 == confirm("Clone VAM into ".a:plugin_root_dir."?","&Y\n&N")
      " I'm sorry having to add this reminder. Eventually it'll pay off.
      call confirm("Remind yourself that most plugins ship with ".
                  \"documentation (README*, doc/*.txt). It is your ".
                  \"first source of knowledge. If you can't find ".
                  \"the info you're looking for in reasonable ".
                  \"time ask maintainers to improve documentation")
      call mkdir(a:plugin_root_dir, 'p')
      execute '!git clone --depth=1 git://github.com/MarcWeber/vim-addon-manager '.
                  \       shellescape(a:plugin_root_dir, 1).'/vim-addon-manager'
      " VAM runs helptags automatically when you install or update
      " plugins
      exec 'helptags '.fnameescape(a:plugin_root_dir.'/vim-addon-manager/doc')
    endif
    return isdirectory(vam_autoload_dir)
  endif
endfun

fun! SetupVAM()
  " Set advanced options like this:
  " let g:vim_addon_manager = {}
  " let g:vim_addon_manager.key = value
  "     Pipe all output into a buffer which gets written to disk
  " let g:vim_addon_manager.log_to_buf =1

  " Example: drop git sources unless git is in PATH. Same plugins can
  " be installed from www.vim.org. Lookup MergeSources to get more control
  " let g:vim_addon_manager.drop_git_sources = !executable('git')
  " let g:vim_addon_manager.debug_activation = 1

  " VAM install location:
  let c = get(g:, 'vim_addon_manager', {})
  let g:vim_addon_manager = c
  let c.plugin_root_dir = expand('$HOME', 1) . '/.vim/vim-addons'


  " Force your ~/.vim/after directory to be last in &rtp always:
  " let g:vim_addon_manager.rtp_list_hook = 'vam#ForceUsersAfterDirectoriesToBeLast'

  " if !EnsureVamIsOnDisk(c.plugin_root_dir)
  "   echohl ErrorMsg | echomsg "No VAM found!" | echohl NONE
  "   return
  " endif

  " most used options you may want to use:
  " let c.log_to_buf = 1
  " let c.auto_install = 0
  let &rtp.=(empty(&rtp)?'':',').c.plugin_root_dir.'/vim-addon-manager'
  " If VAM is missing, download and install it
  if !isdirectory(c.plugin_root_dir.'/vim-addon-manager/autoload')
    execute '!git clone --depth=1 git://github.com/MarcWeber/vim-addon-manager '
        \       shellescape(c.plugin_root_dir.'/vim-addon-manager', 1)
  endif

  " Tell VAM which plugins to fetch & load:
  call vam#ActivateAddons([], {'auto_install' : 0})
  " sample: call vam#ActivateAddons(['pluginA','pluginB', ...], {'auto_install' : 0})

  " Addons are put into plugin_root_dir/plugin-name directory
  " unless those directories exist. Then they are activated.
  " Activating means adding addon dirs to rtp and do some additional
  " magic

  " How to find addon names?
  " - look up source from pool
  " - (<c-x><c-p> complete plugin names):
  " You can use name rewritings to point to sources:
  "    ..ActivateAddons(["github:foo", .. => github://foo/vim-addon-foo
  "    ..ActivateAddons(["github:user/repo", .. => github://user/repo
  " Also see section "2.2. names of addons and addon sources" in VAM's documentation
endfun

call SetupVAM()

" ACTIVATING PLUGINS

" OPTION 1, use VAMActivate
" VAMActivate PLUGIN_NAME PLUGIN_NAME ..

" OPTION 2: use call vam#ActivateAddons
 call vam#ActivateAddons(["surround", 'Windows_PowerShell_Syntax_Plugin', 'The_NERD_Commenter'], {})
" use <c-x><c-p> to complete plugin names

" TODO: Figure out how to autoload Windows_PowerShell_Syntax_Plugin,
" since it's supposed to do filetype detection automagically; then, we
" can load it conditionally in the "lazyPlugins" list

" OPTION 3: Create a file ~/.vim-srcipts putting a PLUGIN_NAME into each line
" See lazy loading plugins section in README.md for details
"call vam#Scripts('~/.vim-scripts', {'tag_regex': '.*'})



" experimental [E1]: load plugins lazily depending on filetype, See NOTES
" experimental [E2]: run after gui has been started (gvim) [3]
" option1:  au VimEnter * call SetupVAM()
" option2:  au GUIEnter * call SetupVAM()
" See BUGS sections below [*]
" Vim 7.0 users see BUGS section [3]

""
" Lazy filetype plugin loading

" TODO: VAM's support for this has matured since you wrote this. Re-evaluate!

" Add an entry here for each filetype you want to match:
"   The key is the filetype pattern (as used by filter())
"   The value is the list of plugins to load on a match
let g:lazyPlugins = {
    \   '^\%(c\|cpp\)$' :   [ 'c%213' ]
    \ , 'haskell' :         [ 'vim2hs', 'ghcmod', 'neco-ghc' ]
    \ , 'hamlet\|cassius\|lucius\|julius' : [ 'html-template-syntax' ]
    \ , 'lojban' :          [ 'lojban' ]
    \ , 'rfc' :             [ 'rfc-syntax' ]
    \ }
"    \ , 'ps1' :             [ 'Windows_PowerShell_Syntax_Plugin' ] " TODO
" call vam#Scripts([{
"     \   'name' : 'Windows_PowerShell_Syntax_Plugin'
"     \ , 'filename_regex' : '\.ps1$'
"     \ }], { 'tag_regex' : '.*'})

fun! LoadLazyPlugins()
    " TODO: Remove an entry when the rule fires, and store the list of
    " plugins for reuse; this way, we only activate an addon once per
    " run, not once per file.
    let l:plugins = filter(copy(g:lazyPlugins)
        \               , string(expand('<amatch>')) . ' =~ v:key')

    for plugs in values(l:plugins)
        call vam#ActivateAddons(plugs, {'force_loading_plugins_now' : 1})
    endfor
endfun

au FileType * call LoadLazyPlugins ()

au BufReadPre *.cmm setfiletype c
au BufReadPre *.hamlet setfiletype hamlet
au BufReadPre *.ubs setfiletype unibasic

" Manually loaded plugins: these are for all files
ActivateAddons neocomplcache
ActivateAddons surround
ActivateAddons Tagbar
ActivateAddons snipmate " Snippets like TextMate & GEdit use

""
" neocomplcache settings

    " Use neocomplcache.
    let g:neocomplcache_enable_at_startup = 0
    " Use smartcase.
    " let g:neocomplcache_enable_smart_case = 1

    " Set minimum syntax keyword length.
    let g:neocomplcache_min_syntax_length = 4

    " Automatically choose the first completion while displaying the
    " pop-up menu
    "let g:neocomplcache_enable_auto_select = 1

    " Experimental
    " These are setting we're not sure about yet
    let g:neocomplcache_enable_auto_delimiter = 1

    " Enable heavy features.
    " Use camel case completion.
    " let g:neocomplcache_enable_fuzzy_case_completion = 1
    " Use underbar completion.
    "let g:neocomplcache_enable_underbar_completion = 1

    " Define dictionary.
    let g:neocomplcache_dictionary_filetype_lists = {
        \ 'default' : './.completions',
        \ }

    " Define keyword.
    if !exists('g:neocomplcache_keyword_patterns')
        let g:neocomplcache_keyword_patterns = {}
    endif
    let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

    " Plugin key-mappings.
    inoremap <expr><C-g>     neocomplcache#undo_completion()
    inoremap <expr><C-l>     neocomplcache#complete_common_string()

""
" Haskell-specific settings

" This lets neco-ghc work with YouCompleteMe via omni
" setlocal omnifunc=necoghc#omnifunc

let g:ghcmod_max_preview_size = 20

let warnings = "incomplete-patterns overlapping-patterns"
let nowarnings = "missing-signatures type-defaults unused-binds unused-imports unused-matches orphan-instances"
let language = "MultiWayIf OverloadedStrings RecordWildCards"
let nolanguage = "MonomorphismRestriction"

" Create language/nolanguage command line arguments
let exts = split(join(extend([''], split(language)), " -X"))
call extend(exts, split(join(extend([''], split(nolanguage)), " -XNo")))

" Create warnings/nowarnings command line arguments
let warns = [ '-Wall' ]
call extend(warns, split(join(extend([''], split(warnings)), ' -fwarn-')))
call extend(warns, split(join(extend([''], split(nowarnings)), ' -fno-warn-')))

let g:ghcmod_ghc_options = warns + exts +
        \ [ '-user-package-db', '-fno-code', '-fdefer-type-errors' ]

if isdirectory('cabal-dev')
    let g:ghcmod_ghc_options += ['-package-db=cabal-dev/packages-7.6.2.conf']
endif

"au FileType haskell au BufWritePost <buffer> GhcModCheckAndLintAsync
au FileType haskell call HaskellMappings()

let g:haskell_autotags = 1
let g:haskell_tags_generator = "hasktags -c ."
let g:ghcmod_hlint_options = [ "--ignore=Use camelCase" ]
