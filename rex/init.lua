-- Cmd+K clears the screen, like Ctrl+L
rex.bind("cmd+k", "pane.send_key", { key = "ctrl+l" })

-- Ctrl+Shift+Up/Down moves the active tab up/down
rex.bind("ctrl+shift+up", "client.tab.move.backward")
rex.bind("ctrl+shift+down", "client.tab.move.forward")

-- Cmd+\ toggles the sidebar
rex.bind("cmd+\\", "client.sidebar.toggle")

-- Cmd+Shift+R reloads the Rex config
rex.bind("cmd+shift+r", "client.config.reload")

-- Ctrl+Space then U opens an fzf picker with the URLs in the focused pane's
-- scrollback. The plugin is https://github.com/devert/rex-fzf-url, installed
-- in ~/.config/rex/plugins/rex-fzf-url by rex/install.sh.
local ok, fzf_url = pcall(require, "plugins.rex-fzf-url")
if ok then
  fzf_url.setup{ key = "ctrl+space>u" }
else
  rex.log("warn", "rex-fzf-url is not installed: " .. tostring(fzf_url))
end
