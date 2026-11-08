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

# Add uv installed Python executables to path
export PATH="$HOME/.local/bin:$PATH"


# FZF
# ------------------------------------------------------------

# Set here, not in exports.zsh, so that commands that get the login
# environment without .zshrc also get these options.
export FZF_DEFAULT_OPTS="--prompt='❯ '"
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:-1,fg+:-1,bg:-1,bg+:#373539
  --color=hl:#78dce8,hl+:#ff6188,info:#727072,marker:#fc9867
  --color=prompt:#a9dc76,spinner:#fc9867,pointer:#ff6188,header:#727072
  --color=border:#727072,label:#fcfcfa,query:#fcfcfa
  --info=right
  --height=~40%'


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
# if [ -z "$TMUX" ] && [ -t 1 ] && [[ $- == *i* ]]; then
#   exec tmux new-session
# fi
