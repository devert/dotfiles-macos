#!/usr/bin/env zsh

# Install Homerow
echo "Installing Homerow..."
brew install --cask homerow

# Configure Homerow
echo "Configuring Homerow..."

# Import app settings (exported with prefs/prefs.py export homerow)
$HOME/.dotfiles/prefs/prefs.py import homerow || exit 1

echo "Homerow installation complete!"
