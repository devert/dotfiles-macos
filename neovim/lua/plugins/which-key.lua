return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- Milliseconds to wait before the popup opens. The marks and registers
    -- popups open at once. All other popups wait 500 ms (default 200).
    delay = function(ctx)
      if ctx.plugin == "marks" or ctx.plugin == "registers" then
        return 0
      end
      return 500
    end,
    spec = {
      { "<leader>t", group = "tabs" },
      { "<leader>s", group = "search" },
      { "<leader>g", group = "git" },
      { "<leader>w", group = "windows" },
      { "<leader>u", group = "toggles" },
      { "gr", group = "LSP" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer local keymaps (which-key)",
    },
  },
}
