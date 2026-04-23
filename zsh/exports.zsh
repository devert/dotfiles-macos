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

# FZF Default Options
export FZF_DEFAULT_OPTS="--prompt='❯ '"
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:-1,fg+:-1,bg:-1,bg+:#373539
  --color=hl:#78dce8,hl+:#ff6188,info:#727072,marker:#fc9867
  --color=prompt:#a9dc76,spinner:#fc9867,pointer:#ff6188,header:#727072
  --color=border:#727072,label:#fcfcfa,query:#fcfcfa
  --info=right
  --height=~40%'
