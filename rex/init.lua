-- ============================================================================
-- Modules
-- ============================================================================

-- Named pane layouts, defined in layouts.lua beside this file
require("layouts")

-- ============================================================================
-- Key bindings
-- ============================================================================

-- Cmd+K clears the screen, like Ctrl+L
rex.bind("cmd+k", "pane.send_key", { key = "ctrl+l" })

-- Ctrl+Shift+Up/Down moves the active tab up/down
rex.bind("ctrl+shift+up", "client.tab.move.backward")
rex.bind("ctrl+shift+down", "client.tab.move.forward")

-- Ctrl+Shift+J/K sends Ctrl+J/K three times, so OpenCode scrolls 3 lines per
-- press. OpenCode binds Ctrl+J/K to scroll one line down/up.
rex.action({
  name = "send_key_x3",
  title = "Send Key 3 Times",
  args = { key = "string" },
  repeats = true,
  run = function(ctx, args)
    for _ = 1, 3 do
      rex.client.queue("pane.send_key", { key = args.key })
    end
  end,
})
rex.bind("ctrl+shift+j", "send_key_x3", { key = "ctrl+j" })
rex.bind("ctrl+shift+k", "send_key_x3", { key = "ctrl+k" })

-- Cmd+\ toggles the sidebar
rex.bind("cmd+\\", "client.sidebar.toggle")

-- Cmd+Shift+R reloads the Rex config
rex.bind("cmd+shift+r", "client.config.reload")

-- ============================================================================
-- Plugins
-- ============================================================================

-- Cmd+U opens an fzf picker with the URLs in the focused pane's scrollback.
-- The plugin is https://github.com/devert/rex-fzf-url, installed in
-- ~/.config/rex/plugins/rex-fzf-url by rex/install.sh.
local ok, fzf_url = pcall(require, "plugins.rex-fzf-url")
if ok then
  fzf_url.setup({ key = "cmd+u" })
else
  rex.log("warn", "rex-fzf-url is not installed: " .. tostring(fzf_url))
end
