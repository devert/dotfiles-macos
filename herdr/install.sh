#!/usr/bin/env zsh

# Install herdr
echo "Installing herdr"
brew install herdr

# Configure herdr
echo "Configuring herdr"
mkdir -p $HOME/.config/herdr
ln -sfn $HOME/.dotfiles/herdr/config.toml $HOME/.config/herdr/config.toml

# Install Claude Code agent-state integration (generated and version-managed by herdr)
echo "Installing herdr Claude Code integration"
herdr integration install claude

# Link local plugins. Plugin registration is global per-user state outside
# ~/.config/herdr/config.toml, so it happens here rather than via symlink.
# Keybindings for these live in config.toml.
echo "Linking herdr plugins"
herdr plugin link $HOME/.dotfiles/herdr/plugins/fzf-url

echo "herdr installation Complete!"
