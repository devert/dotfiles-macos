#!/usr/bin/env zsh

# Install Claude Code
echo "Installing Claude Code"
brew install claude-code@latest

# Configure Claude Code
echo "Configuring Claude Code"

# Symlink settings file
# The Otto Sport machine uses its own settings.json from ~/.dotfiles-otto-sport.
if [[ -d ~/.dotfiles-otto-sport ]]; then
  echo "Skipping settings.json: this is the Otto Sport machine."
  echo "Run ~/.dotfiles-otto-sport/claude/configure.sh to link its settings.json."
else
  ln -sfn ~/.dotfiles/claude/settings.json ~/.claude/settings.json
fi

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

# Symlink custom skills, one link per skill
# ~/.claude/skills also holds skills from other tools, so it stays a real directory.
mkdir -p ~/.claude/skills
for skill in ~/.dotfiles/claude/skills/*(/); do
  target=~/.claude/skills/${skill:t}
  if [[ -d $target && ! -L $target ]]; then
    skill_backup=$target.backup.$(date +%Y%m%d-%H%M%S)
    echo "Moving existing $target to $skill_backup"
    mv "$target" "$skill_backup"
  fi
  ln -sfn "$skill" "$target"
done

# Symlink status line script
ln -sfn ~/.dotfiles/claude/status-line.sh ~/.claude/status-line.sh

echo "Claude Code installation Complete!"
