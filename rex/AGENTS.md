# Rex Configuration

Rex keeps its configuration in two places. Keybindings and custom actions are in Lua files. App settings from the Rex Settings window are in the macOS preferences for `com.superlogical.rex`.

- `init.lua`: Keybindings and custom actions, symlinked to `~/.config/rex/init.lua`
- `layouts.lua`: Named pane layouts, symlinked to `~/.config/rex/layouts.lua`. `init.lua` loads it with `require("layouts")`. Rex looks for required files in `~/.config/rex`, so each Lua file needs its own symlink there. Each layout is a custom action titled `Layout: <title>` in the command palette. The action splits the focused pane in the current tab. If the tab already has that layout, the action does nothing. To add a layout, add an entry to the `layouts` table
- `init.lua` also loads the [rex-fzf-url](https://github.com/devert/rex-fzf-url) plugin and binds Cmd+U to its URL picker. `install.sh` clones the plugin into `~/.config/rex/plugins/rex-fzf-url` if that folder does not exist
- `settings.plist`: App settings exported from the Rex preferences
- `themes.json`: Custom themes, stored in the preferences as JSON data
- `export-keys.txt`: Preference keys that the export writes to `settings.plist`
- `export-ignore.txt`: Preference keys and glob patterns that the export leaves out, such as window frames and updater state

## Export settings

After you change settings in the Rex Settings window, run `rex/export-settings.py`. Then commit the changed files. Rex can stay open during the export.

If the content of `settings.plist` or `themes.json` did not change, the script does not write that file. If a key is in neither list file, the script shows its value and asks you to keep it, ignore it, or skip it. Your answer goes into `export-keys.txt` or `export-ignore.txt`. Without a terminal, the script prints the new keys and does not ask.

## Import settings

`rex/install.sh` creates the `init.lua` and `layouts.lua` symlinks and runs `rex/import-settings.py`. You can also run the import script on its own. Quit Rex before the import, because a running Rex writes its own copy over the preferences file. If Rex is running, the script stops.

The import merges `settings.plist` and `themes.json` into the existing preferences, so window and session state stays. The script writes a binary plist, because the XML format removes fractional seconds from dates. Then it restarts `cfprefsd` so that macOS reads the new file.
