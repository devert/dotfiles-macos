return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  dependencies = {
    {
      "nvim-tree/nvim-web-devicons",
      config = function()
        -- Use the file icon colors from the Monokai Pro icon theme in VS Code.
        -- Only the colors are changed, the icon shapes stay the same.
        local devicons = require("nvim-web-devicons")
        local colors = require("plugins.nvim-tree.monokai_icon_colors")
        devicons.setup({ default = true })

        local by_ext = devicons.get_icons_by_extension()
        local by_name = devicons.get_icons_by_filename()
        local default_icon = devicons.get_default_icon()
        local icons = {}

        local function extension_of(name)
          local ext = name:match("%.([^.]+)$")
          return ext and ext:lower()
        end

        -- devicons creates one highlight group per icon name. Add the color to the name,
        -- so that icons with the same shape but a different color do not share a group.
        local function entry(base, color)
          return { icon = base.icon, color = color, name = base.name .. color:sub(2) }
        end

        -- Extensions. The theme gives files it does not know the default (yellow) color.
        for ext, base in pairs(by_ext) do
          icons[ext] = entry(base, colors.extensions[ext] or colors.default)
        end

        -- devicons has special icons for some file names that the VS Code theme does not
        -- list (for example README.md). VS Code colors those by extension, so do the same.
        -- (devicons matches file names in lower case.)
        for name, base in pairs(by_name) do
          local ext = extension_of(name)
          local color = (ext and colors.extensions[ext]) or colors.default
          icons[name:lower()] = entry(base, color)
        end

        -- File names that the VS Code theme gives their own color (package.json, Dockerfile, ...)
        for name, color in pairs(colors.filenames) do
          local key = name:lower()
          local ext = extension_of(name)
          local base = by_name[name] or by_name[key] or (ext and by_ext[ext]) or default_icon
          icons[key] = entry(base, color)
        end

        devicons.set_icon(icons)
        devicons.set_default_icon(default_icon.icon, colors.default)
      end,
    },
  },
  init = function()
    -- Disable netrw, the built-in file explorer, before nvim-tree loads
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  keys = {
    { "<C-e>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file tree" },
    { "<leader>e", "<cmd>NvimTreeFindFile<CR>", desc = "Find current file in tree" },
  },
  config = function(_, opts)
    -- Add the decorator that colors folders with changed files (the built-in decorators
    -- keep their order, the new one goes before "Cut")
    -- (before "Diagnostics", so that a warning or error color wins over a git color,
    -- like in VS Code)
    opts.renderer.decorators = {
      "Git",
      require("plugins.nvim-tree.folder_git_decorator"),
      "Open",
      "Hidden",
      "Modified",
      "Bookmark",
      "Diagnostics",
      "Copied",
      "Cut",
    }
    require("nvim-tree").setup(opts)
    require("plugins.nvim-tree.close_if_last_window").setup()

    -- Git status colors from the Monokai Pro theme in VS Code.
    -- Names are colored by git status. Ignored files are dark gray.
    local git_colors = {
      Dirty = "#ffd866", -- modified
      New = "#c1c0c0", -- untracked
      Staged = "#a9dc76", -- added
      Renamed = "#a9dc76",
      Deleted = "#ff6188",
      Merge = "#fc9867", -- conflict
      Ignored = "#5b595c",
    }
    local function git_highlights()
      for status, color in pairs(git_colors) do
        vim.api.nvim_set_hl(0, "NvimTreeFile" .. status, { fg = color })
        vim.api.nvim_set_hl(0, "NvimTreeFolder" .. status, { fg = color })
        vim.api.nvim_set_hl(0, "NvimTreeGit" .. status .. "Icon", { fg = color })
      end
      -- Name under the cursor, for items without a git status (see cursor_highlight.lua)
      vim.api.nvim_set_hl(0, "NvimTreeCursorName", { fg = "#fcfcfa" })
      -- nvim-tree colors executable files, images, symlinks and special files (README,
      -- Makefile, ...) on their own. VS Code shows all of them in the normal gray.
      for _, group in ipairs({ "NvimTreeExecFile", "NvimTreeImageFile", "NvimTreeSymlink", "NvimTreeSpecialFile" }) do
        vim.api.nvim_set_hl(0, group, { fg = "#939293" })
      end
      -- Names of files and folders with warnings (orange) and errors (red)
      for _, kind in ipairs({ "File", "Folder" }) do
        vim.api.nvim_set_hl(0, "NvimTreeDiagnosticWarn" .. kind .. "HL", { fg = "#fc9867" })
        vim.api.nvim_set_hl(0, "NvimTreeDiagnosticError" .. kind .. "HL", { fg = "#ff6188" })
      end
    end
    git_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = git_highlights })
  end,
  opts = {
    on_attach = function(bufnr)
      local api = require("nvim-tree.api")
      api.map.on_attach.default(bufnr)
      require("plugins.nvim-tree.cursor_highlight").attach(bufnr)

      -- :q in the tree quits Neovim when it is the only window left besides the tree,
      -- instead of only closing the tree. With more splits it only closes the tree.
      vim.api.nvim_create_autocmd("QuitPre", {
        buffer = bufnr,
        callback = function()
          local other_windows = 0
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local is_floating = vim.api.nvim_win_get_config(win).relative ~= ""
            local is_tree = vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "NvimTree"
            if not is_floating and not is_tree then
              other_windows = other_windows + 1
            end
          end
          if other_windows <= 1 then
            vim.schedule(function()
              -- Fails with a message when a file has unsaved changes
              local ok, err = pcall(vim.cmd, "qa")
              if not ok then
                vim.notify(err, vim.log.levels.ERROR)
              end
            end)
          end
        end,
      })
      -- <C-e> is "open in place" by default inside the tree, use it to close the tree instead
      vim.keymap.set("n", "<C-e>", api.tree.close, {
        desc = "nvim-tree: Close",
        buffer = bufnr,
        noremap = true,
        silent = true,
        nowait = true,
      })
    end,
    view = {
      width = 35,
    },
    -- Highlight the current file in the tree and open its parent folders when you switch
    -- buffers (for example from Telescope), like the VS Code explorer
    update_focused_file = {
      enable = true,
    },
    renderer = {
      group_empty = true,
      -- Color names by git status and by diagnostics (warnings and errors)
      highlight_git = "name",
      highlight_diagnostics = "name",
      icons = {
        show = {
          -- Hide the folder icon, keep the open / closed arrow
          folder = false,
          -- Diagnostics only color the name, there is no icon
          diagnostics = false,
        },
        -- Git status as a letter on the right, like VS Code
        git_placement = "right_align",
        glyphs = {
          git = {
            unstaged = "M",
            staged = "A",
            unmerged = "C",
            renamed = "R",
            untracked = "U",
            deleted = "D",
            ignored = "",
          },
        },
      },
    },
    git = {
      -- No git letters on folders (folder_git_decorator.lua shows a dot instead)
      show_on_dirs = false,
    },
    diagnostics = {
      -- Only warnings and errors, like the VS Code explorer. Needs a language server.
      enable = true,
      show_on_dirs = true,
      show_on_open_dirs = true,
      severity = { min = vim.diagnostic.severity.WARN },
    },
    filters = {
      -- Show git ignored files (they are drawn in dark gray)
      git_ignored = false,
      -- Show hidden files, but hide a few noisy ones
      dotfiles = false,
      custom = { "^\\.git$", "\\.swp$", "\\.swo$", "\\.pyc$", "^\\.DS_Store$" },
    },
    actions = {
      open_file = {
        -- Keep the tree open after opening a file
        quit_on_open = false,
      },
    },
  },
}
