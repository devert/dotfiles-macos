#!/usr/bin/env zsh

# Install PixelSnap
echo "Installing PixelSnap..."

brew install pixelsnap

# Configure PixelSnap
echo "Configuring PixelSnap..."

# Integrations
defaults write pl.maketheweb.pixelsnap2 "figmaIntegration" -int 1

# Shortcuts
# Global Hotkey
defaults write pl.maketheweb.pixelsnap2 "LAVAglobalHotkey" -data 7b22636172626f6e4b6579223a322c22636172626f6e4d6f64696669657273223a363931327d

echo "PixelSnap installation and configuration complete!"
echo "Restart PixelSnap to apply changes"
