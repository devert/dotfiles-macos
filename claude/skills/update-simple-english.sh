#!/usr/bin/env bash
# Merge upstream changes from AminBlg/SimpleEnglish into the local copy of the
# simple-english skill. A three-way merge keeps the local edits. Review the
# result with git diff before you commit.
set -euo pipefail

repo_url=https://github.com/AminBlg/SimpleEnglish.git
skills_dir="$(cd "$(dirname "$0")" && pwd)"
skill_dir="$skills_dir/simple-english"
base_file="$skills_dir/simple-english.upstream"
upstream_path=skills/simple-english

base=$(tr -d '[:space:]' < "$base_file")
[[ $base =~ ^[0-9a-f]{40}$ ]] || { echo "No commit hash in $base_file" >&2; exit 1; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
git clone -q --filter=blob:none "$repo_url" "$work/upstream"
cd "$work/upstream"
head=$(git rev-parse HEAD)

if [[ $head == "$base" ]]; then
  echo "Up to date at ${head:0:7}."
  exit 0
fi

echo "Upstream commits since ${base:0:7}:"
git log --oneline "$base..$head" -- "$upstream_path" LICENSE
echo

# Map an upstream path to the local path.
local_path() {
  if [[ $1 == LICENSE ]]; then echo "$skill_dir/LICENSE"; else echo "$skill_dir/${1#"$upstream_path"/}"; fi
}

conflicts=0
while IFS= read -r path; do
  ours=$(local_path "$path")
  rel=${ours#"$skill_dir"/}
  if ! git cat-file -e "$base:$path" 2>/dev/null; then
    if [[ -e $ours ]]; then
      echo "SKIP     $rel (new upstream, but a local file has the same name)"
    else
      mkdir -p "$(dirname "$ours")"
      cp "$path" "$ours"
      echo "ADDED    $rel"
    fi
    continue
  fi
  git show "$base:$path" > "$work/base"
  if git diff --quiet "$base" "$head" -- "$path"; then
    continue
  fi
  if git merge-file -L local -L "upstream ${base:0:7}" -L "upstream ${head:0:7}" \
      "$ours" "$work/base" "$path"; then
    echo "MERGED   $rel"
  else
    echo "CONFLICT $rel"
    conflicts=$((conflicts + 1))
  fi
done < <(git ls-files "$upstream_path" LICENSE)

while IFS= read -r path; do
  echo "DELETED  $(local_path "$path" | sed "s|^$skill_dir/||") (removed upstream, delete it here if you agree)"
done < <(git diff --name-only --diff-filter=D "$base" "$head" -- "$upstream_path" LICENSE)

echo "$head" > "$base_file"
echo
echo "Recorded upstream commit ${head:0:7} in ${base_file#"$skills_dir"/}."

if (( conflicts > 0 )); then
  echo "$conflicts file(s) have conflict markers. Fix them, then review git diff."
  exit 1
fi
echo "Review the changes with git diff."
