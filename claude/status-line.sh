#!/bin/bash

input=$(cat)

# Directory and model
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
dir=$(basename "$cwd")

# Git info
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)

  # Ahead/behind remote
  upstream=$(git -C "$cwd" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)
  git_extras=""
  if [ -n "$upstream" ]; then
    ahead=$(git -C "$cwd" rev-list --count '@{upstream}..HEAD' 2>/dev/null)
    behind=$(git -C "$cwd" rev-list --count 'HEAD..@{upstream}' 2>/dev/null)
    [ "$ahead" -gt 0 ] 2>/dev/null && git_extras="${git_extras} ↑${ahead}"
    [ "$behind" -gt 0 ] 2>/dev/null && git_extras="${git_extras} ↓${behind}"
  fi

  # Staged files
  staged=$(git -C "$cwd" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
  [ "$staged" -gt 0 ] && git_extras="${git_extras} +${staged}"

  # Unstaged/modified files
  unstaged=$(git -C "$cwd" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
  [ "$unstaged" -gt 0 ] && git_extras="${git_extras} !${unstaged}"

  # Untracked files
  untracked=$(git -C "$cwd" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
  [ "$untracked" -gt 0 ] && git_extras="${git_extras} ?${untracked}"

  git_info=" \033[36m$branch\033[0m\033[32m$git_extras\033[0m"
else
  git_info=''
fi

# Context usage
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$ctx_pct" ]; then
  ctx_int=$(printf '%.0f' "$ctx_pct")
else
  ctx_int=0
fi

# 5-hour rate limit usage
rl=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
if [ -n "$rl" ]; then
  rl_int=$(printf '%.0f' "$rl")
else
  rl_int=0
fi

printf "\033[32m%s\033[0m%b\033[90m | %s\033[0m \033[33m[C:%d%%]\033[0m\033[90m | \033[33m[U:%d%%]\033[0m" \
  "$dir" "$git_info" "$model" "$ctx_int" "$rl_int"
