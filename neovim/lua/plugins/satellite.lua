-- Git change markers on the right edge of the window, inspired by the VS Code
-- overview ruler. The markers show the added, changed, and deleted lines of the
-- whole file in the gitsigns colors. They show only in the active window, and
-- only when the file does not fit on the screen.
-- The bar is 3 cells wide. Each marker is a thin block in the middle cell. A
-- light line in the right cell shows the cursor position.
-- :SatelliteDisable and :SatelliteEnable turn the markers off and on.
return {
  "lewis6991/satellite.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    current_only = true,
    winblend = 0,
    width = 4,
    excluded_filetypes = { "NvimTree", "lazy", "mason", "TelescopePrompt", "gitcommit", "gitrebase" },
    handlers = {
      cursor = { enable = false }, -- the git handler below draws the cursor line
      search = { enable = false },
      diagnostic = { enable = false },
      gitsigns = { enable = false }, -- replaced by the custom handler below
      marks = { enable = false },
      quickfix = { enable = false },
    },
  },
  config = function(_, opts)
    -- Hide the scrollbar thumb and track: paint both like the editor background.
    local function hide_bar()
      local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
      vim.api.nvim_set_hl(0, "SatelliteBackground", { bg = normal.bg })
      vim.api.nvim_set_hl(0, "SatelliteBar", { bg = normal.bg })
    end
    hide_bar()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = hide_bar,
    })

    -- Git handler. A mark is the upper or lower half of the right quarter of the
    -- middle cell (U+1CEAC, U+1CEAF), or the whole right quarter (U+1FB87).
    local rank_by_type = { add = 1, delete = 2, change = 3 }
    local source_hl = { add = "GitSignsAdd", change = "GitSignsChange", delete = "GitSignsDelete" }

    -- Highlight group for a mark of this hunk type.
    local function cell_highlight(kind)
      local name = "SatelliteHunk_" .. kind
      vim.api.nvim_set_hl(0, name, { fg = vim.api.nvim_get_hl(0, { name = source_hl[kind], link = false }).fg })
      return name
    end

    -- The cursor line at 4 heights inside a cell: top, upper middle, lower middle,
    -- and bottom. Its color is the text color, 70% of the way from the background.
    local line_glyphs = { "⎺", "⎻", "⎼", "⎽" }
    local function line_highlight()
      local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
      local fg, bg = normal.fg or 0xcccccc, normal.bg or 0x000000
      local function mix(shift)
        local f, b = math.floor(fg / 2 ^ shift) % 256, math.floor(bg / 2 ^ shift) % 256
        return math.floor(0.7 * f + 0.3 * b + 0.5)
      end
      vim.api.nvim_set_hl(0, "SatelliteCursorLine", { fg = mix(16) * 65536 + mix(8) * 256 + mix(0) })
      return "SatelliteCursorLine"
    end

    -- satellite adds the fields `enabled` and `ns` itself when it registers the
    -- handler, so the language server is wrong to ask for them here.
    ---@diagnostic disable-next-line: missing-fields
    require("satellite.handlers").register({
      name = "git_hunks",
      config = { enable = true, priority = 20, overlap = true },

      -- Redraw when gitsigns has new changes (GitSignsChanged), after a branch
      -- change (GitSignsUpdate), and when the cursor moves.
      setup = function(_, update)
        vim.api.nvim_create_autocmd("User", {
          pattern = { "GitSignsChanged", "GitSignsUpdate" },
          callback = update,
        })
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, { callback = update })
      end,

      update = function(bufnr, winid)
        local util = require("satellite.util")
        local height = util.get_winheight(winid)
        if not package.loaded.gitsigns or height < 2 then
          return {}
        end

        -- Exact bar position of a buffer row in cells.
        local function bar_pos(row)
          local rounded, diff = util.row_to_barpos(winid, row)
          return (rounded - diff) * height / (height - 1)
        end

        -- Bar position of a buffer row in half cells: 0 to 2 * height - 1.
        local function half_cell(row)
          return math.max(0, math.min(2 * height - 1, math.floor(bar_pos(row) * 2)))
        end

        local winner = {} -- half cell -> hunk type with the highest rank
        for _, hunk in ipairs(require("gitsigns").get_hunks(bufnr) or {}) do
          local first = math.max(1, hunk.added.start)
          local last = math.max(1, hunk.added.start + math.max(0, hunk.added.count - 1))
          for half = half_cell(first - 1), half_cell(last - 1) do
            local current = winner[half]
            if not current or rank_by_type[hunk.type] > rank_by_type[current] then
              winner[half] = hunk.type
            end
          end
        end

        -- A cell with two different hunks cannot show both colors in one column.
        -- Move the lower hunk down into the next half cell if it is free. If not,
        -- move the upper hunk up into the half cell above. If that is taken too,
        -- the higher ranked type wins both halves.
        for cell = 0, height - 1 do
          local top, bottom = winner[2 * cell], winner[2 * cell + 1]
          if top and bottom and top ~= bottom then
            if cell + 1 < height and not winner[2 * cell + 2] then
              winner[2 * cell + 2], winner[2 * cell + 1] = bottom, nil
            elseif cell > 0 and not winner[2 * cell - 1] then
              winner[2 * cell - 1], winner[2 * cell] = top, nil
            else
              local best = rank_by_type[top] >= rank_by_type[bottom] and top or bottom
              winner[2 * cell], winner[2 * cell + 1] = best, best
            end
          end
        end

        -- Bar position of the cursor in cells. The fraction picks one of 4 line
        -- heights inside the cell.
        local cursor_row = vim.api.nvim_win_get_cursor(winid)[1] - 1
        local cursor_exact = math.max(0, math.min(height - 0.001, bar_pos(cursor_row)))
        local cursor_cell = math.floor(cursor_exact)
        local cursor_step = math.min(3, math.floor((cursor_exact - cursor_cell) * 4)) + 1

        -- An empty sign keeps the sign column, which makes the bar 3 cells wide.
        -- The marks below are text that is drawn over the sign column.
        local marks = { { pos = 0, symbol = "  ", highlight = "Normal", column = "sign" } }
        for cell = 0, height - 1 do
          local top, bottom = winner[2 * cell], winner[2 * cell + 1]
          local line = cell == cursor_cell and line_glyphs[cursor_step] or nil
          -- Marks are in the middle cell and the line is always in the right
          -- cell, so the line never hides a mark and never moves sideways.
          if top or bottom then
            local symbol = (top and bottom) and "🮇" or (top and "𜺬" or "𜺯")
            marks[#marks + 1] = { pos = cell, symbol = symbol, highlight = cell_highlight(top or bottom), column = "middle" }
          end
          if line then
            marks[#marks + 1] = { pos = cell, symbol = line, highlight = line_highlight(), column = "right" }
          end
        end
        return marks
      end,

      -- The sign column is the left and middle cells, and the text column is the
      -- right cell. Each mark gets its own extmark, so marks in one row do not
      -- replace each other.
      apply_mark = function(self, bufnr, m, max_pos)
        if m.pos > max_pos then
          return
        end
        local extmark
        if m.column == "sign" then
          extmark = { priority = 1, sign_text = m.symbol }
        else
          extmark = {
            priority = self.config.priority,
            virt_text = { { m.symbol, m.highlight } },
            virt_text_pos = "overlay",
            hl_mode = "combine",
          }
          if m.column == "middle" then
            extmark.virt_text_win_col = -1
          end
        end
        pcall(vim.api.nvim_buf_set_extmark, bufnr, self.ns, m.pos, 0, extmark)
      end,
    })

    require("satellite").setup(opts)
  end,
}
