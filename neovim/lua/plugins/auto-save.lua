-- Save files automatically. Edits save 1 second after the last change.
-- Leaving a buffer or switching away from Neovim saves right away.
-- :ASToggle turns auto-save off and on.

-- Skip git commit and rebase messages, so that quitting with :cq still aborts.
local excluded_filetypes = { "gitcommit", "gitrebase" }

return {
  "okuuva/auto-save.nvim",
  event = { "InsertLeave", "TextChanged" },
  cmd = "ASToggle",
  opts = {
    debounce_delay = 1000,
    condition = function(buf)
      return vim.bo[buf].buftype == ""
        and not vim.tbl_contains(excluded_filetypes, vim.bo[buf].filetype)
    end,
  },
}
