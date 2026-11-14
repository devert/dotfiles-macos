# OpenCode

OpenCode 2 reads its configuration from two files in `~/.config/opencode`. `opencode/install.sh` installs OpenCode with Homebrew. Then it links the folder `~/.config/opencode` to `opencode/config`.

- `opencode.jsonc`: Agents, models, MCP servers, and permissions. The schema is `https://opencode.ai/config.json`.
- `cli.json`: The TUI (terminal user interface) configuration, for example theme, diffs, and session display. The schema is `https://opencode.ai/v2/cli.json`.

Do not link each file separately. OpenCode saves `cli.json` with a temporary file and a rename, and the rename replaces a file symlink with a regular file.

Do not add `service.json` to the repository. It contains the password for the OpenCode background server. The root `.gitignore` excludes it.
