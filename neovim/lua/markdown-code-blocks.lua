-- Paint a background behind whole Markdown code blocks, from the left edge to the
-- right edge of the window, including the lines of the ``` fences and the empty
-- lines. The group MarkdownCodeBlock sets the color (see plugins/monokai-pro.lua).
-- The code keeps its syntax highlighting, because this only adds a background.
-- The extmarks are ephemeral: Neovim redraws them on every screen update, so
-- scrolling and editing need no extra work.
local ns = vim.api.nvim_create_namespace("markdown_code_blocks")
local query = vim.treesitter.query.parse("markdown", "(fenced_code_block) @block")
local block_rows = {} -- rows of the visible code blocks, set in on_win and read in on_line

vim.api.nvim_set_decoration_provider(ns, {
  on_win = function(_, _, buf, top, bottom)
    block_rows = {}
    if vim.bo[buf].filetype ~= "markdown" then
      return false
    end
    local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
    if not ok or not parser then
      return false
    end
    parser:parse({ top, bottom })
    local tree = parser:trees()[1]
    if not tree then
      return false
    end
    for _, node in query:iter_captures(tree:root(), buf, top, bottom + 1) do
      local first, _, last, last_col = node:range()
      -- The block ends at column 0 of the line after the closing fence.
      if last_col == 0 then
        last = last - 1
      end
      for row = first, last do
        block_rows[row] = true
      end
    end
    return true
  end,

  on_line = function(_, _, buf, row)
    if block_rows[row] then
      vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
        end_row = row + 1,
        end_col = 0,
        hl_group = "MarkdownCodeBlock",
        hl_eol = true,
        priority = 10,
        ephemeral = true,
      })
    end
  end,
})
