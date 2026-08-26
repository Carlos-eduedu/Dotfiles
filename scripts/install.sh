#!/bin/sh
# Install managed dotfiles. Package installation is opt-in and macOS/Homebrew-only.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BACKUP_ROOT=${DOTFILES_BACKUP_ROOT:-"$HOME/.dotfiles-backups"}
INSTALL_DEPS=false
BOOTSTRAP_BREW=false
INSTALL_TMUX_PLUGINS=false

usage() {
  cat <<'EOF'
Usage: ./scripts/install.sh [OPTION]...

Install dotfile links with timestamped backups. No packages are installed by default.

  --install-dependencies  Install formulae and casks declared in Brewfile.
  --bootstrap-homebrew    Install Homebrew from its official installer if absent.
  --install-tmux-plugins  Clone TPM if necessary and install declared tmux plugins.
  --restore               Equivalent to all three options above.
  -h, --help              Show this help.

For a clean macOS machine:
  ./scripts/install.sh --restore
EOF
}

for option in "$@"; do
  case "$option" in
    --install-dependencies) INSTALL_DEPS=true ;;
    --bootstrap-homebrew) BOOTSTRAP_BREW=true ;;
    --install-tmux-plugins) INSTALL_TMUX_PLUGINS=true ;;
    --restore) INSTALL_DEPS=true; BOOTSTRAP_BREW=true; INSTALL_TMUX_PLUGINS=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n\n' "$option" >&2; usage >&2; exit 2 ;;
  esac
done

brew_bin() {
  command -v brew 2>/dev/null || {
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      [ -x "$candidate" ] && { printf '%s\n' "$candidate"; return 0; }
    done
    return 1
  }
}

if [ "$BOOTSTRAP_BREW" = true ]; then
  if ! BREW=$(brew_bin); then
    [ "$(uname -s)" = Darwin ] || { printf 'Homebrew bootstrap is supported here only on macOS.\n' >&2; exit 1; }
    printf '%s\n' 'Installing Homebrew with the official Homebrew installer...'
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    BREW=$(brew_bin) || { printf 'Homebrew installation did not produce an available brew command.\n' >&2; exit 1; }
  fi
fi

if [ "$INSTALL_DEPS" = true ]; then
  [ "$(uname -s)" = Darwin ] || { printf 'Brewfile includes macOS casks and cannot be installed on this system.\n' >&2; exit 1; }
  if [ -z "${BREW:-}" ]; then
    BREW=$(brew_bin) || { printf 'Homebrew is required; use --bootstrap-homebrew or install it first.\n' >&2; exit 1; }
  fi
  printf 'Installing dependencies from %s/Brewfile...\n' "$ROOT"
  "$BREW" bundle --file "$ROOT/Brewfile"
fi

STAMP=$(date +%Y%m%d-%H%M%S)
BACKUP="$BACKUP_ROOT/$STAMP"
MANIFEST="$BACKUP/manifest"
mkdir -p "$BACKUP"
: > "$MANIFEST"

install_link() {
  target=$1
  source=$2
  relative=${target#"$HOME"/}

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    return
  fi
  if [ -e "$target" ] || [ -L "$target" ]; then
    mkdir -p "$BACKUP/$(dirname "$relative")"
    mv "$target" "$BACKUP/$relative"
    printf 'existing\t%s\n' "$relative" >> "$MANIFEST"
  else
    printf 'new\t%s\n' "$relative" >> "$MANIFEST"
  fi
  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
}

install_link "$HOME/.zshrc" "$ROOT/zsh/zshrc"
install_link "$HOME/.tmux.conf" "$ROOT/tmux/tmux.conf"
install_link "$HOME/.config/ghostty/config" "$ROOT/ghostty/config"
install_link "$HOME/.config/ghostty/themes" "$ROOT/ghostty/themes"
install_link "$HOME/.config/nvim" "$ROOT/nvim"

if [ "$INSTALL_TMUX_PLUGINS" = true ]; then
  TPM_DIR="$HOME/.tmux/plugins/tpm"
  if [ ! -d "$TPM_DIR/.git" ]; then
    command -v git >/dev/null 2>&1 || { printf 'Git is required for TPM.\n' >&2; exit 1; }
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  fi
  "$TPM_DIR/bin/install_plugins"
fi

printf 'Installed. Backup: %s\n' "$BACKUP"
printf 'To undo: %s/scripts/rollback.sh %s\n' "$ROOT" "$STAMP"
