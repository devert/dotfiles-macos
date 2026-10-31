#!/usr/bin/env zsh

# Install Rex
# echo "Installing Rex"
# TODO: Install from Cask when available

# Configure Rex
echo "Configuring Rex"
mkdir -p $HOME/.config/rex
ln -sfn $HOME/.dotfiles/rex/init.lua $HOME/.config/rex/init.lua

# Import app settings (exported with rex/export-settings.py)
$HOME/.dotfiles/rex/import-settings.py || exit 1

echo "Rex installation and configuration complete!"
