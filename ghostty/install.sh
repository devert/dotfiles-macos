#!/usr/bin/env bash

# Configure Ghostty
echo "Configuring Ghostty..."

# Ensure config directory exists
mkdir -p ~/.config/ghostty
# mkdir -p ~/.config/ghostty/themes

ln -sfn ~/.dotfiles/ghostty/config ~/.config/ghostty/config
# ln -sfn ~/.dotfiles/ghostty/themes/Monokai Pro ~/.config/ghostty/Monokai Pro

echo "Ghostty Configuration Complete"
echo "Reload Configuration with: cmd+shift+,"
