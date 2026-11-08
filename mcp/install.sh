#!/usr/bin/env bash

# Make user-level directories for MCP
# mkdir -p ~/.mcp ~/.mcp/servers

# MCP config file symlinks
# sudo ln -sfn ~/.dotfiles/mcp/mcp-config.json ~/.mcp/mcp-config.json

# Symlink for Claude Code
sudo mkdir -p /Library/Application\ Support/ClaudeCode
sudo ln -sfn ~/.dotfiles/mcp/mcp-config.json /Library/Application\ Support/ClaudeCode/managed-mcp.json

# Symlink for VS Code
sudo ln -sfn ~/.dotfiles/mcp/mcp-config.json ~/Library/Application\ Support/Code/User/mcp.json

# Install local mcp servers
# TODO: Add server installation commands here
# echo "Installing MCP servers..."

echo "MCP installation complete."
