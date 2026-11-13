-- Multiple cursors, with keys close to the VSCodeVim multi-cursor mode.
-- Every cursor runs the same Normal, Visual, and Insert mode commands.
--
--   gb / gB         add a cursor at the next / previous match of the word or selection
--                   (VSCodeVim gb, VS Code Cmd+D)
--   gA              add a cursor at every match (VS Code Cmd+Shift+L)
--   Alt+Up/Down     add a cursor on the line above / below (VS Code Opt+Cmd+Up/Down)
--   Ctrl+click      add or remove a cursor (VS Code Cmd+click)
--   I / A           in Visual mode, insert / append on each selected line
--
-- While there are multiple cursors:
--   gs / gS         skip the next / previous match (VS Code Cmd+K Cmd+D)
--   Left / Right    make the previous / next cursor the main cursor
--   <leader>x       delete the main cursor
--   Esc             remove all cursors except the main cursor
return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { desc = desc })
    end

    map({ "n", "x" }, "gb", function() mc.matchAddCursor(1) end, "Add cursor at next match")
    map({ "n", "x" }, "gB", function() mc.matchAddCursor(-1) end, "Add cursor at previous match")
    map({ "n", "x" }, "gA", mc.matchAllAddCursors, "Add cursor at every match")

    map({ "n", "x" }, "<M-Up>", function() mc.lineAddCursor(-1) end, "Add cursor above")
    map({ "n", "x" }, "<M-Down>", function() mc.lineAddCursor(1) end, "Add cursor below")

    map("n", "<C-LeftMouse>", mc.handleMouse, "Add or remove cursor")
    map("n", "<C-LeftDrag>", mc.handleMouseDrag, "Add cursors by dragging")
    map("n", "<C-LeftRelease>", mc.handleMouseRelease, "Finish cursor drag")

    map("x", "I", mc.insertVisual, "Insert on each selected line")
    map("x", "A", mc.appendVisual, "Append on each selected line")

    -- These keys apply only while there are multiple cursors.
    mc.addKeymapLayer(function(layer)
      layer({ "n", "x" }, "gs", function() mc.matchSkipCursor(1) end)
      layer({ "n", "x" }, "gS", function() mc.matchSkipCursor(-1) end)
      layer({ "n", "x" }, "<Left>", mc.prevCursor)
      layer({ "n", "x" }, "<Right>", mc.nextCursor)
      layer({ "n", "x" }, "<leader>x", mc.deleteCursor)
      layer("n", "<Esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)
  end,
}
