#!/usr/bin/env bash

# Install Neovim and associated tools
echo "Installing Neovim"
brew install neovim tree-sitter-cli

# Symlink neovim config files
mkdir -p ~/.config/nvim
ln -sfn ~/.dotfiles/neovim/init.lua ~/.config/nvim/init.lua
ln -sfn ~/.dotfiles/neovim/lazy-lock.json ~/.config/nvim/lazy-lock.json
ln -sfn ~/.dotfiles/neovim/lua ~/.config/nvim/lua
