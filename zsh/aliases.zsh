#!/usr/bin/env zsh

# Path shortcuts
alias db="cd ~/Dropbox"
alias dl="cd ~/Downloads"
alias doc="cd ~/Documents"
alias dt="cd ~/Desktop"
alias df="cd ~/.dotfiles"
alias prj="cd ~/Projects"

# Shorten commonly typed commands
alias b="brew"
alias c="cargo"
alias cc="claude"
alias code="code ."
alias d="docker"
alias dsa="docker stop (docker ps -q)"
alias dka="docker kill (docker ps -q)"
alias dc="docker compose"
alias dcb="docker compose build"
alias dcbnc="docker compose build --no-cache"
alias dcd="docker compose down"
alias dce="docker compose exec"
alias dck="docker compose kill"
alias dcs="docker compose stop"
alias dcu="docker compose up"
alias g="git"
alias kc="kubectl"
alias nvm="fnm"
alias oc="opencode"
alias p="pnpm"
alias t="tmux"
alias vim="nvim"
alias v="vim"
alias y="yazi"

unalias gb
unalias gbr
alias ga="git status --porcelain | grep -E '^(\?\?| M| D| A)' | fzf | awk '{print \$2}' | xargs git add"
alias gu="git status --porcelain | grep -E '^(M |A |D |R |C )' | fzf | awk '{print \$2}' | xargs git restore --staged"
alias gb="git branch | grep -v \"^\*\" | fzf | xargs git checkout"
alias gbr="git branch -r | sed 's/.*origin\///' | fzf | xargs -I {} git checkout {}"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

# Reload shell
alias reload="omz reload"

# Edit .zshrc
alias zshconfig="v ~/.zshrc"

# Eza aliases
alias ls="eza -a -F --icons"
alias lsa="eza -la -F --icons"
alias lt="eza -T --icons"
