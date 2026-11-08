#!/usr/bin/env zsh

# Install OpenCode
echo "Installing OpenCode"
brew install opencode

# Configure OpenCode
# opencode.jsonc: agent, model, MCP, and permission configuration
# cli.json: TUI configuration (theme, diffs, session display)
echo "Configuring OpenCode"
mkdir -p $HOME/.config/opencode
ln -sfn $HOME/.dotfiles/opencode/opencode.jsonc $HOME/.config/opencode/opencode.jsonc
ln -sfn $HOME/.dotfiles/opencode/cli.json $HOME/.config/opencode/cli.json

echo "OpenCode installation Complete!"
