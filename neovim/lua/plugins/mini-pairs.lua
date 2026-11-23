-- Auto pairs: typing (, [, {, or a quote adds the closing character, like VS Code.
-- Typing the closing character next to it moves over it. Backspace between a pair
-- deletes both, and Enter between a pair of brackets opens an empty line inside.
-- See :h MiniPairs for all options.
return {
  "nvim-mini/mini.pairs",
  event = "InsertEnter",
  opts = {},
}
