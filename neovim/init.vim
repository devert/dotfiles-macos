" Remaining parts of the old init.vim (reference only, this file is not loaded).
" Everything that is already covered by the Lua config was removed.
" Bring these back as plugins in lua/plugins/.


" Plugins
" ---------------------------------------------------------------

" Utility
" Currently causing slow down when opening files
" https://github.com/editorconfig/editorconfig-vim/issues/100
" Plug 'editorconfig/editorconfig-vim'
Plug 'mattn/emmet-vim'
Plug 'terryma/vim-multiple-cursors'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'

" FZF Config
" ---------------------------------------------------------------

nnoremap <silent> <Leader><Leader> :FZF<CR>
