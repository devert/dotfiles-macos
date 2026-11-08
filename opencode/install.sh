#!/usr/bin/env zsh

# Install OpenCode
echo "Installing OpenCode"
brew install opencode

# Configure OpenCode
# opencode.jsonc: agent, model, MCP, and permission configuration
# cli.json: TUI configuration (theme, diffs, session display)
#
# Link the whole directory, not each file. OpenCode saves cli.json by writing a temp file and renaming it over
# cli.json, which replaces a file symlink with a regular file.
echo "Configuring OpenCode"
mkdir -p $HOME/.config

CONFIG_DIR=$HOME/.config/opencode
DOTFILES_CONFIG_DIR=$HOME/.dotfiles/opencode/config

if [ -L "$CONFIG_DIR" ] && [ "$(readlink "$CONFIG_DIR")" = "$DOTFILES_CONFIG_DIR" ]; then
  echo "$CONFIG_DIR already links to $DOTFILES_CONFIG_DIR"
else
  if [ -e "$CONFIG_DIR" ] || [ -L "$CONFIG_DIR" ]; then
    BACKUP_DIR=$CONFIG_DIR.bak.$(date +"%Y-%m-%d_%H%M%S")
    echo "Backing up existing $CONFIG_DIR to $BACKUP_DIR"
    mv "$CONFIG_DIR" "$BACKUP_DIR"

    # Keep the background server password. Git ignores this file.
    if [ -f "$BACKUP_DIR/service.json" ] && [ ! -e "$DOTFILES_CONFIG_DIR/service.json" ]; then
      cp -p "$BACKUP_DIR/service.json" "$DOTFILES_CONFIG_DIR/service.json"
    fi
  fi

  ln -sfn "$DOTFILES_CONFIG_DIR" "$CONFIG_DIR"
fi

echo "OpenCode installation Complete!"
