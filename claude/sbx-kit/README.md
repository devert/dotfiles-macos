# Claude Code Kit for Docker Sandboxes

This folder is a mixin kit for [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) (`sbx`). A mixin kit adds configuration to a built-in sandbox agent. This kit gives the `claude` agent the Claude Code rules, status line, and configuration from this repo.

Docker Sandboxes do not read `~/.claude` from the host. Symlinks to host paths also do not work inside a sandbox. This kit mounts `~/.dotfiles/claude` into the sandbox and makes the links inside the sandbox.

## Files

- `spec.yaml`: The kit descriptor. It runs `link.sh` each time the sandbox starts.
- `link.sh`: The startup script. It runs inside the sandbox as the `agent` user.

## Create a sandbox with the kit

Run this command from the project folder on the host:

```bash
sbx run claude . ~/.dotfiles/claude:ro --kit ~/.dotfiles/claude/sbx-kit
```

To give the sandbox a name, add `--name <sandbox-name>`.

The command has three parts:

- `.`: The project folder. The sandbox can read and write it.
- `~/.dotfiles/claude:ro`: The Claude Code configuration from this repo. The `:ro` suffix makes the mount read-only.
- `--kit ~/.dotfiles/claude/sbx-kit`: This kit.

Do not remove `:ro`. Claude runs in the sandbox with all permission checks off. `status-line.sh` and `settings.json` also run on the host. A writable mount lets the agent change code that runs outside the sandbox.

## Start the sandbox again

When you create the sandbox, sbx saves the mount and the kit with it. You do not add them again. To start the sandbox again, run:

```bash
sbx run --name <sandbox-name>
```

## Add the kit to an existing sandbox

You cannot add the kit to an existing sandbox. The kit needs the mount, because `link.sh` is on the mount. sbx cannot add a mount to a sandbox after it creates the sandbox.

1. Remove the sandbox with `sbx rm <sandbox-name>`.
2. Go to the project folder on the host.
3. Create the sandbox again with the command in [Create a sandbox with the kit](#create-a-sandbox-with-the-kit).

Do not run `sbx rm` before you save the data that you need from the sandbox. The command deletes all data in the sandbox that is not in the project folder, for example Claude session history and installed packages.

## What link.sh does

The script makes these changes in `/home/agent/.claude` inside the sandbox:

1. It links `rules` to `rules` in the mount.
2. It links `status-line.sh` to `status-line.sh` in the mount.
3. On the first start only, it saves a copy of the configuration file that sbx wrote. The copy is `settings.sbx.json`.
4. It merges `settings.json` from this repo on top of `settings.sbx.json` and writes the result to `settings.json`. When both files set the same key, the value from this repo wins.

The merge removes these keys from the configuration of this repo:

- `hooks`: The herdr hook calls a script that is only on the host.
- `voice`: The sandbox has no microphone.
- `permissions`: sbx starts Claude in bypass mode. The sandbox keeps the permission configuration from sbx.

The script runs again on each start, so it is safe to run more than one time.

## When changes take effect

- Changes to `rules/` and `status-line.sh` take effect immediately, because the sandbox links to the files on the host.
- Changes to `settings.json` take effect on the next start of the sandbox, because `link.sh` makes a merged copy.

If a new sbx version changes its own `settings.json`, the merge will not include the change. To get the new configuration, delete `/home/agent/.claude/settings.sbx.json` inside the sandbox and start the sandbox again.

## Requirements

- The `sbx` CLI.
- `bash` and `jq` in the sandbox image. The default `claude` image has both.
- Network access to github.com from the sandbox, for the plugins in `extraKnownMarketplaces`.
