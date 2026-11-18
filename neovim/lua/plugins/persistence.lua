-- persistence.nvim saves a session (open buffers, windows, cursor positions) for each folder
-- and git branch when Neovim quits. A plain `nvim` (no files, no folder) restores the session
-- for the current folder. bufferline shows the restored buffers as tabs, and
-- plugins/nvim-tree/session.lua opens the tree again if it was open.
--   <leader>ss  restore the session for the current folder
--   <leader>sl  restore the last session
--   <leader>sS  pick a session
--   <leader>sd  do not save a session when Neovim quits
return {
  "folke/persistence.nvim",
  -- Loads when a file opens, or at startup when it restores a session (see init below)
  event = "BufReadPre",
  opts = {
    -- Save a session only when at least one file buffer is open
    need = 1,
    -- One session for each git branch
    branch = true,
  },
  keys = {
    { "<leader>ss", function() require("persistence").load() end, desc = "Restore session for this folder" },
    { "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
    { "<leader>sS", function() require("persistence").select() end, desc = "Pick a session" },
    { "<leader>sd", function() require("persistence").stop() end, desc = "Do not save session on quit" },
  },
  init = function()
    -- Restore the session for the current folder when Neovim starts without files.
    -- Not after :restart, because :restart restores its own session.
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("PersistenceAutoRestore", { clear = true }),
      once = true,
      -- nested: the buffers that the session opens run their autocmds (Tree-sitter,
      -- gitsigns, LSP)
      nested = true,
      callback = function()
        if vim.fn.argc() == 0 and not vim.g.started_with_stdin and vim.v.startreason == "normal" then
          require("persistence").load()
        end
      end,
    })
    vim.api.nvim_create_autocmd("StdinReadPre", {
      once = true,
      callback = function()
        vim.g.started_with_stdin = true
      end,
    })
  end,
}
