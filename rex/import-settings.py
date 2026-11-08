#!/usr/bin/python3 -I

# Import Rex app settings from rex/settings.plist and rex/themes.json
# (exported with rex/export-settings.py).
# Merges into the existing preferences so window and session state is kept.

import json
import os
import plistlib
import subprocess
import sys
from pathlib import Path

DIR = Path.home() / ".dotfiles" / "rex"
PREFS = Path.home() / "Library" / "Preferences" / "com.superlogical.rex.plist"
SETTINGS = DIR / "settings.plist"
THEMES = DIR / "themes.json"


def merge(prefs, settings, themes):
    data = {}
    if os.path.exists(prefs):
        with open(prefs, "rb") as f:
            data = plistlib.load(f)
    with open(settings, "rb") as f:
        data.update(plistlib.load(f))
    with open(themes) as f:
        data["Workspace.customThemes"] = json.dumps(json.load(f)).encode()
    # Binary, like the file macOS writes (XML would drop fractional seconds)
    with open(prefs, "wb") as f:
        plistlib.dump(data, f, fmt=plistlib.FMT_BINARY)


def main():
    if subprocess.run(["pgrep", "-x", "Rex"], capture_output=True).returncode == 0:
        print("Quit Rex before importing settings, then run this script again.")
        sys.exit(1)
    merge(PREFS, SETTINGS, THEMES)
    # Make macOS reload the preferences file instead of using its cached copy
    subprocess.run(["killall", "cfprefsd"], capture_output=True)
    print(f"Imported {SETTINGS} and {THEMES}")


if __name__ == "__main__":
    main()
