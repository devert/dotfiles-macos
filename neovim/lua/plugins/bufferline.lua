-- Tab bar at the top: one tab for each open file (buffer), like the VS Code editor tabs.
-- Vim tab pages are not used. See :h bufferline-configuration for all options.

-- Close a buffer but keep its window, so the layout (for example nvim-tree) stays.
local function close_buffer(buf)
  require("mini.bufremove").delete(buf or 0, false)
end

local keys = {
  { "H", "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous tab" },
  { "L", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
  { "<leader>tc", close_buffer, desc = "Close tab" },
  { "<leader>to", "<Cmd>BufferLineCloseOthers<CR>", desc = "Close other tabs" },
  { "<leader>tt", "<Cmd>BufferLinePick<CR>", desc = "Pick tab by letter" },
}
-- <leader>1 to <leader>9 jump to the tab at that position
for i = 1, 9 do
  table.insert(keys, { "<leader>" .. i, "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>", desc = "Go to tab " .. i })
end

-- A file tab is a listed buffer with a name. The empty [No Name] buffer is not a file.
local function is_file(buf)
  return vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= ""
end

return {
  "akinsho/bufferline.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-mini/mini.bufremove",
  },
  event = "VeryLazy",
  keys = keys,
  init = function()
    -- Keep the tab bar row from the start, so the screen does not move down when
    -- the first file opens. With no file open, the row is empty.
    vim.o.showtabline = 2
    -- Blank row until bufferline loads, instead of the built-in "[No Name]" tab
    vim.o.tabline = " "
  end,
  config = function(_, opts)
    require("bufferline").setup(opts)
    -- monokai-pro loads its bufferline colors when bufferline loads. It colors the tab
    -- icons on the next BufEnter. Buffers that are already open (for example from a
    -- restored session) get no BufEnter, so their icons keep a darker background until
    -- you switch tabs. Run BufEnter once now.
    vim.api.nvim_exec_autocmds("BufEnter", {})
  end,
  opts = {
    options = {
      mode = "buffers",
      -- Thin yellow bar on the left of the active tab (the default "▎" is twice as wide)
      indicator = { icon = "▏", style = "icon" },
      -- No tab for the empty [No Name] buffer
      custom_filter = is_file,
      -- Use the colors from monokai-pro.nvim instead of the bufferline defaults
      themable = true,
      close_command = close_buffer,
      right_mouse_command = close_buffer,
      -- No close buttons. Close tabs with <leader>tc.
      show_buffer_close_icons = false,
      show_close_icon = false,
      -- Start the tabs after the nvim-tree sidebar, like VS Code
      offsets = {
        -- Same color as the tree background, and no line on the right edge.
        -- Name the group, because bufferline guesses the wrong one from the tree window.
        { filetype = "NvimTree", text = "", highlight = "NvimTreeNormal", separator = false },
      },
    },
  },
}
