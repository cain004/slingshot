#!/bin/sh
set -e

VERSION="2.1.0"
REPO="https://github.com/cain004/slingshot.git"
INSTALL_DIR="$HOME/.slingshot"
OLD_INSTALL_DIR="$HOME/.shell-config"

# ----------------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------------
info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m==>\033[0m %s\n" "$1"; }
error() { printf "\033[1;31m==>\033[0m %s\n" "$1"; exit 1; }

backup() {
  if [ -f "$1" ] && [ ! -L "$1" ]; then
    warn "Backing up $1 -> $1.bak"
    cp "$1" "$1.bak"
  fi
}

# Use sudo only if not root
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi

# ----------------------------------------------------------------------------
# Detect OS
# ----------------------------------------------------------------------------
OS="$(uname -s)"
case "$OS" in
  Linux*)  OS="linux" ;;
  Darwin*) OS="mac" ;;
  *)       error "Unsupported OS: $OS" ;;
esac

printf "\n"
printf "\033[1;36m  slingshot installer v%s\033[0m\n" "$VERSION"
printf "\n"
info "Detected OS: $OS"

# ----------------------------------------------------------------------------
# Install apt packages (Linux only)
# ----------------------------------------------------------------------------
if [ "$OS" = "linux" ]; then
  NEEDS_UPDATE=0
  apt_install() {
    if [ "$NEEDS_UPDATE" -eq 0 ]; then
      info "Updating package list..."
      $SUDO apt-get update -qq
      NEEDS_UPDATE=1
    fi
    info "Installing $1..."
    $SUDO apt-get install -y -qq "$1"
  }
  for cmd in git zsh tmux tree nvim; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      pkg="$cmd"
      [ "$cmd" = "nvim" ] && pkg="neovim"
      apt_install "$pkg"
    fi
  done
  for pkg in zsh-autosuggestions zsh-syntax-highlighting; do
    if [ ! -f "/usr/share/$pkg/$pkg.zsh" ]; then
      apt_install "$pkg"
    fi
  done
else
  if ! command -v git >/dev/null 2>&1; then
    error "git not found. Install Xcode CLI tools: xcode-select --install"
  fi
  if command -v brew >/dev/null 2>&1; then
    BREW_PREFIX="$(brew --prefix)"
    for cmd in nvim tmux tree; do
      if ! command -v "$cmd" >/dev/null 2>&1; then
        info "Installing $cmd..."
        brew install "$cmd"
      fi
    done
    for pkg in zsh-autosuggestions zsh-syntax-highlighting; do
      if [ ! -f "$BREW_PREFIX/share/$pkg/$pkg.zsh" ]; then
        info "Installing $pkg..."
        brew install "$pkg"
      fi
    done
  else
    for cmd in nvim tmux tree zsh-autosuggestions zsh-syntax-highlighting; do
      warn "brew not found. Install missing deps with: brew install $cmd"
    done
  fi
fi

# ----------------------------------------------------------------------------
# Install starship
# ----------------------------------------------------------------------------
if ! command -v starship >/dev/null 2>&1; then
  info "Installing starship..."
  if [ "$OS" = "mac" ]; then
    if command -v brew >/dev/null 2>&1; then
      brew install starship
    else
      curl -sS https://starship.rs/install.sh | sh
    fi
  else
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi
fi

# ----------------------------------------------------------------------------
# Clone or update repo
# ----------------------------------------------------------------------------
# Migrate from old ~/.shell-config location
if [ -d "$OLD_INSTALL_DIR" ] && [ ! -d "$INSTALL_DIR" ]; then
  info "Migrating $OLD_INSTALL_DIR -> $INSTALL_DIR..."
  mv "$OLD_INSTALL_DIR" "$INSTALL_DIR"
  git -C "$INSTALL_DIR" remote set-url origin "$REPO"
fi

if [ -d "$INSTALL_DIR" ]; then
  info "Updating slingshot..."
  git -C "$INSTALL_DIR" pull --quiet
else
  info "Cloning slingshot..."
  git clone --quiet "$REPO" "$INSTALL_DIR"
fi

# ----------------------------------------------------------------------------
# Symlink dotfiles
# ----------------------------------------------------------------------------
info "Linking dotfiles..."

backup "$HOME/.aliases"
ln -sf "$INSTALL_DIR/.aliases" "$HOME/.aliases"
info "Linked .aliases"

CURRENT_SHELL="$(basename "$SHELL")"

backup "$HOME/.zshrc"
ln -sf "$INSTALL_DIR/.zshrc" "$HOME/.zshrc"
info "Linked .zshrc"

backup "$HOME/.bashrc"
ln -sf "$INSTALL_DIR/.bashrc" "$HOME/.bashrc"
info "Linked .bashrc"

backup "$HOME/.tmux.conf"
ln -sf "$INSTALL_DIR/.tmux.conf" "$HOME/.tmux.conf"
info "Linked .tmux.conf"

backup "$HOME/.gitconfig"
ln -sf "$INSTALL_DIR/.gitconfig" "$HOME/.gitconfig"
info "Linked .gitconfig"

mkdir -p "$HOME/.config"
backup "$HOME/.config/starship.toml"
ln -sf "$INSTALL_DIR/starship.toml" "$HOME/.config/starship.toml"
info "Linked starship.toml"

# Ghostty config (macOS only)
if [ "$OS" = "mac" ]; then
  GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
  mkdir -p "$GHOSTTY_DIR"
  backup "$GHOSTTY_DIR/config"
  ln -sf "$INSTALL_DIR/ghostty/config" "$GHOSTTY_DIR/config"
  info "Linked ghostty/config"
fi

# ----------------------------------------------------------------------------
# Set default shell to zsh (Linux only, if not already)
# ----------------------------------------------------------------------------
if [ "$OS" = "linux" ] && [ "$CURRENT_SHELL" != "zsh" ]; then
  if $SUDO chsh -s "$(which zsh)" "$(whoami)" 2>/dev/null; then
    info "Default shell changed to zsh"
  else
    warn "Could not change default shell. Run manually: chsh -s \$(which zsh)"
  fi
fi

# ----------------------------------------------------------------------------
# Done
# ----------------------------------------------------------------------------
printf "\n"
info "Done! Restart your shell or run: exec \$SHELL"
