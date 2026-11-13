-- General
vim.g.mapleader = " "

-- Indentation
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Line Numbers
vim.wo.number = true
vim.wo.numberwidth = 5

-- Move 3 lines at a time with Ctrl+j / Ctrl+k
vim.keymap.set({ 'n', 'x' }, '<C-j>', '3j')
vim.keymap.set({ 'n', 'x' }, '<C-k>', '3k')
--
-- -- Show leading spaces
-- -- vim.cmd("highlight Conceal guibg=NONE ctermbg=NONE guifg=#676767")
-- -- vim.cmd("autocmd BufWinEnter * setl conceallevel=2 concealcursor=nv")
-- -- vim.cmd("autocmd BufWinEnter * syn match LeadingSpace /\(^ *\)\@<= / containedin=ALL conceal cchar=·")
-- -- vim.cmd("autocmd BufReadPre * setl conceallevel=2 concealcursor=nv")
-- -- vim.cmd("autocmd BufReadPre * syn match LeadingSpace /\(^ *\)\@<= / containedin=ALL conceal cchar=·")
--
-- -- Navigate Panes Better
-- vim.keymap.set('n', '<C-k>', ':wincmd k<CR>')
-- vim.keymap.set('n', '<C-j>', ':wincmd j<CR>')
-- vim.keymap.set('n', '<C-h>', ':wincmd h<CR>')
-- vim.keymap.set('n', '<C-l>', ':wincmd l<CR>')

--
-- Ported from the old init.vim (plugin-specific parts left out, they are replaced by lua/plugins/)
--

-- General
-- vim.opt.encoding = "utf-8"
-- vim.opt.fileencoding = "utf-8"
-- vim.opt.timeoutlen = 500
-- vim.opt.ttimeoutlen = 0

-- UI
-- vim.opt.mouse = "a"
-- vim.opt.mousehide = true

-- Clipboard (workaround: https://github.com/neovim/neovim/issues/8631)
-- vim.g.clipboard = {
--   name = "pbcopy",
--   copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
--   paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
--   cache_enabled = 0,
-- }
-- vim.opt.clipboard = "unnamedplus,unnamed"

-- Theme/Editor

-- Make line number column transparent
-- vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE", fg = "#555555" })

-- Cursor styles: block in normal, line in insert, underline in replace
-- vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20"

-- Cursor line
-- vim.opt.cursorline = true
-- vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#BBBBBB" })
-- vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE", fg = "NONE" })

-- Show leading spaces
-- vim.api.nvim_set_hl(0, "Conceal", { bg = "NONE", fg = "#676767" })
-- vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPre" }, {
--   callback = function()
--     vim.opt_local.conceallevel = 2
--     vim.opt_local.concealcursor = "nv"
--     vim.cmd([[syn match LeadingSpace /\(^ *\)\@<= / containedin=ALL conceal cchar=·]])
--   end,
-- })

-- Plugin settings from the old config, to bring back with their plugins:
--   nerdtree (<C-e> toggle, <leader>e find), lightline (one), vim-auto-save,
--   fzf (<Leader><Leader>), emmet, vim-surround, vim-polyglot
