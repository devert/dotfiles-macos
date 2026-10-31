#!/usr/bin/env zsh

# Install Rex
# echo "Installing Rex"
# TODO: Install from Cask when available

# Configure Rex
echo "Configuring Rex"
mkdir -p $HOME/.config/rex
ln -sfn $HOME/.dotfiles/rex/init.lua $HOME/.config/rex/init.lua

# Import app settings (exported with prefs/prefs.py export rex)
$HOME/.dotfiles/prefs/prefs.py import rex || exit 1

echo "Rex installation and configuration complete!"
