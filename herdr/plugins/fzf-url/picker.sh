#!/usr/bin/env bash
# picker.sh — runs inside the herdr popup pane (opened by open-picker.sh,
# which already read the pane, extracted the URLs, and sized this popup to
# fit them). Presents fzf styled like junegunn/tmux-fzf-url:
# Enter opens, ctrl-y copies, tab multi-selects.
# Must stay compatible with macOS /bin/bash 3.2.
set -u

herdr="${HERDR_BIN_PATH:-herdr}"

# Deliberately no `set -e`: a silent popup flash-close is undebuggable.
# Failures print a message and pause so the user can read it.
fail() {
    printf 'fzf-url: %s\n' "$1" >&2
    sleep 2
    exit 1
}

command -v fzf >/dev/null 2>&1 || fail "fzf not found in PATH"

url_file="${FZF_URL_LIST_FILE:-}"
[[ -n "$url_file" && -f "$url_file" ]] || fail "no URL list (FZF_URL_LIST_FILE)"
urls=$(cat "$url_file")
rm -f "$url_file"
[[ -z "$urls" ]] && exit 0

# ---- pick --------------------------------------------------------------------

# fzf options ported from junegunn/tmux-fzf-url's fzf-url.rb, minus its
# border: there fzf's --tmux popup draws the frame and " URLs " label, while
# here herdr's popup chrome already draws both (the label comes from the
# manifest pane title). --expect reports the pressed key (ctrl-y, or empty
# for Enter) on the first output line; the selections follow.
# $FZF_URL_FZF_OPTIONS is intentionally unquoted: word-splitting is the point.
# shellcheck disable=SC2086
selection=$(printf '%s\n' "$urls" | fzf \
    --multi --no-margin --no-padding --wrap \
    --expect ctrl-y --style default \
    --header 'Enter: Open URL / CTRL-Y: Copy to clipboard' \
    --header-border top --header-first \
    --highlight-line --info inline-right \
    --padding 1,1,0,1 \
    ${FZF_URL_FZF_OPTIONS:-}) || exit 0

key=$(printf '%s\n' "$selection" | head -n 1)
chosen=$(printf '%s\n' "$selection" | tail -n +2)
[[ -z "$chosen" ]] && exit 0

# ---- act ---------------------------------------------------------------------

get_copy_cmd() {
    if [[ -n "${FZF_URL_COPY_CMD:-}" ]]; then echo "$FZF_URL_COPY_CMD"
    elif command -v pbcopy >/dev/null 2>&1; then echo "pbcopy"
    elif [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v wl-copy >/dev/null 2>&1; then echo "wl-copy"
    elif [[ -n "${DISPLAY:-}" ]] && command -v xclip >/dev/null 2>&1; then echo "xclip -selection clipboard"
    elif [[ -n "${DISPLAY:-}" ]] && command -v xsel >/dev/null 2>&1; then echo "xsel --clipboard --input"
    fi
}

# The popup pane dies when this script exits, so non-macOS openers are
# detached with nohup to survive it (macOS `open` returns immediately).
open_url() {
    if [[ -n "${FZF_URL_OPENER:-}" ]]; then nohup $FZF_URL_OPENER "$1" >/dev/null 2>&1 &
    elif command -v open >/dev/null 2>&1; then open "$1"
    elif command -v xdg-open >/dev/null 2>&1; then nohup xdg-open "$1" >/dev/null 2>&1 &
    elif [[ -n "${BROWSER:-}" ]]; then nohup "$BROWSER" "$1" >/dev/null 2>&1 &
    else fail "no opener found (open/xdg-open/\$BROWSER)"
    fi
}

if [[ "$key" == "ctrl-y" ]]; then
    cmd=$(get_copy_cmd)
    [[ -z "$cmd" ]] && fail "no clipboard tool found (pbcopy/wl-copy/xclip/xsel)"
    printf '%s' "$chosen" | $cmd
    "$herdr" notification show "fzf-url" --body "Copied to clipboard" >/dev/null 2>&1
else
    while IFS= read -r url; do
        [[ -n "$url" ]] && open_url "$url"
    done <<< "$chosen"
    wait
fi
