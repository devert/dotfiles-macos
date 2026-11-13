-- Quit Neovim when the tree is the only window left, like neo-tree's close_if_last_window.
-- It runs after any window closes (:q, :close, <C-w>c, ...). Floating windows are ignored.

local M = {}

local function only_tree_windows_left()
  local count = 0
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local is_floating = vim.api.nvim_win_get_config(win).relative ~= ""
    if not is_floating then
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "NvimTree" then
        return false
      end
      count = count + 1
    end
  end
  return count > 0
end

function M.setup()
  vim.api.nvim_create_autocmd("WinClosed", {
    group = vim.api.nvim_create_augroup("NvimTreeCloseIfLastWindow", { clear = true }),
    nested = true,
    callback = function()
      -- Wait until the window is really closed
      vim.schedule(function()
        if only_tree_windows_left() then
          -- Fails with a message when a file has unsaved changes
          local ok, err = pcall(vim.cmd, "qa")
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end)
    end,
  })
end

return M
