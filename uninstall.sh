#!/bin/sh
set -e

INSTALL_DIR="$HOME/.slingshot"
OLD_INSTALL_DIR="$HOME/.shell-config"

# ----------------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------------
info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m==>\033[0m %s\n" "$1"; }
error() { printf "\033[1;31m==>\033[0m %s\n" "$1"; exit 1; }

printf "\n"
printf "\033[1;36m  slingshot uninstaller\033[0m\n"
printf "\n"

# ----------------------------------------------------------------------------
# Remove symlinks and stubs, restore backups
# ----------------------------------------------------------------------------
remove_link() {
  target="$1"
  if [ -L "$target" ]; then
    link_dest="$(readlink "$target")"
    case "$link_dest" in
      "$INSTALL_DIR"/*)
        rm "$target"
        info "Removed $target"
        if [ -f "$target.bak" ]; then
          mv "$target.bak" "$target"
          info "Restored $target from backup"
        fi
        ;;
      *)
        warn "Skipping $target (symlink does not point to $INSTALL_DIR)"
        ;;
    esac
  else
    warn "Skipping $target (not a symlink)"
  fi
}

# Stubs hold lines that other installers appended, so keep a copy of any
# stub with content beyond the slingshot load line.
remove_stub() {
  target="$1"
  marker="$2"
  if [ -L "$target" ]; then
    remove_link "$target"
    return
  fi
  if [ ! -f "$target" ] || ! grep -qF "$marker" "$target"; then
    warn "Skipping $target (not a slingshot stub)"
    return
  fi
  if awk -v m="$marker" 'f && NF { extra = 1 } index($0, m) { f = 1 } END { exit !extra }' "$target"; then
    mv "$target" "$target.slingshot-stub"
    warn "Kept extra lines from $target in $target.slingshot-stub"
  else
    rm "$target"
    info "Removed $target"
  fi
  if [ -f "$target.bak" ]; then
    mv "$target.bak" "$target"
    info "Restored $target from backup"
  fi
}

remove_link "$HOME/.aliases"
remove_stub "$HOME/.zshrc" "source \"$INSTALL_DIR/.zshrc\""
remove_stub "$HOME/.bashrc" "source \"$INSTALL_DIR/.bashrc\""
remove_link "$HOME/.tmux.conf"
remove_stub "$HOME/.gitconfig" "path = $INSTALL_DIR/.gitconfig"
remove_link "$HOME/.config/starship.toml"

# ----------------------------------------------------------------------------
# Optionally remove the repo
# ----------------------------------------------------------------------------
# Clean up old location if it still exists
if [ -d "$OLD_INSTALL_DIR" ]; then
  rm -rf "$OLD_INSTALL_DIR"
  info "Removed old $OLD_INSTALL_DIR"
fi

if [ -d "$INSTALL_DIR" ]; then
  printf "\n"
  printf "Remove %s? [y/N] " "$INSTALL_DIR"
  read -r answer
  case "$answer" in
    [yY]*)
      rm -rf "$INSTALL_DIR"
      info "Removed $INSTALL_DIR"
      ;;
    *)
      info "Kept $INSTALL_DIR"
      ;;
  esac
fi

# ----------------------------------------------------------------------------
# Done
# ----------------------------------------------------------------------------
printf "\n"
info "Done! Restart your shell or run: exec \$SHELL"
