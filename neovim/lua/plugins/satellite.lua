-- Git change markers on the right edge, like the VS Code overview ruler. The
-- markers show added, changed, and deleted lines for the whole file, so you can
-- see them without scrolling. There is no scrollbar thumb or track, only the
-- markers. The markers use the gitsigns colors and show only in the active
-- window. They hide when the whole file fits on screen, because the sign column
-- shows them.
-- The layout copies the VS Code overview ruler, measured from a screenshot. The
-- bar is 3 cells wide. Each hunk is a small square, half a cell wide and half a
-- cell tall, in the right half of the middle cell. That is about 9 px wide and
-- 28 px from the edge, like VS Code. Each cell is split into a top and a bottom
-- half. All marks stay in one column. A cell can only hold one color per column,
-- so when two different hunks share a cell, the lower one moves down into the
-- next half cell if it is free (and otherwise the upper one moves up). If both
-- places are taken, the hunk with the higher rank wins: a change wins over a
-- delete, and a delete wins over an add.
-- The cursor line crosses the middle and right cells, at one of 4 heights inside
-- the cell, so it moves 4 times per cell. In a cell with a mark, the mark takes
-- the middle cell and the line is only in the right cell, at the same height.
-- Its color is the text color, 70% of the way from the background, which is the
-- VS Code color in Monokai Pro.
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

    -- Git handler. A mark is a quarter block, which is a small square. It sits in
    -- the right half of the middle cell of the bar. Its glyph is the top
    -- right or the bottom right quarter of the cell, or the whole right half
    -- when both halves of the cell hold the same type.
    local rank_by_type = { add = 1, delete = 2, change = 3 }
    local source_hl = { add = "GitSignsAdd", change = "GitSignsChange", delete = "GitSignsDelete" }

    local function color_of(kind)
      local hl = vim.api.nvim_get_hl(0, { name = source_hl[kind], link = false })
      return hl.fg
    end

    -- Color of the cursor line: the text color, 70% of the way from the
    -- background.
    local function cursor_color()
      local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
      local fg, bg = normal.fg or 0xcccccc, normal.bg or 0x000000
      local function mix(shift)
        local f, b = math.floor(fg / 2 ^ shift) % 256, math.floor(bg / 2 ^ shift) % 256
        return math.floor(0.7 * f + 0.3 * b + 0.5)
      end
      return mix(16) * 65536 + mix(8) * 256 + mix(0)
    end

    -- Highlight group for a mark. top and bottom are hunk types or nil. The color
    -- is that of the first one that is set.
    local function cell_highlight(top, bottom)
      local kind = top or bottom
      local name = "SatelliteHunk_" .. kind
      vim.api.nvim_set_hl(0, name, { fg = color_of(kind) })
      return name
    end

    -- The cursor line at 4 heights inside a cell: top, upper middle, lower middle,
    -- and bottom.
    local line_glyphs = { "⎺", "⎻", "⎼", "⎽" }
    local function line_highlight()
      vim.api.nvim_set_hl(0, "SatelliteCursorLine", { fg = cursor_color() })
      return "SatelliteCursorLine"
    end

    -- satellite adds the fields `enabled` and `ns` itself when it registers the
    -- handler, so the language server is wrong to ask for them here.
    ---@diagnostic disable-next-line: missing-fields
    require("satellite.handlers").register({
      name = "git_hunks",
      config = { priority = 20, overlap = true },

      setup = function(_, update)
        vim.api.nvim_create_autocmd("User", {
          pattern = { "GitSignsChanged", "GitSignsUpdate" },
          callback = update,
        })
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, { callback = update })
      end,

      update = function(bufnr, winid)
        local height = require("satellite.util").get_winheight(winid)
        if not package.loaded.gitsigns or height < 2 then
          return {}
        end
        local util = require("satellite.util")

        -- Bar position of a buffer row in half cells: 0 to 2 * height - 1.
        local function half_cell(row)
          local rounded, diff = util.row_to_barpos(winid, row)
          local exact = rounded - diff
          local half = math.floor(exact * height / (height - 1) * 2)
          return math.max(0, math.min(2 * height - 1, half))
        end

        local winner = {} -- half cell -> hunk type with the highest rank
        for _, hunk in ipairs(require("gitsigns").get_hunks(bufnr) or {}) do
          local first = math.max(1, hunk.added.start)
          local last = math.max(1, hunk.added.start + math.max(0, hunk.added.count - 1))
          for half = half_cell(first - 1), half_cell(last - 1) do
            local current = winner[half]
            if not current or (rank_by_type[hunk.type] or 0) > (rank_by_type[current] or 0) then
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

        -- Exact bar position of the cursor row in cells. The whole part is the cell,
        -- and the fraction picks one of 4 line heights inside the cell.
        local cursor_row = vim.api.nvim_win_get_cursor(winid)[1] - 1
        local rounded, diff = util.row_to_barpos(winid, cursor_row)
        local cursor_exact = math.max(0, math.min(height - 0.001, (rounded - diff) * height / (height - 1)))
        local cursor_cell = math.floor(cursor_exact)
        local cursor_step = math.min(3, math.floor((cursor_exact - cursor_cell) * 4)) + 1

        -- An empty sign keeps the sign column, which makes the bar 3 cells wide.
        -- The marks below are text that is drawn over the sign column.
        local marks = { { pos = 0, symbol = "  ", highlight = "Normal", column = "sign" } }
        for cell = 0, height - 1 do
          local top, bottom = winner[2 * cell], winner[2 * cell + 1]
          local line = cell == cursor_cell and line_glyphs[cursor_step] or nil
          if top or bottom then
            local symbol = (top and bottom) and "▐" or (top and "▝" or "▗")
            marks[#marks + 1] = { pos = cell, symbol = symbol, highlight = cell_highlight(top or bottom), column = "middle" }
          elseif line then
            marks[#marks + 1] = { pos = cell, symbol = line, highlight = line_highlight(), column = "middle" }
          end
          -- The line stays at the same height whether or not the cell has a mark.
          -- Next to a mark it is only in the right cell, because the middle cell
          -- holds the mark.
          if line then
            marks[#marks + 1] = { pos = cell, symbol = line, highlight = line_highlight(), column = "right" }
          end
        end
        return marks
      end,

      -- The bar has 3 cells. The sign column is the left and middle cells. The
      -- text column is the right cell. "middle" and "right" marks are text drawn
      -- over those cells. Every mark gets its own extmark, so marks in
      -- the same row do not replace each other.
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

    -- Redraw the markers when gitsigns finishes reading the changes. Satellite
    -- only listens for GitSignsUpdate (a branch change), so it can render before
    -- gitsigns has the changes and then show no markers until you scroll.
    -- GitSignsChanged fires when the changes of a buffer are updated.
    local refresh_pending = false
    local function refresh()
      if refresh_pending then
        return
      end
      refresh_pending = true
      vim.defer_fn(function()
        refresh_pending = false
        pcall(vim.cmd, "SatelliteRefresh")
      end, 100)
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = { "GitSignsChanged", "GitSignsUpdate" },
      callback = refresh,
    })
    vim.api.nvim_create_autocmd("BufWinEnter", { callback = refresh })
    refresh()
  end,
}
