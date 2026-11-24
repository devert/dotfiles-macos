-- Diff view for all changed files, file and branch history, and a three-way
-- merge conflict view. gitsigns only shows changes in one buffer.
-- See :h diffview for all options.
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  keys = {
    { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diff view of all changes" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "History of this file" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "History of the branch" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
  },
  config = function(_, opts)
    require("diffview").setup(opts)
    -- The theme gives Directory a dark background, which shows behind the folder
    -- names in the file panel. Use the same text color without the background.
    local function folder_name()
      local fg = vim.api.nvim_get_hl(0, { name = "Directory", link = false }).fg
      vim.api.nvim_set_hl(0, "DiffviewFolderName", { fg = fg })
    end
    folder_name()

    -- Close all diff views before persistence.nvim saves the session. A session
    -- cannot restore a diff view. It brings back a broken tab with empty windows
    -- and diffview:// buffers.
    vim.api.nvim_create_autocmd("User", {
      pattern = "PersistenceSavePre",
      callback = function()
        for _, view in ipairs(require("diffview.lib").views) do
          pcall(view.close, view)
        end
      end,
    })
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        vim.schedule(folder_name)
      end,
    })
  end,
  opts = function()
    local actions = require("diffview.actions")
    -- Open the file under the cursor, then move focus to the diff on the right so
    -- that you can scroll it.
    local function open_and_focus()
      actions.select_entry()
      local view = require("diffview.lib").get_current_view()
      local main = view and view.cur_layout and view.cur_layout:get_main_win()
      if main and main.id and vim.api.nvim_win_is_valid(main.id) then
        vim.api.nvim_set_current_win(main.id)
      end
    end
    return {
      enhanced_diff_hl = true,
      keymaps = {
        file_panel = {
          { "n", "<cr>", open_and_focus, { desc = "Open the diff and focus it" } },
        },
      },
      -- Diffview has its own tab page, but bufferline lists every buffer. Hide the
      -- tab bar while a diff view is active, and show it again when you leave.
      hooks = {
        view_enter = function()
          vim.o.showtabline = 0
        end,
        view_leave = function()
          vim.o.showtabline = 2
        end,
        view_closed = function()
          vim.o.showtabline = 2
        end,
      },
    }
  end,
}
