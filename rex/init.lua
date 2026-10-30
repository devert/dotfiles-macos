-- Cmd+K clears the screen, like Ctrl+L
rex.bind("cmd+k", "pane.send_key", { key = "ctrl+l" })

-- Ctrl+Shift+Left/Right moves the active tab left/right
rex.bind("ctrl+shift+left", "client.tab.move.backward")
rex.bind("ctrl+shift+right", "client.tab.move.forward")

-- Cmd+\ toggles the sidebar
rex.bind("cmd+\\", "client.sidebar.toggle")
