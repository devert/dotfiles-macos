# AGENTS.md

This file gives guidance to AI agents that work in this repository.

## Repository Overview

This repository holds macOS dotfiles. Each tool has its own folder with its configuration files and an `install.sh` script. The install scripts create symlinks from the system locations to the files in `~/.dotfiles`. Thus, a change to a file in this repository applies at once, and you do not need to run the installer again.

Read the `AGENTS.md` file in a folder before you change files there. These folders have one: `neovim/`, `rex/`, `claude/`, `zsh/`, and `opencode/`.

## Rules

- Do not create commits unless the user asks.
- Use the Monokai Pro color scheme in each tool that supports themes (Ghostty, VS Code, Neovim, FZF).
- The Zsh setup has two steps. Run `./zsh/install.sh`, reload the shell with `reload`, then run `./zsh/configure.sh`.
- To measure the Zsh startup time, run `timesh`.

## Adding New Components

1. Make a folder `~/.dotfiles/<tool-name>/` and put the configuration files in it.
2. Write an `install.sh` that links the files to their system locations.
3. Add the installation step to `README.md`.
4. Run the installer to test it.
