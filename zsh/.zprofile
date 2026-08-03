# Homebrew
# -------------------------------------------------------------

# Doing this manually to avoid running "brew shellenv" on startup. Improves startup time.
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"

# Add homebrew to PATH
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

# Add brew installed curl to path
export PATH="/opt/homebrew/opt/curl/bin:$PATH"


# FNM (Fast Node Manager)
# -------------------------------------------------------------

eval "$(fnm env --use-on-cd)"


# Python
# ------------------------------------------------------------

export PATH="$HOME/.local/bin:$PATH"

# Enable auto-activation of uv virtualenvs
# TODO


# MCP
# ------------------------------------------------------------

# export MCP_HOME="$HOME/.mcp"
# export MCP_CONFIG_PATH="$MCP_HOME/mcp-config.json"
# export MCP_LOG_LEVEL="info"
# export MCP_LOG_DIR="$MCP_HOME/logs"


# Tmux
# ------------------------------------------------------------

# Automatically start new tmux session on terminal open.
# Only auto-start tmux for interactive login shells attached to a TTY.
# This prevents non-interactive processes (like VS Code's shell env resolver)
# from being replaced by tmux, which can cause unexpected exit codes.
if [ -z "$TMUX" ] && [ -t 1 ] && [[ $- == *i* ]]; then
  exec tmux new-session
fi
