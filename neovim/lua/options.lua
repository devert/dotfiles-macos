-- General
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>q", ":qa<CR>", { desc = "Quit all" })

-- Cmd+S saves the file. The terminal turns Cmd+S into F13 (see rex/init.lua and
-- ghostty/config), because terminals do not pass Cmd to Neovim.
vim.keymap.set({ "n", "i", "v" }, "<F13>", "<Cmd>silent! write<CR><Esc>", { desc = "Save file" })

-- Cmd+Return and Cmd+Shift+Return open a new line below and above, like o and O.
-- The terminal turns them into F14 and F15. In insert mode they work the same way.
vim.keymap.set("n", "<F14>", "o", { desc = "New line below" })
vim.keymap.set("n", "<F15>", "O", { desc = "New line above" })
vim.keymap.set("i", "<F14>", "<C-o>o", { desc = "New line below" })
vim.keymap.set("i", "<F15>", "<C-o>O", { desc = "New line above" })

-- Save all files and restart Nvim to load config and plugin changes.
-- :restart (Nvim 0.12+) keeps the terminal UI and restores open windows.
vim.keymap.set("n", "<leader><leader>r", function()
  vim.cmd("silent! wall")
  vim.cmd("restart")
end, { desc = "Save all and restart Nvim" })

-- What a session saves (persistence.nvim and :restart). No "blank": windows that have no
-- file, like nvim-tree, are skipped. "globals" saves vim.g.NvimTreeOpen, so that the tree
-- opens again (see lua/plugins/nvim-tree/session.lua). No "terminal": terminal windows
-- cannot restore their program.
vim.opt.sessionoptions = { "buffers", "curdir", "folds", "globals", "help", "tabpages", "winsize" }

-- Messages: use the experimental ui2 message UI (Nvim 0.12+). Messages show in a
-- small window at the bottom right and close after the timeout.
-- Long messages show a [+x] marker instead of "Press ENTER". Use g< to read them.
-- The command line row is hidden (cmdheight = 0) and shows only while you type a :
-- command. In Rex, set Padding Fill to Off, or the status line colors stretch into the
-- padding under it.
vim.opt.cmdheight = 0
require("vim._core.ui2").enable({
  msg = {
    targets = "msg",
    msg = { timeout = 4000 },
  },
})
-- Hide the messages of the built-in Ctrl+N/Ctrl+P completion, such as "match 1 of 12"
-- and "Pattern not found". The LSP completion menu is blink.cmp (lua/plugins/blink-cmp.lua).
vim.opt.shortmess:append("c")

-- Clipboard (share yank and paste with the system clipboard)
vim.opt.clipboard = "unnamedplus"

-- Folding: Tree-sitter finds the folds. All folds are open when you open a file.
-- <leader><leader>f opens or closes the fold under the cursor. <leader><leader>F closes all folds,
-- and <leader><leader>u opens all folds (the same keys as in VS Code). zM and zR also work.
-- A file type without a Tree-sitter parser has no folds.
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99
vim.keymap.set("n", "<leader><leader>f", "za", { desc = "Toggle fold" })
-- Fold look, like VS Code: a chevron in the gutter on the first line of each closed fold
-- (fold_column() below, used by the statuscolumn), and a collapsed line that keeps its syntax colors and ends with a dim marker and line count.
-- The Folded and FoldColumn colors are set in lua/plugins/monokai-pro.lua.
-- The built-in fold column is off: in nested folds it shows the fold level as a digit.
vim.opt.foldcolumn = "0"
vim.opt.fillchars:append({ fold = " " })
function _G.fold_column()
  local lnum = vim.v.lnum
  if vim.v.virtnum ~= 0 then
    return " "
  end
  if vim.fn.foldclosed(lnum) == lnum then
    local hl = lnum == vim.fn.line(".") and "FoldColumnCursor" or "FoldColumn"
    return "%#" .. hl .. "#▸%*"
  end
  return " "
end
function _G.fold_text()
  local lines = vim.v.foldend - vim.v.foldstart + 1
  local ok, chunks = pcall(vim.treesitter.foldtext)
  if not ok or type(chunks) ~= "table" then
    chunks = { { vim.fn.getline(vim.v.foldstart), "Folded" } }
  end
  table.insert(chunks, { " ⋯ " .. lines .. " lines", "FoldedMarker" })
  return chunks
end
vim.opt.foldtext = "v:lua.fold_text()"
vim.keymap.set("n", "<leader><leader>F", "zM", { desc = "Fold all" })
vim.keymap.set("n", "<leader><leader>u", "zR", { desc = "Unfold all" })

-- Files: no swap files (auto-save writes when you leave a buffer), and reload files that
-- another program changed (for example Claude Code) when Neovim gets focus back.
vim.opt.swapfile = false
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "TermClose" }, {
  command = "silent! checktime",
})

-- Keep undo history after you close a file or restart Neovim
vim.opt.undofile = true

-- Keep 4 lines of context above and below the cursor
vim.opt.scrolloff = 4

-- Search: ignore case, unless the search text has a capital letter
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Splits open to the right and below
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Always show the sign column, so text does not shift when git signs or diagnostics appear
vim.opt.signcolumn = "yes"

-- Do not wrap long lines
vim.opt.wrap = false

-- Markdown files wrap long lines. They break at a space, not in the middle of a
-- word, and wrapped list items keep their indent.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
  end,
})

-- Run CursorHold events after 250 ms idle (default 4000 ms)
vim.opt.updatetime = 250

-- Indentation
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Line Numbers
vim.wo.number = true
vim.wo.numberwidth = 5
-- Line number (4 digits wide), then the fold chevron, with a 3 cell gap like VS Code.
-- %s is the sign column, which stays empty until something (git, diagnostics) uses it.
vim.opt.statuscolumn = "%s%4l %{%v:lua.fold_column()%} "

-- Move 3 lines at a time with Ctrl+j / Ctrl+k
vim.keymap.set({ "n", "x" }, "<C-j>", "3j", { desc = "Down 3 lines" })
vim.keymap.set({ "n", "x" }, "<C-k>", "3k", { desc = "Up 3 lines" })

-- Cursor line
vim.opt.cursorline = true

-- Show leading and trailing spaces, and tabs
vim.opt.list = true
vim.opt.listchars = { lead = "·", trail = "·", multispace = "·", tab = "» " }

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
  vim.keymap.set("n", key, function()
    resize_pane(1)
  end, { desc = "Increase pane size" })
end
for _, key in ipairs({ "<M-k>", "˚" }) do
  vim.keymap.set("n", key, function()
    resize_pane(-1)
  end, { desc = "Decrease pane size" })
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

-- Undo and redo without the "1 change; before #2 ..." message
vim.keymap.set("n", "u", function()
  vim.cmd("silent normal! " .. vim.v.count1 .. "u")
end, { desc = "Undo" })
vim.keymap.set("n", "<C-r>", function()
  vim.cmd("silent normal! " .. vim.v.count1 .. "\18")
end, { desc = "Redo" })

-- Keep the selection after indenting in Visual mode
vim.keymap.set("x", "<", "<gv", { desc = "Outdent and keep selection" })
vim.keymap.set("x", ">", ">gv", { desc = "Indent and keep selection" })

-- Open every modified and untracked file as a buffer (a bufferline tab).
vim.keymap.set("n", "<leader>ga", function()
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  local files = vim.fn.systemlist("git ls-files --modified --others --exclude-standard")
  if vim.v.shell_error ~= 0 or #files == 0 then
    vim.notify("No git changes found.")
    return
  end
  for _, file in ipairs(files) do
    local path = root .. "/" .. file
    -- A deleted file is still listed as modified, so skip it.
    if vim.uv.fs_stat(path) then
      vim.cmd.edit(vim.fn.fnameescape(path))
    end
  end
end, { desc = "Open all changed files" })

-- Close the Lazy window with Esc (q also works)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lazy",
  callback = function(ev)
    vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = ev.buf, desc = "Close Lazy" })
  end,
})
