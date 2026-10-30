#!/usr/bin/env zsh

# Install Rex
# echo "Installing Rex"
# TODO: Install from Cask when available

# Configure Rex
echo "Configuring Rex"
mkdir -p $HOME/.config/rex
ln -sfn $HOME/.dotfiles/rex/init.lua $HOME/.config/rex/init.lua

# Import app settings (exported with rex/export-settings.sh)
# Merge into the existing preferences so window and session state is kept
if pgrep -x Rex >/dev/null; then
  echo "Quit Rex before importing settings, then run this script again."
  exit 1
fi
prefs="$HOME/Library/Preferences/com.superlogical.rex.plist"
/usr/bin/python3 -I - "$prefs" "$HOME/.dotfiles/rex/settings.plist" "$HOME/.dotfiles/rex/themes.json" <<'PY'
import json, os, plistlib, sys
prefs, settings, themes = sys.argv[1:]
data = {}
if os.path.exists(prefs):
    with open(prefs, "rb") as f:
        data = plistlib.load(f)
with open(settings, "rb") as f:
    data.update(plistlib.load(f))
with open(themes) as f:
    data["Workspace.customThemes"] = json.dumps(json.load(f)).encode()
with open(prefs, "wb") as f:
    plistlib.dump(data, f)
PY
killall cfprefsd 2>/dev/null

echo "Rex installation and configuration complete!"
