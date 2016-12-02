" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible | filetype indent plugin on | syn on

let $PATH = $PATH. ';C:\\Users\\Jonathan.Paugh\\AppData\\Local\\Programs\\Git\\mingw64\\bin'

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
    \ }

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

au BufReadPre *.cmm set filetype=c
au BufReadPre *.hamlet set filetype=hamlet

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
