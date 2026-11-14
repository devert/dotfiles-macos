-- Jump with two characters, like VSCodeVim sneak.
-- Flash searches both directions and puts a label on every match in view.
--
--   s{ab}{label}   jump to the match that has the label
--   dz{ab}{label}  delete up to the match (VSCodeVim sneak uses z for operators)
--   gl             pick a Treesitter node and select it
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    -- Use only lowercase labels. With more matches than labels, type another
    -- character to narrow the matches.
    label = { uppercase = false },
    -- Show jump labels for f/t/F/T too.
    modes = { char = { jump_labels = true } },
  },
  keys = {
    { "s", mode = { "n", "x" }, function() require("flash").jump() end, desc = "Flash jump" },
    { "z", mode = "o", function() require("flash").jump() end, desc = "Flash jump (operator)" },
    { "gl", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter select" },
  },
}
