# fzf-url

A [herdr](https://herdr.dev) port of [wfxr/tmux-fzf-url](https://github.com/wfxr/tmux-fzf-url):
press a key, fuzzy-pick any URL visible in the focused pane, and open it in
your browser.

- **Enter** opens the selection, **ctrl-y** copies it, **tab** multi-selects.
- The popup is sized to its content and styled like junegunn/tmux-fzf-url's
  fzf window; with no URLs on screen it shows a notification instead of
  opening a popup.
- Extracts `http(s)`/`ftp`/`file` URLs, `git@host:path` remotes, bare `www.`
  domains, IPv4 addresses, quoted `'user/repo'` GitHub shorthands, and OSC 8
  hyperlink targets.
- Reads only the rendered viewport (`--source visible`), so it opens
  instantly — including on alternate-screen panes (TUIs, agents), where deep
  scrollback reads force herdr to visibly scroll the pane.
- No runtime downloads and no bash 4 requirement: works on stock macOS
  (bash 3.2) with `perl` and [`fzf`](https://github.com/junegunn/fzf).

## Install

```sh
herdr plugin install devert/herdr-fzf-url   # once published
# or, from a checkout:
herdr plugin link /path/to/fzf-url
```

Bind a key in `~/.config/herdr/config.toml`:

```toml
[[keys.command]]
key = "prefix+u"
type = "plugin_action"
command = "devert.fzf-url.pick"
description = "fzf-url: open URL picker"
```

## Configuration

Optional flat TOML at `$(herdr plugin config-dir devert.fzf-url)/config.toml`:

```toml
history_limit = "screen"  # default. A number (e.g. "2000") scans that many
                          # scrollback lines via recent-unwrapped instead —
                          # NOTE: on alternate-screen panes herdr must scroll
                          # the pane to harvest rows, which is visibly slow.
open = "open -a Firefox"                    # custom opener
copy_cmd = "pbcopy"                         # custom clipboard command
fzf_options = "--no-wrap"                   # extra fzf flags
extra_pattern = 'JIRA-\d+'                  # extra perl regex to extract
extra_sub = 'https://jira.example.com/browse/$0'
```

## Testing

```sh
test/extract-urls.test.sh
```

## Credits & License

MIT. URL extraction patterns ported from
[wfxr/tmux-fzf-url](https://github.com/wfxr/tmux-fzf-url) (MIT); the perl
implementation is adapted from
[kaar/herdr-fzf-url](https://github.com/kaar/herdr-fzf-url) (MIT).
