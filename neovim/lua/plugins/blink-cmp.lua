-- Completion menu like the VS Code suggest widget: kind icons and colors, a docs
-- panel, and fuzzy matching. The items come from the language servers
-- (lua/plugins/lsp-config.lua), file paths, snippets, and words in the buffer.
-- monokai-pro.nvim colors the menu. See :h blink-cmp-config for all options.

-- Fix for a blink.cmp bug in the docs panel height. blink.cmp counts the lines of
-- the docs at full width (up to max_width), and then makes the panel narrower to fit
-- next to the menu. The text wraps onto more lines, but the height stays the same,
-- so the panel scrolls with free space below it. This runs the placement a second
-- time with the narrow width, so the height counts the wrapped lines.
local function fix_docs_height()
  local docs = require("blink.cmp.completion.windows.documentation")
  local place = docs.update_position
  docs.update_position = function()
    place()
    local win = docs.win:get_win()
    if not docs.win:is_open() or not win then
      return
    end
    local needed = vim.api.nvim_win_text_height(win, {}).all
    if needed <= vim.api.nvim_win_get_height(win) then
      return
    end
    -- Keep the narrow width this time. The placement still limits the height to
    -- the free space on the screen.
    local width = vim.api.nvim_win_get_width(win)
    local max_height = docs.win.config.max_height
    docs.win.update_size = function(self)
      vim.api.nvim_win_set_width(self:get_win(), width)
      vim.api.nvim_win_set_height(self:get_win(), math.min(needed, max_height))
    end
    pcall(place)
    docs.win.update_size = nil
  end
end

return {
  "saghen/blink.cmp",
  -- Release versions download a prebuilt fuzzy matcher, so no Rust build is needed.
  version = "1.*",
  event = "InsertEnter",
  opts = {
    -- Ctrl+Space opens the menu. Most terminals send Ctrl+Space as <C-@>, so both
    -- keys are mapped. Tab and Shift+Tab, Down and Up, and Ctrl+J and Ctrl+K (like
    -- Telescope) move through the items. Without the menu, these keys do their normal
    -- job. Enter accepts the selected item, and with nothing selected it makes a new line.
    keymap = {
      preset = "none",
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-@>"] = { "show", "show_documentation", "hide_documentation" },
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-e>"] = { "cancel", "fallback" },
      -- Ctrl+D and Ctrl+U scroll the docs panel down and up, like half-page scroll
      -- in normal mode
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      ["<C-u>"] = { "scroll_documentation_up", "fallback" },
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    completion = {
      -- The menu opens only with Ctrl+Space, not while you type.
      trigger = {
        show_on_keyword = false,
        show_on_trigger_character = false,
      },
      -- Select nothing until Tab, and do not insert the item until Enter.
      list = {
        selection = { preselect = false, auto_insert = false },
      },
      menu = {
        border = "none",
        draw = {
          columns = {
            { "kind_icon" },
            { "label", "label_description", gap = 1 },
            { "kind" },
          },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        -- The docs show to the right of the menu if at least desired_min_width columns
        -- are free there (default 50). If not, they show on the left. The panel gets
        -- narrower to fit the space. The panel is as tall as the docs need. A large
        -- max_height (default 20) removes the fixed limit, so long docs fill all the
        -- space below or above the cursor before they need to scroll.
        window = {
          border = "none",
          desired_min_width = 30,
          max_height = 1000,
        },
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  config = function(_, opts)
    require("blink.cmp").setup(opts)
    fix_docs_height()
  end,
}
