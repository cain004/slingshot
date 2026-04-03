# slingshot

Portable shell configuration for macOS (zsh) and Linux (bash/zsh). Uses [Starship](https://starship.rs/) for a consistent prompt across shells and machines.

## Slingshot Theme

![Starship Slingshot prompt preview](preview.png)

## Install

```sh
curl -sS https://raw.githubusercontent.com/cain004/slingshot/main/install.sh | sh
```

Re-run anytime to pull the latest changes.

## What it does

The install script will:

1. Install **zsh**, **tmux**, **tree**, and **neovim** via apt if missing (Linux only)
2. Install **nvim**, **tmux**, and **tree** via Homebrew if available (macOS only)
3. Install **Starship** prompt
4. Clone this repo to `~/.slingshot`
5. Back up existing dotfiles to `.bak`
6. Symlink dotfiles from the repo into `~/` and `~/.config/`
7. Set zsh as the default shell (Linux only, if not already zsh)

## Files

| File | Purpose |
|---|---|
| `.aliases` | Git, navigation, and shell aliases — shared by bash and zsh |
| `.zshrc` | Zsh config — completion, history, editor, PATH, Starship |
| `.bashrc` | Bash config — completion, history, colors, editor, PATH, Starship |
| `.tmux.conf` | Tmux — 256color, mouse, history, window numbering |
| `.gitconfig` | Git defaults — editor, default branch, pull strategy |
| `starship.toml` | Starship prompt — Slingshot theme with git status and SSH detection |
| `install.sh` | One-line installer |
| `uninstall.sh` | Removes symlinks and restores backups |

## Local overrides

Machine-specific settings go in local files that are sourced but not tracked:

| File | Purpose |
|---|---|
| `~/.local.zshrc` | Extra zsh config (e.g. JAVA_HOME, ANDROID_HOME) |
| `~/.local.bashrc` | Extra bash config |
| `~/.local.gitconfig` | Git user name and email |

## Git aliases

| Alias | Command |
|---|---|
| `ga` | `git add` |
| `gbl` | `git blame -b -w` |
| `gc` | `git commit -v` |
| `gcmsg` | `git commit -m` |
| `gco` | `git checkout` |
| `gcp` | `git cherry-pick` |
| `gcl` | `git clone` |
| `gclean` | `git clean -id` |
| `gcm` | `git checkout main` |
| `gpristine` | `git reset --hard && git clean -dffx` |
| `gd` | `git diff` |
| `gl` | `git pull` |
| `glg` | `git log --stat` |
| `glgg` | `git log --graph` |
| `glog` | `git log --oneline --decorate --graph` |
| `gp` | `git push` |
| `gpsup` | `git push --set-upstream origin <current-branch>` |
| `gst` | `git status` |
| `gsta` | `git stash push` |
| `gstp` | `git stash pop` |
| `gstl` | `git stash list` |
| `gstc` | `git stash clear` |
| `gstall` | `git stash --all` |

## Other aliases

| Alias | Command |
|---|---|
| `ll` | `ls -AlFh` |
| `la` | `ls -A` |
| `lt` | `tree -C -L 2` |
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `mkd` | `mkdir -p` |

## Shell functions

| Function | Description |
|---|---|
| `set_terminal_title <title>` | Set the terminal tab title |

Both `.bashrc` and `.zshrc` set `DISABLE_AUTO_TITLE="true"` to prevent frameworks (oh-my-zsh, iTerm2, etc.) from overriding manually set terminal titles.

## Uninstall

```sh
sh ~/.slingshot/uninstall.sh
```

This removes all symlinks, restores any `.bak` backups, and optionally deletes `~/.slingshot`.

## Updating

Since the dotfiles are symlinked, pulling the repo updates everything:

```sh
cd ~/.slingshot && git pull
```

Or just re-run the install command.

## SSH from Ghostty

If you use [Ghostty](https://ghostty.org/) locally on macOS and SSH into Linux machines, you may see `?????` instead of arrows and have broken backspace/delete keys. This happens because Ghostty reports itself as `xterm-ghostty`, which most Linux servers don't recognize.

**Fix:** Add to `~/.ssh/config` on your Mac:

```ssh
Host *
    SetEnv TERM=xterm-256color
```

This makes SSH sessions use the standard `xterm-256color` terminfo while preserving Ghostty's native features for local use.
