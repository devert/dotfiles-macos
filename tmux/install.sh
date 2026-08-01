#!/usr/bin/env bash

# Install tmux configuration
ln -sfn ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf
echo "Tmux configuration installed."

# Install Tmux Plugin Manager (skip if already cloned)
if [ -d ~/.tmux/plugins/tpm ]; then
  echo "Tmux Plugin Manager already installed."
else
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  echo "Tmux Plugin Manager installed."
fi

# install_plugins reads TMUX_PLUGIN_MANAGER_PATH from tmux's global environment,
# which is normally only set when tmux sources .tmux.conf. Set it explicitly so
# a headless run (no config-sourced server) doesn't abort with
# "unknown variable: TMUX_PLUGIN_MANAGER_PATH".
tmux start-server
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins/"
~/.tmux/plugins/tpm/bin/install_plugins
echo "Tmux plugins installed."

echo "Tmux installation complete!"
