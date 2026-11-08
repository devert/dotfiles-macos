#!/usr/bin/env zsh

# Install Rex
# echo "Installing Rex"
# TODO: Install from Cask when available

# Configure Rex
echo "Configuring Rex"
mkdir -p $HOME/.config/rex
ln -sfn $HOME/.dotfiles/rex/init.lua $HOME/.config/rex/init.lua

# Install the fzf URL picker plugin (https://github.com/devert/rex-fzf-url)
if [ ! -e $HOME/.config/rex/plugins/rex-fzf-url ]; then
  echo "Installing rex-fzf-url"
  mkdir -p $HOME/.config/rex/plugins
  git clone https://github.com/devert/rex-fzf-url.git $HOME/.config/rex/plugins/rex-fzf-url
fi

# Import app settings (exported with rex/export-settings.py)
$HOME/.dotfiles/rex/import-settings.py || exit 1

echo "Rex installation and configuration complete!"
