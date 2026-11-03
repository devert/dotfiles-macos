-- Cmd+K clears the screen, like Ctrl+L
rex.bind("cmd+k", "pane.send_key", { key = "ctrl+l" })

-- Ctrl+Shift+Up/Down moves the active tab up/down
rex.bind("ctrl+shift+up", "client.tab.move.backward")
rex.bind("ctrl+shift+down", "client.tab.move.forward")

-- Cmd+\ toggles the sidebar
rex.bind("cmd+\\", "client.sidebar.toggle")

-- Cmd+Shift+R reloads the Rex config
rex.bind("cmd+shift+r", "client.config.reload")

-- Ctrl+Space then U opens an fzf picker with the URLs in the focused pane's scrollback.
-- Enter opens the URL and closes the picker. Ctrl+Y copies it instead.
-- The URL extraction is shared with the herdr fzf-url plugin.
local fzf_url_dir = os.getenv("HOME") .. "/.dotfiles/rex/fzf-url"
local fzf_url_extract = os.getenv("HOME") .. "/.dotfiles/herdr/plugins/fzf-url/extract-urls"
local terminal = "com.superlogical.terminal"

-- Read the whole screen and scrollback as plain text. Large output arrives in
-- parts, so read the rest with blob_read until it is complete.
local function read_scrollback(block_id)
  local chunk = 512 * 1024
  local r, err = rex.block.call(terminal, "format", {
    block_id = block_id, format = "text", trim = true, unwrap = true, max_bytes = chunk,
  })
  if r == nil then return nil, err end
  local parts = { r.content or "" }
  local offset = #parts[1]
  while r.id ~= nil and not r.eof do
    r, err = rex.block.call(terminal, "blob_read", {
      block_id = block_id, id = r.id, offset = offset, max_bytes = chunk,
    })
    if r == nil then return nil, err end
    if r.data == nil or r.data == "" then break end
    parts[#parts + 1] = r.data
    offset = offset + #r.data
  end
  return table.concat(parts)
end

-- Find the rect of a block in the window's tiled layout, as [x, y, w, h]
-- fractions of the window.
local function find_rect(node, block_id)
  if node == nil then return nil end
  if node.block_id == block_id then return node.rect end
  if node.split ~= nil then
    return find_rect(node.split.before, block_id) or find_rect(node.split.after, block_id)
  end
  return nil
end

-- Size the popup to its content, like junegunn/tmux-fzf-url:
-- width = longest line + 8, height = count + 7, centered in the window.
local function popup_bounds(block_id, urls)
  local width = #"Enter: Open URL / CTRL-Y: Copy to clipboard"
  for _, url in ipairs(urls) do
    if #url > width then width = #url end
  end
  width = width + 8
  local height = #urls + 7

  local win_cols, win_rows
  local size = rex.block.call(terminal, "size", { block_id = block_id })
  local view = rex.session.view{}
  if size ~= nil and view ~= nil then
    for _, window in ipairs(view.windows or {}) do
      for _, layer in ipairs(window.layers or {}) do
        local rect = find_rect(layer.layout, block_id)
        if rect ~= nil then
          win_cols = size.columns / rect[3]
          win_rows = size.rows / rect[4]
        end
      end
    end
  end
  if win_cols == nil then return { 0.2, 0.3, 0.6, 0.4 } end

  local w = math.min(width / win_cols, 0.9)
  local h = math.min(height / win_rows, 0.9)
  return { (1 - w) / 2, (1 - h) / 2, w, h }
end

rex.action{
  name  = "fzf_url",
  title = "Open URL from Scrollback",
  description = "Pick a URL from the focused pane's scrollback with fzf and open it.",
  keywords = "url link fzf browser",
  run   = function(ctx, args)
    if ctx.block_id == nil then error("fzf-url: no focused pane", 0) end

    local text, err = read_scrollback(ctx.block_id)
    if text == nil then error("fzf-url: " .. tostring(err), 0) end

    local r, exec_err = rex.exec({ "perl", fzf_url_extract }, { stdin = text, timeout = 10 })
    if r == nil then error("fzf-url: " .. tostring(exec_err), 0) end
    if not r.ok then error("fzf-url: " .. r.stderr, 0) end

    -- Newest URLs first.
    local urls = {}
    for url in r.stdout:gmatch("[^\n]+") do table.insert(urls, 1, url) end
    if #urls == 0 then error("fzf-url: no URLs found", 0) end

    local url_file = os.tmpname()
    local f = assert(io.open(url_file, "w"))
    f:write(table.concat(urls, "\n"), "\n")
    f:close()

    local _, layer_err = rex.session.new_layer{
      bounds = popup_bounds(ctx.block_id, urls),
      focus  = true,
      layout = rex.layout.block{
        flavor  = "com.superlogical.terminal.shell",
        options = { command = { "bash", fzf_url_dir .. "/picker.sh", url_file } },
      },
    }
    if layer_err ~= nil then
      os.remove(url_file)
      error("fzf-url: " .. tostring(layer_err), 0)
    end
  end,
}

rex.bind("ctrl+space>u", "fzf_url")
