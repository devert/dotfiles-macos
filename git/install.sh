#!/usr/bin/env zsh

# Install Git and GitHub CLI
echo "Installing Git and GitHub CLI..."

brew install git
brew install gh

# Symlink .gitconfig and .gitignore_global
echo "Installing Git configuration files..."

ln -sfn ~/.dotfiles/git/.gitconfig ~/.gitconfig
ln -sfn ~/.dotfiles/git/.gitignore_global ~/.gitignore_global

# Configuration settings for Github CLI
echo "Installing GitHub CLI configuration files..."

mkdir ~/.config/gh
ln -s ~/.dotfiles/git/gh_config.yml ~/.config/gh/config.yml

# Install some GitHub CLI extensions
echo "Installing GitHub CLI extensions..."

gh extension install gennaro-tedesco/gh-f

echo "Git and GitHub CLI Installation and Configuration Complete"
