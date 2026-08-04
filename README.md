# macOS Dotfiles

Setup, software installation and dotfiles for macOS.

## Install Command Line Tools (CLT) for Xcode

```sh
xcode-select --install
```

## Install Rosetta

```sh
softwareupdate --install-rosetta
```

[developer.apple.com/downloads](https://developer.apple.com/downloads) or [Xcode](https://itunes.apple.com/us/app/xcode/id497799835)

## Install [Homebrew](http://brew.sh/), Git, Chrome and 1Password

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git
brew install google-chrome
brew install 1password
```

## Checkout dotfiles project

[Generate SSH Key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and add it to GitHub [profile](https://github.com/settings/keys).

Then pull this repo.

```sh
cd ~
git clone git@github.com:devert/dotfiles-osx .dotfiles
```

## Configure sensible macOS defaults

When setting up a new Mac, you may want to set some sensible macOS defaults:

```sh
./macos/install.sh
```

## Install Homebrew Packages and Casks

```sh
./brew/install.sh
```

## Install Node, Python, Rust

```sh
./node/install.sh
./python/install.sh
./rust/install.sh
```

## Install and Configure Zsh And Make Default Shell

```sh
./zsh/install.sh

reload

./zsh/configure.sh
```

## Run remaining install scripts

```sh
./git/install.sh
./karabiner/install.sh
./neovim/install.sh
./tmux/install.sh
./vscode/install.sh
...and more
```

## Heavily influenced by the following .dotfiles projects

- [Mathias Bynens](https://github.com/mathiasbynens/dotfiles)
- [Pawel Grzybek](https://github.com/pawelgrzybek/dotfiles)
- [Springload](https://github.com/springload/dotfiles)
