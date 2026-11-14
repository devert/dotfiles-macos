-- Cache compiled Lua modules to speed up startup
vim.loader.enable()

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("options")
require("markdown-code-blocks")
require("lazy").setup("plugins", {
  performance = {
    rtp = {
      -- Built-in plugins that are not used. netrw is replaced by nvim-tree.
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "zipPlugin",
        "tohtml",
        "tutor",
        "netrwPlugin",
        "rplugin",
        "spellfile",
        "matchit",
      },
    },
  },
})
