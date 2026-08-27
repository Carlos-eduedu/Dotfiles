#!/bin/sh
# Install managed dotfiles. Package installation is opt-in and macOS/Homebrew-only.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BACKUP_ROOT=${DOTFILES_BACKUP_ROOT:-"$HOME/.dotfiles-backups"}
INSTALL_DEPS=false
BOOTSTRAP_BREW=false
INSTALL_TMUX_PLUGINS=false
DRY_RUN=false
CHANGED=0
BACKUP=
MANIFEST=

usage() {
  cat <<'EOF'
Usage: ./scripts/install.sh [OPTION]...

Install dotfile links with timestamped backups. No packages are installed by default.

  --install-dependencies  Install formulae and casks declared in Brewfile.
  --bootstrap-homebrew    Install Homebrew from its official installer if absent.
  --install-tmux-plugins  Clone TPM if necessary and install declared tmux plugins.
  --restore               Equivalent to all three options above.
  --dry-run               Show actions without changing files or installing software.
  -h, --help              Show this help.

For a clean macOS machine:
  ./scripts/install.sh --restore
EOF
}

info() {
  printf '[INFO] %s\n' "$*"
}

for option in "$@"; do
  case "$option" in
    --install-dependencies) INSTALL_DEPS=true ;;
    --bootstrap-homebrew) BOOTSTRAP_BREW=true ;;
    --install-tmux-plugins) INSTALL_TMUX_PLUGINS=true ;;
    --restore) INSTALL_DEPS=true; BOOTSTRAP_BREW=true; INSTALL_TMUX_PLUGINS=true ;;
    --dry-run) DRY_RUN=true ;;
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

preflight_directory() {
  directory=$1
  description=$2
  probe=$directory

  while [ ! -e "$probe" ] && [ ! -L "$probe" ]; do
    parent=$(dirname "$probe")
    [ "$parent" != "$probe" ] || break
    probe=$parent
  done
  [ -d "$probe" ] || { printf '%s is blocked by a non-directory path: %s\n' "$description" "$probe" >&2; exit 1; }
  [ -w "$probe" ] || { printf '%s is not writable: %s\n' "$description" "$probe" >&2; exit 1; }
}

WILL_CHANGE=false
preflight_link() {
  target=$1
  source=$2

  [ -e "$source" ] || [ -L "$source" ] || { printf 'Managed source not found: %s\n' "$source" >&2; exit 1; }
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    return 0
  fi
  preflight_directory "$(dirname "$target")" "Managed target parent"
  WILL_CHANGE=true
}

managed_links() {
  action=$1
  "$action" "$HOME/.zshrc" "$ROOT/zsh/zshrc"
  "$action" "$HOME/.tmux.conf" "$ROOT/tmux/tmux.conf"
  "$action" "$HOME/.config/ghostty/config" "$ROOT/ghostty/config"
  "$action" "$HOME/.config/ghostty/themes" "$ROOT/ghostty/themes"
  "$action" "$HOME/.config/nvim" "$ROOT/nvim"
  "$action" "$HOME/.config/eza/theme.yml" "$ROOT/eza/theme.yml"
  "$action" "$HOME/.config/starship.toml" "$ROOT/starship/starship.toml"
  "$action" "$HOME/.config/git/config" "$ROOT/git/config"
  "$action" "$HOME/.config/git/ignore" "$ROOT/git/ignore"
  "$action" "$HOME/.config/git/commit-template" "$ROOT/git/commit-template"
}

PRIVATE_GIT_CONFIG="$HOME/.config/git/config.local"
preflight_private_git_config() {
  if [ -L "$PRIVATE_GIT_CONFIG" ]; then
    printf 'Refusing symbolic link for private Git config: %s\n' "$PRIVATE_GIT_CONFIG" >&2
    exit 1
  fi
  if [ -e "$PRIVATE_GIT_CONFIG" ]; then
    [ -f "$PRIVATE_GIT_CONFIG" ] || {
      printf 'Private Git config is not a regular file: %s\n' "$PRIVATE_GIT_CONFIG" >&2
      exit 1
    }
    return 0
  fi
  preflight_directory "$(dirname "$PRIVATE_GIT_CONFIG")" "Private Git config parent"
}

# Validate every local destination before package operations or link mutations.
managed_links preflight_link
preflight_private_git_config
[ "$WILL_CHANGE" = false ] || preflight_directory "$BACKUP_ROOT" "Backup root"

if [ "$BOOTSTRAP_BREW" = true ] && ! BREW=$(brew_bin); then
  [ "$(uname -s)" = Darwin ] || { printf 'Homebrew bootstrap is supported here only on macOS.\n' >&2; exit 1; }
  if [ "$DRY_RUN" = true ]; then
    info 'Would run the official Homebrew installer.'
  else
    info 'Installing Homebrew with the official Homebrew installer...'
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    BREW=$(brew_bin) || { printf 'Homebrew installation did not produce an available brew command.\n' >&2; exit 1; }
  fi
fi

if [ "$INSTALL_DEPS" = true ]; then
  [ "$(uname -s)" = Darwin ] || { printf 'Brewfile includes macOS casks and cannot be installed on this system.\n' >&2; exit 1; }
  if [ "$DRY_RUN" = true ]; then
    info "Would install dependencies from $ROOT/Brewfile."
  else
    if [ -z "${BREW:-}" ]; then
      BREW=$(brew_bin) || { printf 'Homebrew is required; use --bootstrap-homebrew or install it first.\n' >&2; exit 1; }
    fi
    info "Installing dependencies from $ROOT/Brewfile..."
    "$BREW" bundle --file "$ROOT/Brewfile"
  fi
fi

prepare_backup() {
  [ -z "$BACKUP" ] || return 0

  stamp=$(date +%Y%m%d-%H%M%S)
  BACKUP="$BACKUP_ROOT/$stamp"
  suffix=0
  while [ -e "$BACKUP" ] || [ -L "$BACKUP" ]; do
    suffix=$((suffix + 1))
    BACKUP="$BACKUP_ROOT/$stamp-$suffix"
  done
  MANIFEST="$BACKUP/manifest"
  (
    umask 077
    mkdir -p "$BACKUP_ROOT"
    chmod 700 "$BACKUP_ROOT"
    mkdir "$BACKUP"
    : > "$MANIFEST"
  )
}

install_link() {
  target=$1
  source=$2
  relative=${target#"$HOME"/}

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    return 0
  fi

  if [ "$DRY_RUN" = true ]; then
    if [ -e "$target" ] || [ -L "$target" ]; then
      info "Would back up and link $target -> $source"
    else
      info "Would link $target -> $source"
    fi
    CHANGED=$((CHANGED + 1))
    return 0
  fi

  prepare_backup
  if [ -e "$target" ] || [ -L "$target" ]; then
    mkdir -p "$BACKUP/$(dirname "$relative")"
    mv "$target" "$BACKUP/$relative"
    printf 'existing\t%s\t%s\n' "$relative" "$source" >> "$MANIFEST"
  else
    printf 'new\t%s\t%s\n' "$relative" "$source" >> "$MANIFEST"
  fi
  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  CHANGED=$((CHANGED + 1))
}

abort_with_rollback() {
  status=$1
  shift
  printf '%s\n' "$*" >&2
  if [ -n "$BACKUP" ]; then
    printf 'Managed links changed before this failure. Backup: %s\n' "$BACKUP" >&2
    printf 'To undo: %s/scripts/rollback.sh %s\n' "$ROOT" "$(basename "$BACKUP")" >&2
  fi
  exit "$status"
}

managed_links install_link

# Identity is deliberately local and never belongs in the managed repository.
if [ ! -e "$PRIVATE_GIT_CONFIG" ]; then
  if [ "$DRY_RUN" = true ]; then
    info "Would create private local Git config at $PRIVATE_GIT_CONFIG"
  else
    mkdir -p "$(dirname "$PRIVATE_GIT_CONFIG")" ||
      abort_with_rollback $? 'Failed to create the private Git config directory.'
    # noclobber closes the gap between preflight and creation without following
    # a file or link that appeared in the meantime.
    (umask 077; set -C; : > "$PRIVATE_GIT_CONFIG") ||
      abort_with_rollback 1 "Refusing to overwrite private Git config: $PRIVATE_GIT_CONFIG"
  fi
fi

if [ "$INSTALL_TMUX_PLUGINS" = true ]; then
  TPM_DIR="$HOME/.tmux/plugins/tpm"
  if [ "$DRY_RUN" = true ]; then
    info "Would install tmux plugins through $TPM_DIR."
  else
    if [ ! -d "$TPM_DIR/.git" ]; then
      command -v git >/dev/null 2>&1 || abort_with_rollback 1 'Git is required for TPM.'
      mkdir -p "$(dirname "$TPM_DIR")"
      git clone https://github.com/tmux-plugins/tpm "$TPM_DIR" ||
        abort_with_rollback $? 'Failed to clone TPM.'
    fi
    "$TPM_DIR/bin/install_plugins" || abort_with_rollback $? 'Failed to install tmux plugins.'
  fi
fi

if [ "$DRY_RUN" = true ]; then
  info "Dry run complete: $CHANGED managed link(s) would change."
elif [ "$CHANGED" -eq 0 ]; then
  info 'Already up to date; no backup was created.'
else
  info "Installed $CHANGED managed link(s). Backup: $BACKUP"
  info "To undo: $ROOT/scripts/rollback.sh $(basename "$BACKUP")"
fi
