-- Status line at the bottom of the window.
-- See :h lualine for all options.
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  init = function()
    -- lualine shows the mode, so hide the "-- INSERT --" text under it.
    vim.opt.showmode = false

    -- Redraw when macro recording starts or stops, so the indicator updates right away.
    -- On RecordingLeave, reg_recording() still returns the register, so wait a tick.
    vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
      callback = function()
        vim.schedule(function()
          require("lualine").refresh()
        end)
      end,
    })
  end,
  opts = {
    options = {
      -- monokai-pro.nvim includes a lualine theme
      theme = "monokai-pro",
      -- One status line for all windows, instead of one per split
      globalstatus = true,
      -- Flat look: thin bar between components, no powerline arrows between sections
      component_separators = "|",
      section_separators = "",
    },
    sections = {
      lualine_b = {
        "branch",
        -- Use the change counts that gitsigns already has, instead of running git again
        {
          "diff",
          source = function()
            local status = vim.b.gitsigns_status_dict
            if status then
              return { added = status.added, modified = status.changed, removed = status.removed }
            end
          end,
        },
        "diagnostics",
      },
      -- Path relative to the working directory, not only the file name
      lualine_c = { { "filename", path = 1 } },
      -- Macro indicator (hidden by showmode = false), then file type only.
      -- Leaves out the default encoding and fileformat.
      lualine_x = {
        {
          function()
            return "recording @" .. vim.fn.reg_recording()
          end,
          cond = function()
            return vim.fn.reg_recording() ~= ""
          end,
        },
        "filetype",
      },
    },
    -- Simpler status lines for these plugin windows
    extensions = { "lazy", "mason" },
  },
}
