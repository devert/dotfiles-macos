-- Git change markers in the sign column, and ]c / [c to jump between changes.
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(buf)
      local gitsigns = require("gitsigns")

      -- In diff mode, keep the built-in ]c / [c that jump between diff changes.
      local function jump(direction, builtin)
        if vim.wo.diff then
          vim.cmd.normal({ builtin, bang = true })
        else
          gitsigns.nav_hunk(direction)
        end
      end

      vim.keymap.set("n", "]c", function() jump("next", "]c") end, { buffer = buf, desc = "Next git change" })
      vim.keymap.set("n", "[c", function() jump("prev", "[c") end, { buffer = buf, desc = "Previous git change" })
    end,
  },
}
