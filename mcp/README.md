# MCP Configuration

Centralized Model Context Protocol (MCP) server configuration for Claude Code, VS Code, Raycast, etc.

## Installation

```bash
./install.sh
```

Creates `~/.mcp/` directories for centralized installation and management of local MCP servers.

- `~/.mcp/servers` - Location for putting locally installed servers (none installed yet).

Symlinks MCP JSON configuration files to application-specific paths:

- `~/.mcp/mcp-config.json`: Global config
- `~/Library/Application Support/Code/User/mcp.json`: VS Code config

Claude Code gets the same servers from its plugins, so the script does not configure Claude Code.

Do not use `/Library/Application Support/ClaudeCode/managed-mcp.json` for these servers. Claude Code treats that file as an enterprise policy. Then the OpenCode Claude Agent provider cannot start Claude Code.

### Raycast Installation

To install MCP servers in Raycast:

1. Run the **Import Servers** command
2. Select `~/.mcp/mcp-config.json`

Note: You must manually re-import after adding new servers. Raycast skips duplicate server definitions that have already been added.

## Config JSON

The configuration file contains two sections with identical server definitions:

- `mcpServers`: Used by Claude Code and Raycast
- `servers`: Used by VS Code

Both sections must be maintained with the same configuration to ensure consistency across all applications.
