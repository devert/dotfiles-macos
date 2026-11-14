# Zsh

The shell configuration is tuned for a fast startup. Keep it fast when you change it.

- `.zprofile` exports paths directly and does not use `eval`, because `eval` is slower. FNM is the only exception. It needs `eval "$(fnm env --use-on-cd)"`.
- The FNM plugin in `.zshrc` stays commented out, because the `eval` in `.zprofile` is faster.
- Load the `vi-mode` plugin before `fzf`. In the other order, the keybindings conflict.
- Powerlevel10k instant prompt is on. Put code that asks for input (password prompts, y/n questions) above it in `.zshrc`. Code below it must not print output.
- `ZSH_DISABLE_COMPFIX=true` turns off the completion security checks. This skips the slow `compaudit` scan.
- Put aliases in `aliases.zsh`, functions in `functions.zsh`, and environment variables in `exports.zsh`. Oh-My-Zsh loads these files through `ZSH_CUSTOM`.

After a change, run `timesh` to measure the startup time.
