return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local languages = {
      "lua", "javascript", "typescript", "tsx", "python",
      "json", "html", "css", "markdown", "bash",
    }
    require("nvim-treesitter").install(languages)

    vim.api.nvim_create_autocmd("FileType", {
      callback = function() pcall(vim.treesitter.start) end,
    })
  end,
}
