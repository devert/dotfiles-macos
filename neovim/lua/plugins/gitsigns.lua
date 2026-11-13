-- Git change markers in the sign column, and ]c / [c to jump between changes.
-- <leader>g keymaps preview, reset, and diff the changes.
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

      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
      end

      map("n", "<leader>gp", gitsigns.preview_hunk_inline, "Preview change inline")
      map("n", "<leader>gP", gitsigns.preview_hunk, "Preview change in a window")
      map("n", "<leader>gr", gitsigns.reset_hunk, "Reset change")
      map("v", "<leader>gr", function()
        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset selected lines")
      map("n", "<leader>gd", gitsigns.diffthis, "Diff file against last commit")
    end,
  },
}
