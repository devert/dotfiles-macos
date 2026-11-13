-- Add, change, and delete surrounding pairs: ys{motion}{char}, cs{old}{new}, ds{char}.
-- Since v4, setup() is optional and only changes configuration.
-- See :h nvim-surround.configuration to change it.
return {
  "kylechui/nvim-surround",
  version = "^4.0.0", -- Stay on v4 until a breaking release is reviewed
  event = "VeryLazy",
}
