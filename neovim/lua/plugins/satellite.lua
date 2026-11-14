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
-- half, so two hunks that share a cell can both show. A cell shows at most two
-- colors. When hunks share a half, a change wins over a delete, and a delete
-- wins over an add.
-- The cursor line is a light underline across the middle and right cells. It
-- shares the cell with the marks, so it does not hide them. Its color is the text color, 70% of the
-- way from the background, which is the VS Code color in Monokai Pro.
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
      gitsigns = { enable = false }, -- replaced by the two column handler below
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
    -- right or the bottom right quarter of the cell. A cell with two different
    -- hunks draws the top one in the middle cell and the bottom one in the
    -- left half of the cell right of it.
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

    -- Highlight group for a cell. top and bottom are hunk types or nil. With
    -- cursor set, the cell also gets an underline in the cursor color.
    local function cell_highlight(top, bottom, cursor)
      local name = "SatelliteHunk_" .. (top or "none") .. "_" .. (bottom or "none") .. (cursor and "_cursor" or "")
      local spec = {}
      if top and bottom and top ~= bottom then
        spec.fg, spec.bg = color_of(top), color_of(bottom)
      elseif top or bottom then
        spec.fg = color_of(top or bottom)
      end
      if cursor then
        spec.underline, spec.sp = true, cursor_color()
      end
      vim.api.nvim_set_hl(0, name, spec)
      return name
    end

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

        local cursor_cell = math.floor(half_cell(vim.api.nvim_win_get_cursor(winid)[1] - 1) / 2)

        -- An empty sign keeps the sign column, which makes the bar 3 cells wide.
        -- The marks below are text that is drawn over the sign column.
        local marks = { { pos = 0, symbol = "  ", highlight = "Normal", column = "sign" } }
        for cell = 0, height - 1 do
          local top, bottom = winner[2 * cell], winner[2 * cell + 1]
          local is_cursor = cell == cursor_cell
          if top and bottom and top ~= bottom then
            marks[#marks + 1] = { pos = cell, symbol = "▝", highlight = cell_highlight(top, nil, is_cursor), column = "middle" }
            marks[#marks + 1] = { pos = cell, symbol = "▖", highlight = cell_highlight(nil, bottom, is_cursor), column = "right" }
          else
            if top or bottom then
              local symbol = (top and bottom) and "▐" or (top and "▝" or "▗")
              marks[#marks + 1] =
                { pos = cell, symbol = symbol, highlight = cell_highlight(top or bottom, nil, is_cursor), column = "middle" }
            elseif is_cursor then
              marks[#marks + 1] = { pos = cell, symbol = " ", highlight = cell_highlight(nil, nil, true), column = "middle" }
            end
            -- The cursor line also crosses the right cell.
            if is_cursor then
              marks[#marks + 1] = { pos = cell, symbol = " ", highlight = cell_highlight(nil, nil, true), column = "right" }
            end
          end
        end
        return marks
      end,

      -- The bar has 3 cells. The sign column is the left and middle cells. The
      -- text column is the right cell. A "middle" mark is text drawn over the
      -- middle cell, and a "right" mark is text drawn over the right cell. Every
      -- mark gets its own extmark, so marks in the same row do not replace each
      -- other. The cursor line starts at the middle cell, so the left cell stays
      -- empty.
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
