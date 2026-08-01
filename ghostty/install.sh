#!/usr/bin/env bash

# Configure Ghostty
echo "Configuring Ghostty..."

# Ensure config directory exists
mkdir -p ~/.config/ghostty

ln -sfn ~/.dotfiles/ghostty/config ~/.config/ghostty/config

echo "Ghostty Configuration Complete"
echo "Reload Configuration with: cmd+shift+,"
