-- General
vim.g.mapleader = " "
vim.opt.timeoutlen = 500
vim.keymap.set("n", "<leader>q", ":qa<CR>", { desc = "Quit all" })

-- Clipboard (share yank and paste with the system clipboard)
vim.opt.clipboard = "unnamedplus"

-- Indentation
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Line Numbers
vim.wo.number = true
vim.wo.numberwidth = 5
-- Line number (4 digits wide) followed by 3 spaces, like the gap in VS Code.
-- %s is the sign column, which stays empty until something (git, diagnostics) uses it.
vim.opt.statuscolumn = "%s%4l   "

-- Move 3 lines at a time with Ctrl+j / Ctrl+k
vim.keymap.set({ "n", "x" }, "<C-j>", "3j", { desc = "Down 3 lines" })
vim.keymap.set({ "n", "x" }, "<C-k>", "3k", { desc = "Up 3 lines" })

-- Cursor line
vim.opt.cursorline = true

-- Show leading and trailing spaces, and tabs
vim.opt.list = true
vim.opt.listchars = { lead = "·", trail = "·", tab = "» " }

-- Navigate split panes with <leader>h/j/k/l
vim.keymap.set("n", "<leader>h", ":wincmd h<CR>", { desc = "Window left" })
vim.keymap.set("n", "<leader>j", ":wincmd j<CR>", { desc = "Window down" })
vim.keymap.set("n", "<leader>k", ":wincmd k<CR>", { desc = "Window up" })
vim.keymap.set("n", "<leader>l", ":wincmd l<CR>", { desc = "Window right" })

-- Resize the current pane with Alt+j (bigger) / Alt+k (smaller), like VS Code.
-- Width changes when the pane has a neighbor to the left or right.
-- Height changes when the pane has a neighbor above or below.
local function resize_pane(delta)
  local win = vim.api.nvim_get_current_win()
  local has_neighbor = function(dir)
    return vim.fn.win_getid(vim.fn.winnr(dir)) ~= win
  end
  if has_neighbor("h") or has_neighbor("l") then
    vim.cmd("vertical resize " .. string.format("%+d", delta * 5))
  end
  if has_neighbor("k") or has_neighbor("j") then
    vim.cmd("resize " .. string.format("%+d", delta * 2))
  end
end
-- "∆" and "˚" are what Option+j / Option+k type on macOS when the
-- terminal does not send Option as Alt.
for _, key in ipairs({ "<M-j>", "∆" }) do
  vim.keymap.set("n", key, function() resize_pane(1) end, { desc = "Increase pane size" })
end
for _, key in ipairs({ "<M-k>", "˚" }) do
  vim.keymap.set("n", key, function() resize_pane(-1) end, { desc = "Decrease pane size" })
end

-- Create and close split panes
vim.keymap.set("n", "<leader>wv", ":vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>wh", ":split<CR>", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>wc", ":close<CR>", { desc = "Close window" })
vim.keymap.set("n", "<leader>wo", ":only<CR>", { desc = "Close other windows" })

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Keep the selection after indenting in Visual mode
vim.keymap.set("x", "<", "<gv", { desc = "Outdent and keep selection" })
vim.keymap.set("x", ">", ">gv", { desc = "Indent and keep selection" })

-- Plugin settings from the old config, to bring back with their plugins:
--   lightline (one), vim-auto-save,
--   fzf (<Leader><Leader>), emmet, vim-surround
--   (see init.vim for the old settings)
