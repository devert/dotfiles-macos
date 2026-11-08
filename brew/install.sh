#!/usr/bin/env bash

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Install command-line tools using Homebrew.
echo "Installing Homebrew Packages"

brew install bat
brew install curl
brew install eza
brew install fzf

brew install git
brew install git-extras
brew install gh

# Conflicts with git-extras sync, so override
brew tap jacobwgillespie/tap
brew trust --formula jacobwgillespie/tap/git-sync
brew install jacobwgillespie/tap/git-sync
brew link --overwrite git-sync

brew install jq
brew install neovim
brew install ripgrep
brew install tmux
brew install uv
brew install zoxide
brew install zsh

echo "Install Applications with Homebrew Cask"

# Install casks
brew install 1password
brew install bettertouchtool
brew install brave-browser
brew install contexts
brew install dropbox
brew install firefox
brew install google-chrome
brew install hiddenbar
brew install homerow
brew install insomnia
brew install karabiner-elements
brew install leader-key
brew install microsoft-edge
brew install notion
brew install pixelsnap
brew install raycast
brew install slack
brew install sourcetree
brew install spotify
brew install visual-studio-code

# Optional casks
# brew install appcleaner
# brew install docker-desktop
# brew install plex
# brew install vlc
# brew install zoom

# Optional Raspberry Pi dev Casks
# brew install applepi-baker
# brew install balenaetcher
# brew install raspberry-pi-imager
