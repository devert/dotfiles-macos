# AGENTS.md

This file provides guidance to AI Agents when working with code in this repository.

## Repository Overview

This is a macOS dotfiles repository using modular organization with individual installation scripts for each component. Configuration is managed via symlinks, keeping the repository as the single source of truth.

**Repository**: `git@github.com:devert/dotfiles-macos.git`
**Primary Shell**: Zsh with Oh-My-Zsh framework
**Primary Terminal**: Ghostty

## Architecture & Organization

The repository follows a **component-based structure** where each tool/application has its own directory containing:

- Configuration files
- `install.sh` script that creates symlinks to system locations
- Optional README.md with setup notes

### Key Components

```
zsh/          # Shell configuration (Oh-My-Zsh, Powerlevel10k, custom functions/aliases)
neovim/       # Neovim with lazy.nvim plugin manager
vscode/       # VS Code settings, keybindings, snippets, extensions
git/          # Git config with aliases, GitHub CLI config
brew/         # Homebrew package and cask installation
macos/        # System defaults configuration (100+ settings)
ghostty/      # Ghostty terminal emulator configuration
node/         # FNM (Fast Node Manager) setup
python/       # PyEnv and virtualenv setup
karabiner/    # Keyboard remapping configuration
leader-key/   # Configuration for Leader Key application (https://github.com/mikker/LeaderKey.app)
tmux/         # Tmux multiplexer configuration with tpm plugins
fonts/        # Custom fonts installation
claude/       # Claude Code settings, rules, and status line configuration
mcp/          # Model Context Protocol server configuration
contexts/     # Contexts window switching app configuration (https://contexts.co/)
homerow/      # Homerow keyboard-driven UI navigation configuration (https://www.homerow.app/)
yazi/         # Yazi terminal file manager configuration (https://github.com/sxyazi/yazi)
herdr/        # Herdr terminal agent multiplexer configuration (https://herdr.dev)
opencode/     # OpenCode 2 configuration: agent configuration and TUI configuration (https://opencode.ai)
rex/          # Rex terminal configuration: keybindings, pane layouts, app settings, and custom themes
```

`neovim/AGENTS.md` and `rex/AGENTS.md` have the details for those components. Read them before you change files there.

## Installation Flow

The setup follows a specific sequence (from README.md):

1. **System prerequisites**: Xcode Command Line Tools, Homebrew, Git
2. **Clone repository** to `~/.dotfiles`
3. **MacOS defaults**: `./macos/install.sh`
4. **Homebrew packages**: `./brew/install.sh`
5. **Runtimes**: Node (FNM) and Python (PyEnv)
6. **Zsh (two-step process)**:
   - `./zsh/install.sh` - Installs Zsh and Oh-My-Zsh
   - `reload` - Reload shell
   - `./zsh/configure.sh` - Symlinks configs and installs plugins
7. **Remaining components**: Run other `*/install.sh` scripts

**Important**: The Zsh installation requires a shell reload between the install and configure steps.

## Configuration Management Pattern

All install scripts use **symlinks** rather than copying files:

```bash
ln -s ~/.dotfiles/<component>/<file> <target-location>
```

**Examples**:

- `~/.zshrc` → `~/.dotfiles/zsh/.zshrc`
- `~/.config/nvim/init.lua` → `~/.dotfiles/neovim/init.lua`
- `~/.gitconfig` → `~/.dotfiles/git/.gitconfig`
- `~/Library/Application Support/Code/User/settings.json` → `~/.dotfiles/vscode/settings.json`

This means **changes to dotfiles are immediately reflected** system-wide without needing to re-run installers.

## Common Commands & Development

### Shell Performance Testing

```bash
# Measure zsh startup time (runs 10 iterations)
timesh

# Alternative method
for i in $(seq 1 10); do /usr/bin/time $SHELL -i -c exit; done
```

## Critical Architecture Patterns

### 1. Shell Startup Optimization

The shell configuration is **performance-optimized**:

- `.zprofile` manually exports paths instead of using `eval` commands (faster startup), with the exception of FNM which requires `eval`
- Paths are hardcoded rather than dynamically generated where possible
- Plugins are carefully selected to minimize startup time
- `vi-mode` plugin loaded before `fzf` to avoid keybinding conflicts
- FNM plugin commented out in `.zshrc` in favor of eval in `.zprofile` for speed
- Powerlevel10k instant prompt is on. Code that asks for input (password prompts, y/n questions) must go above it in `.zshrc`, and code below it should not print output
- Completion security checks are off (`ZSH_DISABLE_COMPFIX=true`) to skip the slow `compaudit` scan

**Example from `.zprofile`**:

```bash
# Manual path exports (faster than eval)
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# FNM requires eval for use-on-cd functionality
eval "$(fnm env --use-on-cd)"
```

### 2. FZF Integration

FZF (fuzzy finder) is integrated throughout the workflow:

- Git aliases use FZF for interactive file/branch selection
- Shell history search enhanced with FZF
- Custom color scheme matches Monokai Pro theme

### 3. Vi-Mode Everywhere

Vi keybindings are enabled across:

- Zsh (vi-mode plugin with custom cursor styles per mode)
- Neovim (native)
- VS Code (via extensions)

### 4. Monokai Pro Theme Consistency

The Monokai Pro color scheme is unified across all tools:

- Ghostty terminal
- VS Code, Neovim editors
- FZF fuzzy finder

### 5. Sudo Privilege Maintenance

Many install scripts use this pattern to avoid repeated password prompts:

```bash
sudo -v  # Ask for password upfront
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
```

### 6. Interactive Install Scripts

Most installers:

- Prompt for confirmation before changes
- Backup existing configurations
- Allow selective installation of components
- Exit gracefully if dependencies are missing

## Shell Configuration Details

### Zsh File Responsibilities

- **`.zprofile`**: Login shell startup - PATH setup, environment variables (performance-critical)
- **`.zshrc`**: Interactive shell config - Oh-My-Zsh, plugins, theme
- **`aliases.zsh`**: Custom command shortcuts (sourced by OMZ)
- **`functions.zsh`**: Custom shell functions (sourced by OMZ)
- **`exports.zsh`**: Environment variables (sourced by OMZ)
- **`.p10k.zsh`**: Powerlevel10k prompt configuration

## MCP Server Configuration

`mcp/mcp-config.json` defines the MCP servers. `mcp/install.sh` symlinks it for VS Code. Claude Code gets the same servers from its plugins. Do not symlink it to `/Library/Application Support/ClaudeCode/managed-mcp.json`. Claude Code treats that file as an enterprise policy, and the OpenCode Claude Agent provider then fails.

The servers are:

- **chrome-devtools-mcp**: Browser automation and DevTools access
- **context7**: Documentation and context lookup
- **playwright**: Web testing and browser automation

## OpenCode Configuration

OpenCode 2 reads its configuration from two files in `~/.config/opencode`. `opencode/install.sh` installs OpenCode with Homebrew. Then it links the directory `~/.config/opencode` to `opencode/config`. The files are:

- `opencode.jsonc`: Agents, models, MCP servers, and permissions. The schema is `https://opencode.ai/config.json`.
- `cli.json`: The TUI (terminal user interface) configuration, for example theme, diffs, and session display. The schema is `https://opencode.ai/v2/cli.json`.

Do not link each file separately. OpenCode saves `cli.json` with a temp file and a rename, and the rename replaces a file symlink with a regular file.

Do not add `service.json` to the repository. It contains the password for the OpenCode background server. The root `.gitignore` excludes it.

## Adding New Components

To add a new tool configuration:

1. Create directory: `~/.dotfiles/<tool-name>/`
2. Add configuration files
3. Create `install.sh` with symlink logic:

   ```bash
   #!/usr/bin/env bash
   ln -s ~/.dotfiles/<tool-name>/<config> <target-location>
   ```

4. Update README.md with installation step
5. Test the installer

## Working with This Repository

### Making Changes

1. Edit files directly in `~/.dotfiles/` subdirectories
2. Changes apply immediately (symlinks make them live)
3. Test the changes
4. Use git to track changes (but do NOT create commits unless explicitly asked)

### Updating Install Scripts

When updating installers (especially VS Code extensions):

1. Export current state (e.g., `code --list-extensions`)
2. Update the install script
3. Test on a clean account if possible
4. Document any new dependencies

### Shell Customization

Custom functions and aliases live in:

- `zsh/aliases.zsh` - Command shortcuts
- `zsh/functions.zsh` - Shell functions
- `zsh/exports.zsh` - Environment variables

These are automatically sourced by Oh-My-Zsh via the ZSH_CUSTOM mechanism.
