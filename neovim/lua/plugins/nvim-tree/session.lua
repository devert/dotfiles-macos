-- Restore the tree with a session (persistence.nvim and :restart).
-- A session cannot save the tree window: 'sessionoptions' has no "blank", so :mksession
-- skips it. Instead, the global vim.g.NvimTreeOpen (1 or 0) remembers if the tree was
-- open. Sessions save it because 'sessionoptions' has "globals" (only names that start
-- with a capital letter, and only numbers and strings). After a session loads, the tree
-- opens again if the flag is 1. The cursor stays in the editor.

local M = {}

local function tree_is_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "NvimTree" then
      return true
    end
  end
  return false
end

local function remember()
  vim.g.NvimTreeOpen = tree_is_open() and 1 or 0
end

function M.setup()
  local group = vim.api.nvim_create_augroup("NvimTreeSession", { clear = true })

  -- Keep the flag up to date. :restart writes its session without an event before it,
  -- so the flag must already be right at that time.
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function(args)
      if vim.bo[args.buf].filetype == "NvimTree" then
        vim.g.NvimTreeOpen = 1
      end
    end,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    -- Wait until the window is really closed
    callback = function()
      vim.schedule(remember)
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "PersistenceSavePre",
    callback = remember,
  })

  -- Close the tree before a session loads, so that the restore does not show two trees
  vim.api.nvim_create_autocmd("SessionLoadPre", {
    group = group,
    callback = function()
      if package.loaded["nvim-tree"] and tree_is_open() then
        require("nvim-tree.api").tree.close()
      end
    end,
  })

  vim.api.nvim_create_autocmd("SessionLoadPost", {
    group = group,
    callback = function()
      -- "globals" also saves flags that nvim-tree sets for itself. They are wrong when
      -- nvim-tree is not loaded yet, so remove them.
      if not package.loaded["nvim-tree"] then
        vim.g.NvimTreeSetup = nil
        vim.g.NvimTreeRequired = nil
      end
      if vim.g.NvimTreeOpen == 1 and not tree_is_open() then
        require("nvim-tree.api").tree.toggle({ focus = false, find_file = true })
      end
    end,
  })
end

return M
