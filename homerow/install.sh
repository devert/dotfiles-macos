#!/usr/bin/env zsh

# Install Homerow
echo "Installing Homerow..."
brew install --cask homerow

# Configure Homerow
echo "Configuring Homerow..."

# General settings
defaults write com.superultra.Homerow "launch-at-login" -bool true
defaults write com.superultra.Homerow "show-menubar-icon" -bool true
defaults write com.superultra.Homerow "check-for-updates-automatically" -bool true
defaults write com.superultra.Homerow "auto-switch-input-source-id" -string "com.apple.keylayout.US"
defaults write com.superultra.Homerow "enable-hyper-key" -bool false

# Appearance settings
defaults write com.superultra.Homerow "theme-id" -string "light";
defaults write com.superultra.Homerow "label-font-size" -integer 11;

# Clicking settings
defaults write com.superultra.Homerow "non-search-shortcut" -string "⌃⌥⇧⌘F";
defaults write com.superultra.Homerow "is-auto-click-enabled" -bool true;
defaults write com.superultra.Homerow "chain-clicks" -bool false;
defaults write com.superultra.Homerow "label-characters" -string "";
defaults write com.superultra.Homerow "use-search-predicate" -int 0;
defaults write com.superultra.Homerow "search-shortcut" -string "⌃⌥⇧⌘S";
defaults write com.superultra.Homerow "hide-labels-when-nothing-is-searched" -bool true;

# Scrolling settings
defaults write com.superultra.Homerow "scroll-shortcut" -string "⌃⌥⇧⌘I";
defaults write com.superultra.Homerow "map-arrow-keys-to-scroll" -bool true;
defaults write com.superultra.Homerow "scroll-show-numbers" -bool true;
defaults write com.superultra.Homerow "scroll-keys" -string "HJKL";
defaults write com.superultra.Homerow "is-scroll-shortcuts-enabled" -bool true;
defaults write com.superultra.Homerow "dash-speed-multiplier" -int 4;
defaults write com.superultra.Homerow "scroll-px-per-ms" -int 2;
defaults write com.superultra.Homerow "auto-deactivate-scrolling" -int 0;

echo "Homerow installation complete!"
