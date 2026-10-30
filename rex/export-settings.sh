#!/usr/bin/env zsh

# Export Rex app settings to rex/settings.plist and rex/themes.json
# Run this after changing settings in the Rex Settings window, then commit.
# Window frames, update checks, and session state are left out on purpose.

domain="com.superlogical.rex"
out="$HOME/.dotfiles/rex/settings.plist"
themes="$HOME/.dotfiles/rex/themes.json"
keys=(
  Workspace.appIcon
  Workspace.appearance
  Workspace.darkThemeID
  Workspace.lightThemeID
  Workspace.inactivePaneFadeMode
  Workspace.interfaceStyle
  Workspace.paneDensity
  Workspace.playsProgramActivitySounds
  Workspace.sidebarPosition
  Workspace.tabIconTintMode
  Workspace.tabStyle
  Workspace.terminalAllowsLigatures
  Workspace.terminalCellHeightPercent
  Workspace.terminalCharacterSpacing
  Workspace.terminalCursorBlinkIntervalMilliseconds
  Workspace.terminalCursorBlinkUsesCustomInterval
  Workspace.terminalCursorStyle
  Workspace.terminalCursorStyleForced
  Workspace.terminalFallbackFontNames
  Workspace.terminalFontName
  Workspace.terminalFontPointSize
  Workspace.terminalFontSmoothing
  Workspace.terminalFontStyle
  Workspace.terminalImproveTextContrast
  Workspace.terminalSelectionForeground
  Workspace.terminalSmoothScrolling
  Workspace.usesStandardInactiveWindowPaneStyles
  rex.agents.names-sessions
  rex.server.automatic-restart-enabled
  rex.server.block-plugin-reload-enabled
  rex.server.run-mode
  rex.server.web-client-origin-patterns
)

tmp="$(mktemp -d)"
defaults export "$domain" "$tmp/all.plist"

/usr/bin/python3 -I - "$tmp/all.plist" "$out" "$themes" $keys <<'PY'
import json, plistlib, sys
src, dst, themes, *keys = sys.argv[1:]
with open(src, "rb") as f:
    data = plistlib.load(f)
with open(dst, "wb") as f:
    plistlib.dump({k: data[k] for k in keys if k in data}, f)
# Custom themes are JSON stored as data, so write them as a readable file
if "Workspace.customThemes" in data:
    with open(themes, "w") as f:
        json.dump(json.loads(data["Workspace.customThemes"]), f, indent=2)
        f.write("\n")
PY

rm -rf "$tmp"
echo "Wrote $out and $themes"
