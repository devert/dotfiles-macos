#!/usr/bin/env bash
# picker.sh: runs inside the floating Rex pane that the fzf_url action in
# init.lua opens. The action already read the scrollback, extracted the URLs,
# and wrote them to the file in $1. Enter opens the selection, ctrl-y copies
# it, tab selects more than one. The pane closes when this script exits.
# Must stay compatible with macOS /bin/bash 3.2.
set -u

# No `set -e`: a pane that closes without a message is hard to debug.
# Failures print a message and pause so the user can read it.
fail() {
    printf 'fzf-url: %s\n' "$1" >&2
    sleep 2
    exit 1
}

command -v fzf >/dev/null 2>&1 || fail "fzf not found in PATH"

url_file="${1:-}"
[[ -n "$url_file" && -f "$url_file" ]] || fail "no URL list file"
urls=$(cat "$url_file")
rm -f "$url_file"
[[ -z "$urls" ]] && exit 0

# Same fzf look as the herdr plugin (herdr/plugins/fzf-url/picker.sh).
# --expect reports the pressed key (ctrl-y, or empty for Enter) on the first
# output line. The selections follow.
selection=$(printf '%s\n' "$urls" | fzf \
    --multi --no-margin --no-padding --wrap \
    --expect ctrl-y --style default \
    --header 'Enter: Open URL / CTRL-Y: Copy to clipboard' \
    --header-border top --header-first \
    --highlight-line --info inline-right \
    --padding 1,1,0,1) || exit 0

key=$(printf '%s\n' "$selection" | head -n 1)
chosen=$(printf '%s\n' "$selection" | tail -n +2)
[[ -z "$chosen" ]] && exit 0

if [[ "$key" == "ctrl-y" ]]; then
    printf '%s' "$chosen" | pbcopy
else
    while IFS= read -r url; do
        [[ -n "$url" ]] && open "$url"
    done <<< "$chosen"
fi
