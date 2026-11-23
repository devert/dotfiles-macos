# Neovim Configuration

- Entry point: `init.lua` (bootstraps lazy.nvim and loads configs)
- Core settings and keymaps: `lua/options.lua` (leader key = Space). `<leader>ga` there opens all modified and untracked files as tabs, in any buffer.
- Plugin definitions: one spec per file in `lua/plugins/*.lua`, or a directory with an `init.lua` for larger specs (`lua/plugins/nvim-tree/`). `lua/plugins.lua` returns an empty table.
- Folding: Tree-sitter finds the folds, and all folds are open at the start. `<leader><leader>f` toggles the fold under the cursor, `<leader><leader>F` closes all folds, and `<leader><leader>u` opens all folds (`zM` and `zR` also work). VS Code uses the same three keys. The gutter shows a `▸` chevron on the first line of each closed fold and a collapsed line ends with `⋯ N lines`. The settings are in `lua/options.lua`, and the colors are in `lua/plugins/monokai-pro.lua`.
- Locked versions: `lazy-lock.json`

`neovim/install.sh` installs `neovim` and `tree-sitter-cli` with Homebrew. Then it symlinks `init.lua`, `lazy-lock.json`, and `lua/` into `~/.config/nvim/`.

Active plugins: Monokai Pro theme, Tree-sitter, LSP (nvim-lspconfig with Mason and mason-lspconfig), nvim-tree, lualine, gitsigns (keymaps under `<leader>g`), nvim-surround, Which-key, Telescope (with fzf-native and ui-select, keymaps under `<leader>f`, and `<leader>/` searches the current buffer), auto-save.nvim (saves when you leave a buffer or switch away from Neovim, `:ASToggle` turns it off and on; Cmd+S saves on demand through F13), multicursor.nvim, flash.nvim, satellite.nvim, bufferline.nvim (with mini.bufremove), rainbow-delimiters.nvim, persistence.nvim.

bufferline.nvim shows a tab for each open buffer, like the VS Code editor tabs. Vim tab pages are not used. `Shift+H` and `Shift+L` go to the previous and next tab. `<leader>1` to `<leader>9` go to a tab by position. `<leader>tc` closes the tab, `<leader>to` closes the other tabs, and `<leader>tt` picks a tab by letter. Tabs close with mini.bufremove, so the window and the nvim-tree layout stay. The colors come from monokai-pro.nvim (`themable = true`). `lua/plugins/monokai-pro.lua` gives the tab bar and all tabs the editor background and draws a yellow bar on the left of the active tab. `lua/plugins/bufferline.lua` sets the bar to the thin `▏` character. The space above nvim-tree uses the tree background (`NvimTreeNormal`).

monokai-pro.nvim caches its colors in `~/.cache/nvim/monokai-pro-pro.json`, and a change to its override functions does not clear that cache. `lua/plugins/monokai-pro.lua` deletes the cache when the file is newer than the cache.

multicursor.nvim uses keys like the VSCodeVim multi-cursor mode. `gb` adds a cursor at the next match. Alt+Up/Down adds a cursor above or below. Esc removes the extra cursors. `lua/plugins/multicursor.lua` lists all the keys.

flash.nvim jumps like the VSCodeVim sneak plugin. `s` plus two characters shows a label on each match, and you press a label to jump. `z` does the same after an operator, for example `dz`, because `s` is used by nvim-surround. `gl` selects a Tree-sitter node. Labels are lowercase only, and `f`, `t`, `F`, and `T` also show labels. The Flash colors are set in `lua/plugins/monokai-pro.lua`.

Messages use the experimental ui2 UI (`vim._core.ui2`) with `cmdheight = 0`. Messages close after 4 seconds. In Rex, Padding Fill must be Off (`Workspace.terminalPaddingColor = background`), or the status line colors stretch into the padding under it.

satellite.nvim shows git change markers (gitsigns colors) on the right edge of the window. It works like the VS Code overview ruler and is inspired by it. The bar is 3 cells wide. Each marker is a thin block, a quarter of a cell wide and half a cell tall, at the right edge of the middle cell. All markers stay in one column. Each cell is split into a top and a bottom half. When two different hunks share a cell, the lower one moves down into the next half cell if it is free. If both places are taken, a change wins over a delete, and a delete wins over an add. A custom handler in `lua/plugins/satellite.lua` draws them. A light line, one cell wide, shows the cursor position in the right cell of the bar, next to the markers. It moves in 4 steps per cell. There is no scrollbar thumb or track. `:SatelliteDisable` and `:SatelliteEnable` turn it off and on.

Markdown code blocks get a dark background over the whole block, from the left edge to the right edge of the window, including the ``` lines and empty lines. `lua/markdown-code-blocks.lua` paints it, and `MarkdownCodeBlock` in `lua/plugins/monokai-pro.lua` sets the color. The theme's own background behind the characters is removed. The code keeps its syntax colors. To drop the background, set `MarkdownCodeBlock` to `bg = "NONE"`.

rainbow-delimiters.nvim colors nested brackets by depth, in the same order as VS Code (pink, orange, yellow, green, cyan, purple). The colors are the `RainbowDelimiter*` groups in `lua/plugins/monokai-pro.lua`.

persistence.nvim saves a session for each folder and git branch when Neovim quits, if at least one file is open. A plain `nvim` (no files, no folder) restores the session for the current folder. `nvim <file>`, `nvim <dir>`, and `:restart` do not. The keys are under `<leader>s`: `ss` restores the session for the folder, `sl` restores the last session, `sS` picks a session, and `sd` stops the save on quit. bufferline shows the restored buffers as tabs. A session cannot save the nvim-tree window, so `'sessionoptions'` in `lua/options.lua` has no `blank`. Instead, `lua/plugins/nvim-tree/session.lua` keeps `vim.g.NvimTreeOpen` (saved through `globals`) and opens the tree again after any session loads, also after `:restart`. The cursor stays in the editor.

`neovim/README.md` lists the known color differences between Monokai Pro in Neovim and in VS Code.
