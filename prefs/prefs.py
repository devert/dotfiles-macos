#!/usr/bin/python3 -I

# Export and import macOS app settings kept in ~/Library/Preferences
#
#   prefs/prefs.py export <app-dir>
#   prefs/prefs.py import <app-dir>
#
# <app-dir> is a path, or a folder name in ~/.dotfiles (for example "rex").
# It holds these files:
#   prefs.json         domain, process name, and optional JSON data keys
#   export-keys.txt    keys that the export writes to settings.plist
#   export-ignore.txt  keys and glob patterns that the export leaves out
#   settings.plist     the exported settings
#
# prefs.json example:
#   {
#     "domain": "com.superlogical.rex",
#     "process": "Rex",
#     "json_files": {"Workspace.customThemes": "themes.json"}
#   }
# "json_files" is optional. Each key in it holds JSON stored as data, which
# the export writes to its own readable file instead of settings.plist.

import fnmatch
import json
import os
import plistlib
import subprocess
import sys
from pathlib import Path

DOTFILES = Path.home() / ".dotfiles"


class App:
    def __init__(self, arg):
        path = Path(arg)
        self.dir = path if path.is_dir() else DOTFILES / arg
        with open(self.dir / "prefs.json") as f:
            conf = json.load(f)
        self.domain = conf["domain"]
        self.process = conf["process"]
        self.json_files = {k: self.dir / v for k, v in conf.get("json_files", {}).items()}
        self.settings = self.dir / "settings.plist"
        self.keys_file = self.dir / "export-keys.txt"
        self.ignore_file = self.dir / "export-ignore.txt"
        self.prefs = Path.home() / "Library" / "Preferences" / f"{self.domain}.plist"


def read_list(path):
    if not path.exists():
        return []
    with open(path) as f:
        return [l.rstrip("\n") for l in f if l.strip() and not l.startswith("#")]


def append(path, key):
    with open(path, "a") as f:
        f.write(key + "\n")


def preview(value):
    if isinstance(value, bytes):
        return f"<{len(value)} bytes of data>"
    text = repr(value)
    return text if len(text) <= 80 else text[:77] + "..."


def write_if_changed(path, content):
    if path.exists() and path.read_bytes() == content:
        return False
    path.write_bytes(content)
    return True


def open_tty():
    # Separate read and write handles, since "r+" needs a seekable file
    try:
        return open("/dev/tty"), open("/dev/tty", "w")
    except OSError:
        return None, None


def sort_unknown(app, unknown, data, keys, ignore):
    tty_in, tty_out = open_tty()
    for k in unknown:
        if tty_in is None:
            print(f"Not exported, add to export-keys.txt or export-ignore.txt: {k}")
            continue
        tty_out.write(f"\nNew key: {k}\n  value: {preview(data[k])}\n")
        while True:
            tty_out.write("  [k]eep, [i]gnore, or [s]kip for now? ")
            tty_out.flush()
            answer = tty_in.readline().strip().lower()[:1]
            if answer in ("k", "i", "s"):
                break
        if answer == "k":
            keys.append(k)
            append(app.keys_file, k)
        elif answer == "i":
            ignore.append(k)
            append(app.ignore_file, k)


def export(app):
    exported = subprocess.run(
        ["defaults", "export", app.domain, "-"], capture_output=True, check=True
    ).stdout
    data = plistlib.loads(exported)
    keys, ignore = read_list(app.keys_file), read_list(app.ignore_file)

    unknown = [k for k in sorted(data)
               if k not in keys and k not in app.json_files
               and not any(fnmatch.fnmatchcase(k, p) for p in ignore)]
    if unknown:
        sort_unknown(app, unknown, data, keys, ignore)

    updated = []
    settings = plistlib.dumps({k: data[k] for k in keys if k in data})
    if write_if_changed(app.settings, settings):
        updated.append(app.settings)
    for key, path in app.json_files.items():
        if key in data:
            text = json.dumps(json.loads(data[key]), indent=2) + "\n"
            if write_if_changed(path, text.encode()):
                updated.append(path)

    if updated:
        for path in updated:
            print(f"Updated {path}")
    else:
        print("No changes")


def import_(app):
    if subprocess.run(["pgrep", "-x", app.process], capture_output=True).returncode == 0:
        print(f"Quit {app.process} before importing settings, then run this script again.")
        sys.exit(1)

    # Merge into the existing preferences so window and session state is kept
    data = {}
    if os.path.exists(app.prefs):
        with open(app.prefs, "rb") as f:
            data = plistlib.load(f)
    with open(app.settings, "rb") as f:
        data.update(plistlib.load(f))
    imported = [app.settings]
    for key, path in app.json_files.items():
        if path.exists():
            with open(path) as f:
                data[key] = json.dumps(json.load(f)).encode()
            imported.append(path)
    # Binary, like the file macOS writes (XML would drop fractional seconds)
    with open(app.prefs, "wb") as f:
        plistlib.dump(data, f, fmt=plistlib.FMT_BINARY)

    # Make macOS reload the preferences file instead of using its cached copy
    subprocess.run(["killall", "cfprefsd"], capture_output=True)
    print("Imported " + " and ".join(str(p) for p in imported))


def main():
    if len(sys.argv) != 3 or sys.argv[1] not in ("export", "import"):
        print("Usage: prefs.py export|import <app-dir>")
        sys.exit(2)
    app = App(sys.argv[2])
    export(app) if sys.argv[1] == "export" else import_(app)


if __name__ == "__main__":
    main()
