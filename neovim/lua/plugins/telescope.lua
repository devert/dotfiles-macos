-- Fuzzy finder for files, text, buffers, and help.
-- Telescope loads on the first <leader>f key, :Telescope command, or vim.ui.select prompt.
-- live_grep needs ripgrep (installed by brew/install.sh).
return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    -- Native sorter: faster, better ranking, and fzf query syntax ('exact, ^prefix, !not).
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    -- Show vim.ui.select prompts (for example LSP code actions) in Telescope.
    "nvim-telescope/telescope-ui-select.nvim",
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Grep in project" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Find help" },
    { "<leader>fc", "<cmd>Telescope git_status<CR>", desc = "Find changed files (git)" },
  },
  init = function()
    -- Load Telescope the first time something calls vim.ui.select.
    -- Loading ui-select replaces vim.ui.select, so the second call uses Telescope.
    vim.ui.select = function(...)
      require("lazy").load({ plugins = { "telescope.nvim" } })
      return vim.ui.select(...)
    end
  end,
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            -- One Esc closes Telescope (the default goes to normal mode first)
            ["<Esc>"] = actions.close,
          },
        },
      },
      extensions = {
        ["ui-select"] = { require("telescope.themes").get_dropdown() },
      },
    })

    telescope.load_extension("fzf")
    telescope.load_extension("ui-select")
  end,
}
