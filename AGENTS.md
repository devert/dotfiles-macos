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
rex/          # Rex terminal configuration: keybindings, app settings, and custom themes
prefs/        # Export and import of macOS app preferences, used by rex/ and homerow/
```

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
- `~/.config/nvim/` → `~/.dotfiles/neovim/`
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

### Shell Management

```bash
reload      # Reload shell configuration (alias for omz reload)
zshconfig   # Open ~/.zshrc in editor
```

### Git Workflow

The git configuration includes 66+ aliases. Most commonly used:

```bash
git s         # Status
git aa        # Add all changes
git c         # Commit with message
git co        # Checkout
git p         # Push
git pl        # Pull
git l         # Log with graph
git nb        # New branch
git b         # List branches
git bd        # Branch delete
git bdf       # Branch delete (forced)
git rhh       # Reset hard to HEAD
git rnb       # Rename branch
git t         # Tag list
```

**FZF-enhanced aliases** (interactive selection with fuzzy finder):

```bash
ga   # Add files interactively
gu   # Unstage files interactively
gb   # Checkout branch interactively
gbr  # Checkout remote branch interactively
```

### Kubernetes (Custom Functions)

```bash
kgpg [search-term]       # Get pods with optional grep
kubesh pod-name-fragment # Shell into pod matching name
```

### Modern CLI Tool Replacements

```bash
ls / lsa / lt  # eza aliases (replaces ls) with --group-directories-first
y               # yazi terminal file manager
bat             # Cat clone with syntax highlighting (installed via Homebrew)
nvm             # Aliased to fnm for backward compatibility
```

### VS Code Extensions

```bash
# Export currently installed extensions
code --list-extensions | xargs -L 1 echo code --install-extension

# Update extensions via install script
~/.dotfiles/vscode/install.sh
```

## Critical Architecture Patterns

### 1. Shell Startup Optimization

The shell configuration is **performance-optimized**:

- `.zprofile` manually exports paths instead of using `eval` commands (faster startup), with the exception of FNM which requires `eval`
- Paths are hardcoded rather than dynamically generated where possible
- Plugins are carefully selected to minimize startup time
- `vi-mode` plugin loaded before `fzf` to avoid keybinding conflicts
- FNM plugin commented out in `.zshrc` in favor of eval in `.zprofile` for speed

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
- **`exports.zsh`**: Environment variables like FZF_DEFAULT_OPTS (sourced by OMZ)
- **`.p10k.zsh`**: Powerlevel10k prompt configuration

### Active Oh-My-Zsh Plugins

```bash
plugins=(git history-substring-search zoxide zsh-autosuggestions zsh-syntax-highlighting vi-mode fzf)
```

Plugin order matters: `vi-mode` before `fzf` to prevent keybinding conflicts. The `fnm` plugin is commented out in favor of eval in `.zprofile` for faster startup.

## Neovim Configuration

Uses **lazy.nvim** as the plugin manager with Lua configuration:

- Entry point: `init.lua` (bootstraps lazy.nvim and loads configs)
- Core settings: `lua/options.lua`
- Plugin definitions: `lua/plugins.lua` and `lua/plugins/*.lua`
- Locked versions: `lazy-lock.json`

Key plugins: LSP, Telescope (fuzzy finder), Tree-sitter, Neo-tree, Which-key, Monokai Pro theme.

## VS Code Configuration

The VS Code install script manages **44 extensions** programmatically via `code --install-extension`. Extensions are version-controlled in the install script rather than via VS Code sync.

Configuration includes:

- Custom settings
- Custom keybindings
- Code snippets
- Monokai Pro theme and icon theme
- Operator Mono font with JetBrainsMonoNL Nerd Font as fallback
- Vim integration with Neovim enabled (leader key = Space)
- Copilot inline suggestions disabled by default, togglable via keybinding
- Multiple language formatters

## Git Configuration Philosophy

Git aliases follow a pattern (66+ total):

- **Single-letter shortcuts**: Ultra-common operations (a, b, c, d, s)
- **Multi-letter names**: Compound operations (amend, uncommit, delete-merged-branches)
- **Aliases that chain aliases**: e.g., `dmb` combines multiple operations
- **Uses git-extras**: For advanced functionality (delete-branch, rename-branch, etc.)

## Terminal Emulator

**Primary**: Ghostty (custom split/scroll keybindings, Monokai Pro theme)

- Operator Mono font at 16pt
- Custom keybindings for split management (Opt+h/j/k/l for resize)
- Quick terminal shortcut: Shift+Ctrl+Opt+Cmd+U
- Window maximized by default

## Claude Code Configuration

Configuration lives in `claude/` and includes:

- `settings.json`: Core settings (model, permissions, status line, auto-update disabled)
- `status-line.sh`: Custom status line showing directory, git branch/status, model, context usage %, and rate limit %
- `rules/git.md`: Commit rules (no structured formatting, request review before committing)
- `rules/github.md`: PR rules (assign to @devert, no "Co-Authored-By" lines, no "Created with Claude Code")

## MCP Server Configuration

MCP server configs in `mcp/` are symlinked to both Claude Code and VS Code:

- **chrome-devtools-mcp**: Browser automation and DevTools access
- **context7**: Documentation and context lookup
- **playwright**: Web testing and browser automation

## Tmux Configuration

- **Prefix**: Ctrl+Space (not default Ctrl+b)
- **Status bar**: Hidden
- **Plugins** (via tpm): tmux-fzf-url, tmux-jump, extrakto
- **Vi mode** for copy mode
- **Passthrough**: Enabled (for Ghostty shell integration)

## App Settings Export and Import

Many apps keep the configuration from their Settings window in the macOS preferences, in `~/Library/Preferences/<domain>.plist`. A domain is the app identifier, such as `com.superlogical.rex`. The `prefs/prefs.py` script copies that configuration to and from a component directory. Rex and Homerow use it.

Each component directory that uses the script contains these files:

- `prefs.json`: The domain, the process name of the app, and optional JSON data keys
- `settings.plist`: The configuration exported from the preferences
- `export-keys.txt`: Preference keys that the export writes to `settings.plist`
- `export-ignore.txt`: Preference keys and glob patterns that the export leaves out, such as window frames and updater state

Some apps store JSON text as data in a preference key. Rex keeps its custom themes in this format. Put such a key in the `json_files` object of `prefs.json`, with a file name as its value. The export then writes that key to the named file as readable JSON, and not to `settings.plist`.

```json
{
  "domain": "com.superlogical.rex",
  "process": "Rex",
  "json_files": {"Workspace.customThemes": "themes.json"}
}
```

### Export settings

After you change the configuration in the Settings window of the app, run `prefs/prefs.py export <component>`. For example, run `prefs/prefs.py export rex`. Then commit the changed files. The app can stay open during the export.

If the content of an output file did not change, the script does not write that file. If a key is in neither list file, the script shows its value and asks you to keep it, ignore it, or skip it. Your answer goes into `export-keys.txt` or `export-ignore.txt`. Without a terminal, the script prints the new keys and does not ask.

### Import settings

The `install.sh` script of the component runs `prefs/prefs.py import <component>`. You can also run the import on its own. Quit the app before the import, because a running app writes its own copy over the preferences file. If the app is running, the script stops.

The import merges `settings.plist` and the JSON files into the existing preferences, so window and session state stays. The script writes a binary plist, because the XML format removes fractional seconds from dates. Then it restarts `cfprefsd` so that macOS reads the new file.

### Add an app

1. Open the Settings window of the app and set the configuration that you want.
2. Find the domain with `defaults domains | tr ',' '\n' | grep -i <app>`.
3. Create `prefs.json` in the component directory with the domain and the process name.
4. Run `prefs/prefs.py export <component>` in a terminal, and answer the prompt for each key.
5. Add `$HOME/.dotfiles/prefs/prefs.py import <component> || exit 1` to the `install.sh` script of the component.

## Rex Configuration

Rex keeps its configuration in two places. Keybindings are in a Lua file. App settings from the Rex Settings window are in the macOS preferences for `com.superlogical.rex`. The export and import use `prefs/prefs.py`, as [App Settings Export and Import](#app-settings-export-and-import) describes.

- `init.lua`: Keybindings, symlinked to `~/.config/rex/init.lua`
- `themes.json`: Custom themes, stored in the preferences as JSON data

`rex/install.sh` creates the `init.lua` symlink and then imports the app settings.

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

## Dependencies

**Critical tools installed via Homebrew**:

- git, git-extras, gh (GitHub CLI)
- fzf, ripgrep, zoxide
- neovim, zsh
- pyenv, pyenv-virtualenv
- fnm (Fast Node Manager)
- eza, bat, yazi
- jq, tmux, curl

**Terminal emulator**: Ghostty
**Editors**: Neovim, VS Code
**Language runtimes**: FNM (Node.js), PyEnv (Python)
**Productivity apps**: Contexts, Homerow, Leader Key

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

## Performance Considerations

This dotfiles setup is optimized for fast shell startup:

- Hardcoded paths in `.zprofile` instead of `eval` commands (exception: FNM requires eval)
- Minimal plugin set in Oh-My-Zsh (FNM plugin commented out in favor of eval in .zprofile)
- Powerlevel10k instant prompt enabled
- Completion security checks disabled

Use `timesh` to measure and track shell startup performance.
