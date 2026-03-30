#!/usr/bin/env bash

# Symlink settings file
sudo ln -sfn ~/.dotfiles/claude/settings.json ~/.claude/settings.json

# Symlink rules files
sudo ln -sfn ~/.dotfiles/claude/rules ~/.claude/rules

# Symlink status line script
sudo ln -sfn ~/.dotfiles/claude/status-line.sh ~/.claude/status-line.sh
