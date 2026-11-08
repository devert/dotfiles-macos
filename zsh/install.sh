#!/usr/bin/env zsh

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install Homebrew Zsh
echo "Installing Zsh"

brew install zsh

# Switch to using brew-installed zsh as default shell
echo "Change User Shell To Homebrew Installed Zsh"

BREW_ZSH="$(brew --prefix)/bin/zsh"

# Register the Homebrew zsh as an allowed login shell (idempotent)
grep -qxF "$BREW_ZSH" /etc/shells || echo "$BREW_ZSH" | sudo tee -a /etc/shells

# Set it as the default shell via the supported, /etc/shells-validated path
sudo chsh -s "$BREW_ZSH" "$USER"

# Install Oh My Zsh
echo "Installing Oh My Zsh"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
