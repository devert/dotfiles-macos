#!/usr/bin/env bash

# Symlink neovim config files
ln -sfn ~/.dotfiles/neovim/init.lua ~/.config/nvim/init.lua
ln -sfn ~/.dotfiles/neovim/lazy-lock.json ~/.config/nvim/lazy-lock.json
ln -sfn ~/.dotfiles/neovim/lua ~/.config/nvim/lua
