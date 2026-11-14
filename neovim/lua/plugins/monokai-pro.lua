return {
  "loctvl842/monokai-pro.nvim",
  priority = 1000,
  config = function()
    require("monokai-pro").setup({
      -- Match the VS Code Monokai Pro theme more closely
      override = function(c)
        return {
          ["@keyword.coroutine"] = { fg = "#ff6188", italic = true },
          DiagnosticHint = { fg = "#ab9df2" },
          DiagnosticSignHint = { fg = "#ab9df2" },
          DiagnosticFloatingHint = { fg = "#ab9df2" },
          DiagnosticUnderlineHint = { sp = "#ab9df2", undercurl = true },
          PmenuSel = { bg = "#5b595c" },
          MatchParen = { fg = "NONE", bg = "#403e41" },
          -- flash.nvim: pink label letters, dim gray matches on a gray background, blue current match, dimmed backdrop
          FlashLabel = { fg = "#ff6188", bg = "NONE", bold = true },
          FlashMatch = { fg = "#c1c0c0", bg = "#5b595c" },
          FlashCurrent = { fg = "#2d2a2e", bg = "#78dce8" },
          FlashBackdrop = { fg = "#727072" },
          -- CSS: class selectors green, id selectors orange, pseudo classes/elements teal italic
          ["@type.css"] = { fg = "#a9dc76" },
          ["@constant.css"] = { fg = "#fc9867" },
          ["@attribute.css"] = { fg = "#78dce8", italic = true },
          -- HTML: attribute "=" gray, entities (&amp;) purple, link text plain
          ["@operator.html"] = { fg = "#939293" },
          ["@character.special.html"] = { fg = "#ab9df2" },
          ["@markup.link.label.html"] = { fg = "#fcfcfa" },
          -- Markdown: block quotes italic
          ["@markup.quote.markdown"] = { italic = true },
          -- Markdown code blocks: the theme paints a dark background only behind the
          -- characters. Remove it here. lua/markdown-code-blocks.lua paints the whole
          -- block, so the syntax colors of the code stay.
          ["@markup.raw.block.markdown"] = { bg = "NONE" },
          ["@markup.raw.delimiter.markdown"] = { fg = c.base.dimmed2, bg = "NONE" },
          MarkdownCodeBlock = { bg = c.base.black },
        }
      end,
    })
    vim.cmd([[colorscheme monokai-pro]])
  end
}
