#!/usr/bin/env bash
# open-picker.sh — plugin action entrypoint. Actions run without a TTY, so
# this does everything non-interactive up front — read the invoking pane,
# extract URLs, size the popup to the content like junegunn/tmux-fzf-url —
# then opens the popup pane that runs fzf. With no URLs it shows a
# notification instead of flashing an empty popup.
# Must stay compatible with macOS /bin/bash 3.2.
#
# Optional config, flat key = "value" TOML at
# $(herdr plugin config-dir <id>)/config.toml:
#   history_limit = "screen"   # default: rendered viewport only (fast).
#                              # A number switches to recent-unwrapped
#                              # scrollback; on alternate-screen panes herdr
#                              # must scroll the pane to harvest rows, which
#                              # is visibly slow. Leave on "screen".
#   open          = "open -a Firefox"
#   copy_cmd      = "pbcopy"
#   fzf_options   = "--no-wrap"
#   extra_pattern = 'JIRA-\d+'                              # extra perl regex
#   extra_sub     = 'https://jira.example.com/browse/$0'    # its substitution
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
herdr="${HERDR_BIN_PATH:-herdr}"
plugin="${HERDR_PLUGIN_ID:-devert.fzf-url}"

fail() {
    printf 'fzf-url: %s\n' "$1" >&2
    exit 1
}

# ---- config ----------------------------------------------------------------

history_limit="screen"
opener=""
copy_cmd=""
fzf_options=""
extra_pattern=""
extra_sub=""

config_file="${HERDR_PLUGIN_CONFIG_DIR:-}/config.toml"
if [[ -n "${HERDR_PLUGIN_CONFIG_DIR:-}" && -f "$config_file" ]]; then
    while IFS='=' read -r key value; do
        key="${key#"${key%%[![:space:]]*}"}"
        key="${key%"${key##*[![:space:]]}"}"
        value="${value#"${value%%[![:space:]]*}"}"
        value="${value%"${value##*[![:space:]]}"}"
        [[ -z "$key" || "$key" == \#* || -z "$value" ]] && continue
        value="${value#\"}"; value="${value%\"}"
        value="${value#\'}"; value="${value%\'}"
        case "$key" in
            history_limit) history_limit="$value" ;;
            open)          opener="$value" ;;
            copy_cmd)      copy_cmd="$value" ;;
            fzf_options)   fzf_options="$value" ;;
            extra_pattern) extra_pattern="$value" ;;
            extra_sub)     extra_sub="$value" ;;
        esac
    done < "$config_file"
fi

# ---- resolve the invoking pane -----------------------------------------------

# Keybinding invocations set HERDR_ACTIVE_PANE_ID; action invocations set
# HERDR_PANE_ID. Fall back to the focused pane from the invocation context.
pane_id="${HERDR_PANE_ID:-${HERDR_ACTIVE_PANE_ID:-}}"
if [[ -z "$pane_id" && -n "${HERDR_PLUGIN_CONTEXT_JSON:-}" ]]; then
    pane_id=$(printf '%s' "$HERDR_PLUGIN_CONTEXT_JSON" |
        perl -ne 'print $1 if /"focused_pane_id"\s*:\s*"([^"]+)"/')
fi
[[ -z "$pane_id" ]] && fail "no focused pane"

# ---- read + extract ----------------------------------------------------------

if [[ "$history_limit" == "screen" || -z "$history_limit" ]]; then
    text=$("$herdr" pane read "$pane_id" --source visible --format text) ||
        fail "pane read failed for $pane_id"
elif printf '%s' "$history_limit" | grep -q '^[0-9][0-9]*$'; then
    text=$("$herdr" pane read "$pane_id" --source recent-unwrapped \
        --lines "$history_limit" --format text) ||
        fail "pane read failed for $pane_id"
else
    fail "invalid history_limit: $history_limit (use \"screen\" or a number)"
fi

# Newest URLs on top, like tmux-fzf-url's .reverse.uniq.
urls=$(printf '%s\n' "$text" |
    FZF_URL_EXTRA_PATTERN="$extra_pattern" FZF_URL_EXTRA_SUB="$extra_sub" \
        perl "$SCRIPT_DIR/extract-urls" | { tac 2>/dev/null || tail -r; })

if [[ -z "$urls" ]]; then
    "$herdr" notification show "fzf-url" --body "No URLs found" >/dev/null 2>&1
    exit 0
fi

# ---- hand off to the popup -----------------------------------------------------

state_dir="${HERDR_PLUGIN_STATE_DIR:-${TMPDIR:-/tmp}}"
mkdir -p "$state_dir"
url_file="$state_dir/urls.$$"
printf '%s\n' "$urls" > "$url_file"

# Size the popup to its content, junegunn/tmux-fzf-url style:
# width = longest line + 8, height = count + 7, clamped to the tab area.
header='Enter: Open URL / CTRL-Y: Copy to clipboard'
area=$("$herdr" pane layout --pane "$pane_id" 2>/dev/null |
    perl -ne 'print "$1 $2" if /"area":\{"height":(\d+),"width":(\d+)/')
max_h=${area%% *}
max_w=${area##* }
[[ -z "$max_w" || -z "$max_h" ]] && { max_w=160; max_h=45; }

set -- $(printf '%s\n' "$urls" | awk -v hdr="${#header}" '
    { n += 1; if (length($0) > w) w = length($0) }
    END { if (hdr > w) w = hdr; print w + 8, n + 7 }')
width=$1
height=$2
[[ $width -gt $max_w ]] && width=$max_w
[[ $height -gt $max_h ]] && height=$max_h

exec "$herdr" plugin pane open \
    --plugin "$plugin" \
    --entrypoint picker \
    --width "$width" \
    --height "$height" \
    --env "FZF_URL_LIST_FILE=$url_file" \
    --env "FZF_URL_OPENER=$opener" \
    --env "FZF_URL_COPY_CMD=$copy_cmd" \
    --env "FZF_URL_FZF_OPTIONS=$fzf_options"
