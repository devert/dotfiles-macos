#!/usr/bin/env zsh

# Install Claude Code
echo "Installing Claude Code"
brew install claude-code@latest

# Configure Claude Code
echo "Configuring Claude Code"

# Symlink settings file
ln -sfn ~/.dotfiles/claude/settings.json ~/.claude/settings.json

# Symlink keybindings file
ln -sfn ~/.dotfiles/claude/keybindings.json ~/.claude/keybindings.json

# Symlink rules files
ln -sfn ~/.dotfiles/claude/rules ~/.claude/rules

# Symlink custom themes
# ln -sfn cannot replace a real directory. It would create the link inside it.
# Move a real directory aside first, so nothing is lost.
if [[ -d ~/.claude/themes && ! -L ~/.claude/themes ]]; then
  themes_backup=~/.claude/themes.backup.$(date +%Y%m%d-%H%M%S)
  echo "Moving existing ~/.claude/themes to $themes_backup"
  mv ~/.claude/themes "$themes_backup"
fi
ln -sfn ~/.dotfiles/claude/themes ~/.claude/themes

# Symlink status line script
ln -sfn ~/.dotfiles/claude/status-line.sh ~/.claude/status-line.sh

echo "Claude Code installation Complete!"
