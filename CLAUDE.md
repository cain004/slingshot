# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Portable shell configuration for macOS (zsh) and Linux (bash/zsh) with Starship prompt. Dotfiles live in `~/.slingshot`; `install.sh` symlinks most of them into `~/`, but writes untracked stubs for `~/.zshrc`, `~/.bashrc`, and `~/.gitconfig` that source/include the repo copies (so third-party installers that append to those files don't dirty the repo).

**Terminal Workflow**: The maintainer uses iTerm2 + tmux on macOS, and tmux on Linux. `.tmux.conf` applies on both platforms — treat it as primary, not Linux-only. `ghostty/config` and the cmux aliases in `.aliases` are unused leftovers kept for portability.

## Architecture

- **`.bashrc` / `.zshrc`** — Shell-specific config (history, completion, keybindings, Starship init). Both source `.aliases` and end with local override sourcing.
- **`.aliases`** — Shared aliases and shell functions used by both bash and zsh. Must use POSIX-compatible syntax.
- **`starship.toml`** — Starship prompt theme ("Slingshot"). Uses custom modules for hostname (cyan local / orange SSH) and git status (green clean / red dirty). Built-in git modules are disabled.
- **`.tmux.conf`** — Tmux settings (256color, mouse, history, 1-indexed windows).
- **`.gitconfig`** — Portable git config (no user fields). Includes `~/.local.gitconfig` for name/email.
- **`install.sh`** — POSIX `sh` installer. Installs dependencies, clones repo, backs up existing dotfiles, writes stubs for rc/gitconfig files and symlinks the rest. Migrates pre-2.2 symlinked installs by moving tool-appended lines from the tracked files into the stubs before `git pull`.

## Key Conventions

- **Stubs, not symlinks, for files tools write to**: Never change `install.sh` back to symlinking `.zshrc`, `.bashrc`, or `.gitconfig`. Keep `uninstall.sh` stub markers in sync with `install_stub` calls.
- **Local overrides pattern**: Machine-specific config goes in `~/.local.{zshrc,bashrc,gitconfig}` — never in tracked files.
- **Section format**: All config files use `# ===` headers for top-level sections and `# ---` headers for subsections.
- **Shell function naming**: Use `snake_case` for function names (e.g., `git_current_branch`, `set_terminal_title`).
- **Cross-shell compatibility**: `.aliases` must work in both bash and zsh. Shell-specific features go in the respective rc file.
- **Local overrides are always last**: The local override source line must remain the final section in `.bashrc` and `.zshrc`.
- **Starship init must precede zsh keybindings**: In `.zshrc`, the history substring search bindings must come after `starship init zsh`.

## Testing Changes

No build system or test suite. To verify:
- `bash --norc --noprofile` then `source .bashrc`
- `zsh --no-rcs` then `source .zshrc`
- `shellcheck install.sh` (installer is POSIX sh)
