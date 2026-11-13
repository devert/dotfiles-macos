" Remaining parts of the old init.vim (reference only, this file is not loaded).
" Everything that is already covered by the Lua config was removed.
" Bring these back as plugins in lua/plugins/.


" Plugins
" ---------------------------------------------------------------

" UI
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
