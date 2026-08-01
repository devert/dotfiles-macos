#!/usr/bin/env zsh

# Install Claude Code
echo "Installing Claude Code"
brew install claude-code

# Configure Claude Code
echo "Configuring Claude Code"

# Symlink settings file
ln -sfn ~/.dotfiles/claude/settings.json ~/.claude/settings.json

# Symlink rules files
ln -sfn ~/.dotfiles/claude/rules ~/.claude/rules

# Symlink status line script
ln -sfn ~/.dotfiles/claude/status-line.sh ~/.claude/status-line.sh

echo "Claude Code installation Complete!"
