#!/usr/bin/python3 -I

# Export Rex app settings to rex/settings.plist and rex/themes.json
# Run this after changing settings in the Rex Settings window, then commit.
# Keys to export are in export-keys.txt, keys left out are in export-ignore.txt.
# A key in neither file prompts for which file to add it to.

import fnmatch
import json
import plistlib
import subprocess
from pathlib import Path

DOMAIN = "com.superlogical.rex"
DIR = Path.home() / ".dotfiles" / "rex"
OUT = DIR / "settings.plist"
THEMES = DIR / "themes.json"
KEYS_FILE = DIR / "export-keys.txt"
IGNORE_FILE = DIR / "export-ignore.txt"


def read_list(path):
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


def sort_unknown(unknown, data, keys, ignore):
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
            append(KEYS_FILE, k)
        elif answer == "i":
            ignore.append(k)
            append(IGNORE_FILE, k)


def main():
    exported = subprocess.run(
        ["defaults", "export", DOMAIN, "-"], capture_output=True, check=True
    ).stdout
    data = plistlib.loads(exported)
    keys, ignore = read_list(KEYS_FILE), read_list(IGNORE_FILE)

    unknown = [k for k in sorted(data)
               if k not in keys and not any(fnmatch.fnmatchcase(k, p) for p in ignore)]
    if unknown:
        sort_unknown(unknown, data, keys, ignore)

    updated = []
    settings = plistlib.dumps({k: data[k] for k in keys if k in data})
    if write_if_changed(OUT, settings):
        updated.append(OUT)
    # Custom themes are JSON stored as data, so write them as a readable file
    if "Workspace.customThemes" in data:
        themes = json.dumps(json.loads(data["Workspace.customThemes"]), indent=2) + "\n"
        if write_if_changed(THEMES, themes.encode()):
            updated.append(THEMES)

    if updated:
        for path in updated:
            print(f"Updated {path}")
    else:
        print("No changes")


if __name__ == "__main__":
    main()
