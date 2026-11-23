# Neovim TODO

Ideas to add to this configuration later. These come from common Neovim distros (LazyVim, NvChad, AstroNvim, kickstart).

## Format on save with conform.nvim

- Add `conform.nvim` and format each file when you save it.
- The LSP list has `ruff` and `eslint`, but no formatter runs on save.
- Use prettier for JS, TS, JSON, CSS, and Markdown.
- Use stylua for Lua.
- Install the formatters with Mason.

## Close brackets and quotes automatically

- Add `mini.pairs` or `nvim-autopairs`.
- When you type `(`, `[`, `{`, or a quote, the plugin types the closing character.
- VS Code does this by default.

## Start screen

- Add a start screen (dashboard) plugin, such as `snacks.dashboard` or `alpha-nvim`.
- It shows when you open Neovim with no file.
- It can list recent files and projects.
- This only helps if you start Neovim without a file. Skip it if you always open a file from the shell.

## Live grep with arguments

- Add `telescope-live-grep-args.nvim` to `lua/plugins/telescope.lua`.
- It lets you pass ripgrep flags in the grep prompt, such as a file type or a glob.
- For example, `"TODO" -t lua` searches only Lua files.

## Diffs and merge conflicts with diffview.nvim

- Add `diffview.nvim`.
- It shows the diff for all changed files in one view.
- It shows the history of a file or a branch.
- It gives a three-way view to fix merge conflicts.
- This adds to the gitsigns setup, which only shows changes in one buffer.

## Extra text objects with mini.ai

- Add `mini.ai`.
- It adds text objects for function arguments, quotes, and brackets.
- With the Tree-sitter text objects, you can select a whole function or class (for example `vif`).
- It works with the commands from nvim-surround, such as `ci"` and `daa`.
