#!/usr/bin/env zsh

echo "Installing Yazi..."
brew install yazi

echo "Installing Yazi deps..."
brew install poppler
brew install imagemagick

echo "Installing Yazi plugins..."
sudo ya pkg add yazi-rs/plugins:smart-enter

echo "Configuring Yazi..."
sudo mkdir -p $HOME/.config/yazi
sudo ln -sfn $HOME/.dotfiles/yazi/yazi.toml $HOME/.config/yazi/yazi.toml
sudo ln -sfn $HOME/.dotfiles/yazi/keymap.toml $HOME/.config/yazi/keymap.toml
sudo ln -sfn $HOME/.dotfiles/yazi/theme.toml $HOME/.config/yazi/theme.toml

echo "Yazi install and configuration complete!"
