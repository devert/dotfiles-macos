" Remaining parts of the old init.vim (reference only, this file is not loaded).
" Everything that is already covered by the Lua config was removed.
" Bring these back as plugins in lua/plugins/.


" Plugins
" ---------------------------------------------------------------

" UI
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'itchyny/lightline.vim'

" Utility
" Currently causing slow down when opening files
" https://github.com/editorconfig/editorconfig-vim/issues/100
" Plug 'editorconfig/editorconfig-vim'
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-surround'
Plug '907th/vim-auto-save'
Plug 'terryma/vim-multiple-cursors'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'


" NERDTree Config
" ---------------------------------------------------------------

map <C-e> :NERDTreeToggle<CR>:

" Close vim if the only window left open is NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

if isdirectory(expand("~/.local/share/nvim/plugged/nerdtree"))
  map <leader>e :NERDTreeFind<CR>
  nmap <leader>nt :NERDTreeFind<CR>

  let NERDTreeShowBookmarks=1
  let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
  let NERDTreeChDirMode=0
  let NERDTreeQuitOnOpen=1
  let NERDTreeMouseMode=2
  let NERDTreeShowHidden=1
  let NERDTreeKeepTreeInNewTab=1
  let NERDTreeMinimalUI = 1
  let NERDTreeDirArrows = 1
  let g:nerdtree_tabs_open_on_gui_startup=0
endif

" Lightline Config
" ---------------------------------------------------------------

let g:lightline = {
  \'colorscheme': 'one',
  \}


" Vim-AutoSave Config
" ---------------------------------------------------------------

let g:auto_save = 1  " enable AutoSave on Vim startup


" FZF Config
" ---------------------------------------------------------------

nnoremap <silent> <Leader><Leader> :FZF<CR>
