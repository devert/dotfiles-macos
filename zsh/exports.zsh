# Homebrew will not auto-update before running `brew install`,`brew upgrade` or `brew tap`.
export HOMEBREW_NO_AUTO_UPDATE=1

# FNM (Fast Node Manager) configuration
export FNM_DIR="/Users/devert/.local/share/fnm"
export FNM_VERSION_FILE_STRATEGY="local"
export FNM_LOGLEVEL="info"
export FNM_NODE_DIST_MIRROR="https://nodejs.org/dist"
export FNM_COREPACK_ENABLED="false"
export FNM_RESOLVE_ENGINES="true"
export FNM_ARCH="arm64"

# FNM acting as NVM
export NVM_DIR="/Users/devert/.local/share/fnm"
