#!/usr/bin/env bash
# Runs inside the sandbox on every start. Must stay idempotent.
set -euo pipefail

src="${DOTFILES_CLAUDE:-/Users/devert/.dotfiles/claude}"
dest="$HOME/.claude"

if [ ! -d "$src" ]; then
  echo "dotfiles-claude: $src is not mounted, skipping" >&2
  exit 0
fi

mkdir -p "$dest"

# Links resolve inside the sandbox, so host edits show up live
ln -sfn "$src/rules" "$dest/rules"
ln -sfn "$src/status-line.sh" "$dest/status-line.sh"

# Keep the settings sbx wrote at creation as the base for every merge
if [ -f "$dest/settings.json" ] && [ ! -f "$dest/settings.sbx.json" ]; then
  cp "$dest/settings.json" "$dest/settings.sbx.json"
fi
[ -f "$dest/settings.sbx.json" ] || echo '{}' >"$dest/settings.sbx.json"

# Drop host-only keys and keep the sandbox's own permissions
jq -s '.[0] * (.[1] | del(.hooks, .voice, .permissions))' \
  "$dest/settings.sbx.json" "$src/settings.json" >"$dest/settings.json.tmp"
mv "$dest/settings.json.tmp" "$dest/settings.json"
