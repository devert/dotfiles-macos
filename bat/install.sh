#!/usr/bin/env zsh

# Install bat
echo "Installing bat"
brew install bat

# Configure bat
echo "Configuring bat"
mkdir -p $HOME/.config/bat
mkdir -p $HOME/.config/bat/themes
ln -sfn $HOME/.dotfiles/bat/config $HOME/.config/bat/config
ln -sfn $HOME/.dotfiles/bat/Monokai\ Pro.tmTheme $HOME/.config/bat/themes/Monokai\ Pro.tmTheme
bat cache --build

echo "bat installation Complete!"
