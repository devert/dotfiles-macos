-- Save files when you leave a buffer or switch away from Neovim.
-- Cmd+S saves on demand (see options.lua).
-- :ASToggle turns auto-save off and on.

-- Skip git commit and rebase messages, so that quitting with :cq still aborts.
local excluded_filetypes = { "gitcommit", "gitrebase" }

return {
  "okuuva/auto-save.nvim",
  event = "VeryLazy",
  cmd = "ASToggle",
  opts = {
    trigger_events = {
      immediate_save = { "BufLeave", "FocusLost" },
      defer_save = {},
      cancel_deferred_save = {},
    },
    condition = function(buf)
      return vim.bo[buf].buftype == ""
        and not vim.tbl_contains(excluded_filetypes, vim.bo[buf].filetype)
    end,
  },
}
