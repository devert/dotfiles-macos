-- Language servers (LSP), diagnostics, and completion.
--
-- Mason installs the servers. mason-lspconfig enables every installed server with
-- vim.lsp.enable(). nvim-lspconfig supplies the default settings for each server.
-- Overrides go in vim.lsp.config() below.
--
-- Built-in keymaps (Neovim 0.11+), active when a server is attached:
--   K      hover docs              grn   rename
--   gra    code action             grr   references
--   gri    implementation          grt   type definition
--   gO     document symbols        <C-s> signature help (Insert mode)
--   [d ]d  previous / next diagnostic
-- Added here:
--   gd          go to definition
--   gh          diagnostic under the cursor, else hover docs (like VS Code)
--   <leader>uh  toggle inlay hints

local servers = {
  "lua_ls",
  "vtsls",
  -- TODO: Enable basedpyright. Mason installs it with pip and needs Python 3.10 or
  -- newer. This machine only has the system Python 3.9. Install a newer Python
  -- (pyenv), then uncomment this line. Its settings are already in configure_servers().
  -- "basedpyright",
  "ruff",
  "jsonls",
  "yamlls",
  "html",
  "cssls",
  "emmet_language_server",
  "eslint",
  "bashls",
  "marksman",
}

-- Diagnostics: underlines only, like VS Code. No gutter signs (so line numbers do not
-- shift) and no text at the end of the line. Use gh to read the message.
local function setup_diagnostics()
  vim.diagnostic.config({
    underline = true,
    signs = false,
    virtual_text = false,
    update_in_insert = false,
    severity_sort = true,
    float = { source = "if_many" },
    jump = {
      -- Show the message after [d / ]d, because nothing else shows it
      on_jump = function(diagnostic, bufnr)
        if diagnostic then
          vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
        end
      end,
    },
  })
end

-- Settings that differ from the nvim-lspconfig defaults
local function configure_servers()
  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        hint = { enable = true },
        workspace = { checkThirdParty = false },
      },
    },
  })

  local ts_inlay_hints = {
    parameterNames = { enabled = "literals" },
    parameterTypes = { enabled = true },
    variableTypes = { enabled = false },
    propertyDeclarationTypes = { enabled = true },
    functionLikeReturnTypes = { enabled = true },
    enumMemberValues = { enabled = true },
  }
  vim.lsp.config("vtsls", {
    settings = {
      typescript = { inlayHints = ts_inlay_hints },
      javascript = { inlayHints = ts_inlay_hints },
    },
  })

  vim.lsp.config("basedpyright", {
    settings = {
      basedpyright = {
        -- Ruff sorts imports
        disableOrganizeImports = true,
        analysis = {
          -- "standard" is close to Pylance. The basedpyright default ("recommended")
          -- reports many more problems.
          typeCheckingMode = "standard",
        },
      },
    },
  })

  vim.lsp.config("jsonls", {
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
        validate = { enable = true },
      },
    },
  })

  vim.lsp.config("yamlls", {
    settings = {
      yaml = {
        -- Use SchemaStore.nvim instead of the server's built-in schema download
        schemaStore = { enable = false, url = "" },
        schemas = require("schemastore").yaml.schemas(),
      },
    },
  })
end

-- Open the completion menu on every word character, not only on the server's trigger
-- characters (such as ".").
local function complete_on_every_keypress(client)
  local provider = client.server_capabilities.completionProvider
  if not provider then
    return
  end
  local chars = provider.triggerCharacters or {}
  for c in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"):gmatch(".") do
    if not vim.tbl_contains(chars, c) then
      table.insert(chars, c)
    end
  end
  provider.triggerCharacters = chars
end

-- gh: show the diagnostic under the cursor. If there is none, show hover docs.
local function diagnostic_or_hover()
  if not vim.diagnostic.open_float({ scope = "cursor" }) then
    vim.lsp.buf.hover()
  end
end

-- Esc closes the hover or diagnostic float. Works from the code window and from
-- inside the float (press gh twice to enter it). Neovim stores the float window in
-- b:lsp_floating_preview of the code buffer, and marks the float with
-- w:lsp_floating_bufnr.
local function close_float()
  local win = vim.w.lsp_floating_bufnr and vim.api.nvim_get_current_win() or vim.b.lsp_floating_preview
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
end

-- Y inside the hover or diagnostic float copies all of its text. The Markdown code
-- fence lines (```) are left out.
local function setup_float_yank()
  vim.api.nvim_create_autocmd("WinEnter", {
    group = vim.api.nvim_create_augroup("UserLspFloatYank", { clear = true }),
    callback = function()
      if not vim.w.lsp_floating_bufnr then
        return
      end
      vim.keymap.set("n", "Y", function()
        local lines = vim.tbl_filter(function(line)
          return not line:match("^%s*```")
        end, vim.api.nvim_buf_get_lines(0, 0, -1, false))
        local text = vim.trim(table.concat(lines, "\n"))
        vim.fn.setreg("+", text)
        vim.fn.setreg('"', text)
        vim.notify("Copied hover text")
      end, { buffer = true, desc = "Copy all float text" })
    end,
  })
end

local function on_attach(ev)
  local client = vim.lsp.get_client_by_id(ev.data.client_id)
  if not client then
    return
  end
  local buf = ev.buf

  -- basedpyright gives better hover docs for Python than Ruff
  if client.name == "ruff" then
    client.server_capabilities.hoverProvider = false
  end

  if client:supports_method("textDocument/completion") then
    complete_on_every_keypress(client)
    vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
  end

  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
  end
  map("gd", vim.lsp.buf.definition, "Go to definition")
  map("gh", diagnostic_or_hover, "Diagnostic or hover")
end

local function setup_completion_keys()
  -- Show the menu with one match too, select nothing until Tab, show docs for the
  -- selected item, and match fuzzy like VS Code.
  vim.opt.completeopt = { "menuone", "noselect", "popup", "fuzzy" }

  local function pum_key(when_visible, otherwise)
    return function()
      return vim.fn.pumvisible() == 1 and when_visible or otherwise
    end
  end
  vim.keymap.set("i", "<Tab>", pum_key("<C-n>", "<Tab>"), { expr = true, desc = "Next completion item" })
  vim.keymap.set("i", "<S-Tab>", pum_key("<C-p>", "<S-Tab>"), { expr = true, desc = "Previous completion item" })
  -- Enter accepts the selected item. With nothing selected it closes the menu and
  -- makes a new line.
  vim.keymap.set("i", "<CR>", function()
    if vim.fn.pumvisible() == 0 then
      return "<CR>"
    end
    return vim.fn.complete_info({ "selected" }).selected ~= -1 and "<C-y>" or "<C-e><CR>"
  end, { expr = true, desc = "Accept completion or new line" })
end

return {
  -- Neovim API types for lua_ls when editing the Neovim config
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  -- JSON and YAML schemas (package.json, tsconfig.json, GitHub Actions, ...)
  { "b0o/SchemaStore.nvim", lazy = true, version = false },
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "b0o/SchemaStore.nvim",
    },
    keys = {
      {
        "<leader>uh",
        function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end,
        desc = "Toggle inlay hints",
      },
    },
    config = function()
      setup_diagnostics()
      setup_completion_keys()
      configure_servers()
      vim.keymap.set("n", "<Esc>", close_float, { desc = "Close hover / diagnostic float" })
      setup_float_yank()

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = on_attach,
      })

      -- Installs missing servers in the background, then enables all installed ones
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = true,
      })
    end,
  },
}
