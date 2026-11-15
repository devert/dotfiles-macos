return {
  "loctvl842/monokai-pro.nvim",
  priority = 1000,
  config = function()
    -- The theme caches its colors on disk, and a change to the override functions
    -- below does not clear that cache. Clear it when this file is newer than the cache.
    local cache_file = vim.fn.stdpath("cache") .. "/monokai-pro-pro.json"
    local cache_stat = vim.uv.fs_stat(cache_file)
    local this_stat = vim.uv.fs_stat(vim.fn.resolve(debug.getinfo(1, "S").source:sub(2)))
    if cache_stat and this_stat and this_stat.mtime.sec >= cache_stat.mtime.sec then
      os.remove(cache_file)
    end

    require("monokai-pro").setup({
      -- bufferline tabs: give the tab bar and all tabs the editor background, like VS Code.
      -- The active tab stands out by its yellow text and the yellow bar on its left.
      override_scheme = function(scheme)
        return {
          editorGroupHeader = { tabsBackground = scheme.editor.background },
          tab = { inactiveBackground = scheme.editor.background },
        }
      end,
      -- Match the VS Code Monokai Pro theme more closely
      override = function(c)
        return {
          -- Keep the theme's dark Directory background. The tab bar change above
          -- would set it to the editor background too.
          Directory = { bg = "#221f22" },
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

    -- ui2 command line (also its dialogs and pager): same background as the file tree.
    -- The theme links MsgArea to ModeMsg, and an override cannot replace a link.
    local scheme = require("monokai-pro").get_scheme()
    vim.api.nvim_set_hl(0, "MsgArea", { fg = scheme.editor.foreground, bg = scheme.sideBar.background })
  end
}
