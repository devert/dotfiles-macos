-- Show the name under the cursor in white when the file or folder has no git status
-- and no warning or error, like the selected row in the VS Code explorer.
-- Names that have a status color (yellow, orange, ...) keep that color.

local M = {}

local ns = vim.api.nvim_create_namespace("nvim_tree_cursor_name")

---@param node table nvim-tree node
local function has_status(node)
  if node.diag_severity then
    return true
  end
  local status = node.git_status
  if not status then
    return false
  end
  if status.file then
    return true
  end
  local dir = status.dir
  return dir ~= nil and (#(dir.direct or {}) > 0 or #(dir.indirect or {}) > 0)
end

---@param bufnr integer buffer of the nvim-tree window
function M.attach(bufnr)
  vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved" }, {
    buffer = bufnr,
    callback = function()
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

      local node = require("nvim-tree.api").tree.get_node_under_cursor()
      if not node or not node.parent or has_status(node) then
        return
      end

      local row = vim.api.nvim_win_get_cursor(0)[1]
      local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
      if not line then
        return
      end

      -- The name is at the end of the line. Folder chains such as "src/deep" are one word.
      local start
      if line:sub(-#node.name) == node.name then
        start = #line - #node.name
      else
        start = (line:find("[^ ]+$") or 1) - 1
      end

      vim.api.nvim_buf_set_extmark(bufnr, ns, row - 1, start, {
        end_col = #line,
        hl_group = "NvimTreeCursorName",
        priority = 5000,
      })
    end,
  })
end

return M
