# Neovim TODO

Ideas to add to this configuration later. These come from common Neovim distros (LazyVim, NvChad, AstroNvim, kickstart).

## Format on save with conform.nvim

- Add `conform.nvim` and format each file when you save it.
- The LSP list has `ruff` and `eslint`, but no formatter runs on save.
- Use prettier for JS, TS, JSON, CSS, and Markdown.
- Use stylua for Lua.
- Install the formatters with Mason.

## Keep undo history with `undofile`

- Set `vim.opt.undofile = true` in `lua/options.lua`.
- The swap file is off (`swapfile = false`), so the undo history is the only way to recover work after a crash or restart.

## Keep context lines with `scrolloff`

- Set `vim.opt.scrolloff` to a value from 4 to 8 in `lua/options.lua`.
- The cursor then stays a few lines away from the top and bottom edge of the window.

## Close brackets and quotes automatically

- Add `mini.pairs` or `nvim-autopairs`.
- When you type `(`, `[`, `{`, or a quote, the plugin types the closing character.
- VS Code does this by default.

## Start screen

- Add a start screen (dashboard) plugin, such as `snacks.dashboard` or `alpha-nvim`.
- It shows when you open Neovim with no file.
- It can list recent files and projects.
- This only helps if you start Neovim without a file. Skip it if you always open a file from the shell.

## Better Telescope pickers

- Add more pickers to `lua/plugins/telescope.lua`.
- Live grep with arguments (`telescope-live-grep-args.nvim`) lets you pass flags such as a file type or a glob.
- A recent files picker (`oldfiles`) or a frecency picker lists the files you open most.
- A `<leader>/` key searches fuzzily inside the current buffer.

## Diffs and merge conflicts with diffview.nvim

- Add `diffview.nvim`.
- It shows the diff for all changed files in one view.
- It shows the history of a file or a branch.
- It gives a three-way view to fix merge conflicts.
- This adds to the gitsigns setup, which only shows changes in one buffer.

## Session restore with persistence.nvim

- Add `persistence.nvim`.
- It saves the open buffers (tabs) for each project folder.
- You can restore them the next time you open Neovim in that folder.
- This fits the bufferline tabs, because it brings back the same tabs.

## Extra text objects with mini.ai

- Add `mini.ai`.
- It adds text objects for function arguments, quotes, and brackets.
- With the Tree-sitter text objects, you can select a whole function or class (for example `vif`).
- It works with the commands from nvim-surround, such as `ci"` and `daa`.

## Code folding with Tree-sitter

- Set `vim.opt.foldmethod = "expr"` and `vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"` in `lua/options.lua`.
- Set `vim.opt.foldlevelstart = 99` so that all folds are open when you open a file.
- Use `za` to open or close a fold, and `zM` and `zR` to close or open all folds.
