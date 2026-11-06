#!/usr/bin/env zsh

# Install Claude Code
echo "Installing Claude Code"
brew install claude-code@latest

# Configure Claude Code
echo "Configuring Claude Code"

# Symlink settings file
ln -sfn ~/.dotfiles/claude/settings.json ~/.claude/settings.json

# Symlink rules files
ln -sfn ~/.dotfiles/claude/rules ~/.claude/rules

# Symlink custom themes
# ln -sfn cannot replace a real directory. It would create the link inside it.
if [[ -d ~/.claude/themes && ! -L ~/.claude/themes ]]; then
  echo "Skipping themes: ~/.claude/themes is a real directory. Move it away, then run this script again."
else
  ln -sfn ~/.dotfiles/claude/themes ~/.claude/themes
fi

# Symlink status line script
ln -sfn ~/.dotfiles/claude/status-line.sh ~/.claude/status-line.sh

echo "Claude Code installation Complete!"
