# Claude Code Configuration

## Custom skills

Each folder in `claude/skills/` is one skill. `claude/install.sh` links each skill folder into `~/.claude/skills/`. The links are per skill, because other tools also put skills in `~/.claude/skills/`.

## The simple-english skill

`claude/skills/simple-english/` is a copy of the skill from the [SimpleEnglish](https://github.com/AminBlg/SimpleEnglish) project. It is under the MIT license. Keep the `LICENSE` file in the skill folder. The copy has no hooks, no output style, and no evals. It has only `SKILL.md` and the files in `references/`.

`claude/skills/simple-english.upstream` holds the upstream commit that the copy is based on. The update script reads and writes this file. Do not edit it by hand.

### Local changes

The copy has these local changes. Keep them when you update the skill:

1. `SKILL.md` has no "The Reply" section. Chat replies follow `claude/rules/writing.md`, which allows lists, bold, and headers.
2. The intro paragraph of `SKILL.md` says that the rules are for documents only.
3. The `description` does not end with "The same rules govern the reply".
4. The "Self-Check Before You Deliver" section has no step for replies. The "Modes" section does not say that the reply stays Plain.
5. The `metadata` block has a `source` line with the upstream URL.
6. Line 3 of `references/strict-vocabulary.md` says that Strict mode does not change chat replies.
7. The `description` names commit messages and PR descriptions in its list of uses.

If you add a local change, add it to this list.

### Update the skill

1. Run `claude/update-simple-english.sh` from any folder. The script downloads the upstream project to a temporary folder. It merges each upstream change into the local copy with a three-way merge. Then it writes the new commit to `simple-english.upstream`.
2. Read the script output. It shows one line for each file that changed: `MERGED`, `ADDED`, `CONFLICT`, `DELETED`, or `SKIP`.
3. If the output shows `CONFLICT`, open the file and find the `<<<<<<< local` markers. Keep the local side where the conflict touches a local change from the list above. Keep the upstream side for all other conflicts. Remove all markers.
4. If upstream adds new rules for chat replies, do not add them. If upstream adds hooks or a new folder outside `skills/simple-english/`, do not copy them. The script copies only `skills/simple-english/` and `LICENSE`.
5. If the output shows `DELETED`, delete the local file only when no local change depends on it.
6. Read `git diff claude/skills/`. Make sure that the change does not add rules that conflict with `claude/rules/writing.md`.
7. Do not commit until the user approves the diff.

If the script shows "Up to date", there is nothing to do.
