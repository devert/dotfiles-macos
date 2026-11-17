-- Colors nested brackets by depth, like the bracket pair colors in VS Code.
-- It uses Tree-sitter. The colors (RainbowDelimiter*) are set in lua/plugins/monokai-pro.lua.
return {
  "HiPhish/rainbow-delimiters.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("rainbow-delimiters.setup").setup({
      -- Same order as VS Code: pink, orange, yellow, green, cyan, purple
      highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterOrange",
        "RainbowDelimiterYellow",
        "RainbowDelimiterGreen",
        "RainbowDelimiterCyan",
        "RainbowDelimiterViolet",
      },
    })
  end,
}
