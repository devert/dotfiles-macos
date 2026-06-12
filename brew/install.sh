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
nrew install eza
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

brew install --cask 1password
brew install --cask appcleaner
brew install --cask balenaetcher
brew install --cask bettertouchtool
brew install --cask brave-browser
brew install --cask contexts #TODO: Figure out how to configure this in a scripted way
brew install --cask docker
brew install --cask dropbox
brew install --cask firefox
brew install --cask google-chrome
brew install --cask hiddenbar
brew install --cask homerow
# brew install --cask httpie # TODO: determine which one is better between this and insomnia
# brew install --cask insomnia # TODO: determine which one is better between this and httpie
# brew install --cask iterm2
brew install --cask karabiner-elements
brew install --cask leader-key
brew install --cask microsoft-edge
brew install --cask notion
# brew install --cask overkill #TODO; May not need now that iTunes is discontinued
brew install --cask pixelsnap
brew install --cask plex
brew install --cask raycast
brew install --cask slack
brew install --cask sourcetree
brew install --cask spotify
brew install --cask visual-studio-code
brew install --cask vlc
brew install --cask zoom

# Optional Raspberry Pi Casks
# brew install --cask applepi-baker
# brew install --cask raspberry-pi-imager

# Reload shell
reload
