#!/usr/bin/env zsh

# Install Leader Key
echo "Installing Leader Key..."

brew install leader-key

# Configure Leader Key
echo "Configuring Leader Key..."

# Ensure parent config directory exists
mkdir -p "$HOME/.config"

# Create a symlink so the entire Leader Key folder points to the dotfiles config
export LEADER_KEY_CONFIG_DIR="$HOME/.config/leader-key"

ln -sfn "$HOME/.dotfiles/leader-key" "$LEADER_KEY_CONFIG_DIR"

# Additional Leader Key configuration using defaults write
defaults write com.brnbw.Leader-Key "configDir" -string "$LEADER_KEY_CONFIG_DIR"
defaults write com.brnbw.Leader-Key "KeyboardShortcuts_group-o" -string "{\"carbonModifiers\":6912,\"carbonKeyCode\":31}"
defaults write com.brnbw.Leader-Key "KeyboardShortcuts_group-r" -string "{\"carbonKeyCode\":15,\"carbonModifiers\":6912}"
defaults write com.brnbw.Leader-Key "KeyboardShortcuts_group-w" -string "{\"carbonModifiers\":6912,\"carbonKeyCode\":13}"
defaults write com.brnbw.Leader-Key "KeyboardShortcuts_navigate" -string "{\"carbonKeyCode\":41,\"carbonModifiers\":6912}"
defaults write com.brnbw.Leader-Key "groupShortcuts" -array "w" "o" "r"
defaults write com.brnbw.Leader-Key "theme" -string breadcrumbs;
defaults write com.brnbw.Leader-Key "screen" -string activeWindow
defaults write com.brnbw.Leader-Key "modifierKeyConfiguration" -string "controlGroupOptionSticky";
defaults write com.brnbw.Leader-Key "reactivateBehavior" -string hide;

echo "Leader Key installation and configuration complete!"
echo "Restart Leader Key to apply changes"
