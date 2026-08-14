# Publishing fzf-url to the herdr plugin marketplace

The marketplace (https://herdr.dev/plugins/) discovers plugins automatically
from public GitHub repos tagged with the `herdr-plugin` topic that have a
`herdr-plugin.toml` manifest. There is no review step. The dotfiles repo is
private, so publishing means extracting this directory to its own public repo.

## 1. Create the public repo

```sh
gh repo create devert/herdr-fzf-url --public \
  --description "Fuzzy-find and open URLs visible in the focused pane, like tmux-fzf-url"
```

Copy the contents of this directory in (manifest at the repo root — that is
where `herdr plugin install owner/repo` looks), minus this file.

## 2. Add a LICENSE file

MIT, and it is not optional: `extract-urls` ports wfxr/tmux-fzf-url's xre
patterns (MIT) and adapts kaar/herdr-fzf-url's perl implementation (MIT).
The README's Credits section already names both — keep it.

## 3. Sanity-check the manifest

- `id = "devert.fzf-url"` — stays as-is; it is the install id users bind
  keys against, so changing it later breaks their configs.
- `min_herdr_version = "0.8.0"` — only verified against 0.8.0. It may work
  on 0.7.x (the mechanisms match plugins that declare 0.7.4) but that was
  never tested; lower it only after testing.
- Add `repository = "https://github.com/devert/herdr-fzf-url"`.

## 4. Push, tag, add the topic

```sh
git push -u origin main
git tag v0.1.0 && git push --tags       # lets installers pin with --ref
gh repo edit devert/herdr-fzf-url --add-topic herdr-plugin
```

The topic is what makes it appear on herdr.dev/plugins.

## 5. Switch this machine to the published source

```sh
herdr plugin unlink devert.fzf-url
herdr plugin install devert/herdr-fzf-url
```

Then in the dotfiles:

- `herdr/install.sh`: replace the `herdr plugin link ...` line with
  `herdr plugin install devert/herdr-fzf-url --yes`.
- The `[[keys.command]]` binding in `herdr/config.toml` is unchanged —
  the action id `devert.fzf-url.pick` is the same either way.
- Decide what happens to this directory: delete it from dotfiles (the
  public repo is now the source of truth) or keep it as the development
  checkout and `plugin link` it while hacking on it.

## 6. Optional: CI

A one-job workflow on macOS + Linux runners catches exactly what broke the
existing marketplace ports (bash 4-only builtins on stock macOS):

```yaml
- run: bash -n picker.sh open-picker.sh
- run: bash test/extract-urls.test.sh
```

On the macOS runner, run both with `/bin/bash` (3.2) explicitly.

## Context worth keeping

Design decisions that should survive iteration, learned from the four
existing marketplace ports (all broken or slow in some way):

- **Read `--source visible` only by default.** `recent-unwrapped` with a
  line count makes herdr visibly scroll alternate-screen panes (TUIs,
  agents) to harvest scrollback. This was the original complaint against
  kaar/herdr-fzf-url and abrose/herdr-url-picker.
- **No runtime downloads.** willian/herdr-fzf-url curl-pipes an installer
  for the xre binary on first keypress; the perl extractor exists to avoid
  that supply-chain hop.
- **bash 3.2 compatible.** willian's port dies on `mapfile` (bash 4) on
  stock macOS. No `mapfile`/`readarray`/`declare -A`/`${var,,}`.
- **No `set -e` in picker.sh.** A failed popup should print and pause, not
  flash-close undebuggably.
- **fzf draws no border.** herdr popup chrome already draws the frame and
  the title (from the manifest pane title); fzf adding its own produces a
  double border. Sizing accounts for this: the junegunn +8/+7 formula's
  border allowance is spent on herdr's chrome instead of fzf's.
