-- Cmd+K clears the screen, like Ctrl+L
rex.bind("cmd+k", "pane.send_key", { key = "ctrl+l" })

-- Ctrl+Shift+Up/Down moves the active tab up/down
rex.bind("ctrl+shift+up", "client.tab.move.backward")
rex.bind("ctrl+shift+down", "client.tab.move.forward")

-- Cmd+\ toggles the sidebar
rex.bind("cmd+\\", "client.sidebar.toggle")
