#!/bin/sh
# Restore a backup created by install.sh after validating the complete manifest.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BACKUP_ROOT=${DOTFILES_BACKUP_ROOT:-"$HOME/.dotfiles-backups"}
DRY_RUN=false
STAMP=

usage() {
  cat <<'EOF'
Usage: ./scripts/rollback.sh [--dry-run] TIMESTAMP

Restore links from a backup created by install.sh. The complete manifest is
validated before any managed link is removed.

  --dry-run   Validate and show actions without changing files.
  -h, --help  Show this help.
EOF
}

info() {
  printf '[INFO] %s\n' "$*"
}

managed_source() {
  case "$1" in
    .zshrc) printf '%s\n' "$ROOT/zsh/zshrc" ;;
    .tmux.conf) printf '%s\n' "$ROOT/tmux/tmux.conf" ;;
    .config/ghostty/config) printf '%s\n' "$ROOT/ghostty/config" ;;
    .config/ghostty/themes) printf '%s\n' "$ROOT/ghostty/themes" ;;
    .config/nvim) printf '%s\n' "$ROOT/nvim" ;;
    .config/eza/theme.yml) printf '%s\n' "$ROOT/eza/theme.yml" ;;
    .config/starship.toml) printf '%s\n' "$ROOT/starship/starship.toml" ;;
    .config/git/config) printf '%s\n' "$ROOT/git/config" ;;
    .config/git/ignore) printf '%s\n' "$ROOT/git/ignore" ;;
    .config/git/commit-template) printf '%s\n' "$ROOT/git/commit-template" ;;
    *) return 1 ;;
  esac
}

for argument in "$@"; do
  case "$argument" in
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage; exit 0 ;;
    -*) printf 'Unknown option: %s\n\n' "$argument" >&2; usage >&2; exit 2 ;;
    *)
      [ -z "$STAMP" ] || { printf 'Only one backup timestamp may be supplied.\n\n' >&2; usage >&2; exit 2; }
      STAMP=$argument
      ;;
  esac
done

[ -n "$STAMP" ] || { usage >&2; exit 2; }
case "$STAMP" in
  [!0-9]*|*[!0-9A-Za-z._-]*|.|..)
    printf 'Invalid backup timestamp: %s\n' "$STAMP" >&2
    exit 2
    ;;
esac

BACKUP="$BACKUP_ROOT/$STAMP"
MANIFEST="$BACKUP/manifest"
[ -r "$MANIFEST" ] || { printf 'Backup manifest not found: %s\n' "$MANIFEST" >&2; exit 1; }

tab=$(printf '\t')
seen='|'
entries=0

# Preflight every entry first so a malformed or incomplete backup changes nothing.
while IFS="$tab" read -r state relative source extra; do
  [ -n "$state" ] || continue
  [ -z "$extra" ] || { printf 'Too many fields in backup manifest entry: %s\n' "$relative" >&2; exit 1; }
  # Manifests created before the typed format contain only the relative path.
  if [ -z "$relative" ]; then
    relative=$state
    state=existing
  fi

  case "$state" in
    existing|new) ;;
    *) printf 'Invalid manifest state for %s: %s\n' "$relative" "$state" >&2; exit 1 ;;
  esac
  case "$relative" in
    ''|/*|.|..|./*|*/./*|*/.|../*|*/../*|*/..|*'|'*)
      printf 'Unsafe path in backup manifest: %s\n' "$relative" >&2
      exit 1
      ;;
  esac
  expected=$(managed_source "$relative") || { printf 'Unmanaged path in backup manifest: %s\n' "$relative" >&2; exit 1; }
  [ -z "$source" ] || [ "$source" = "$expected" ] || {
    printf 'Unexpected source in backup manifest for %s: %s\n' "$relative" "$source" >&2
    exit 1
  }
  case "$seen" in
    *"|$relative|"*) printf 'Duplicate path in backup manifest: %s\n' "$relative" >&2; exit 1 ;;
  esac
  seen="$seen$relative|"

  target="$HOME/$relative"
  [ -L "$target" ] || { printf 'Refusing to replace non-link target: %s\n' "$target" >&2; exit 1; }
  actual=$(readlink "$target")
  [ "$actual" = "$expected" ] || {
    printf 'Refusing to replace link with unexpected destination: %s -> %s\n' "$target" "$actual" >&2
    exit 1
  }
  if [ "$state" = existing ]; then
    saved="$BACKUP/$relative"
    [ -e "$saved" ] || [ -L "$saved" ] || { printf 'Missing backup: %s\n' "$saved" >&2; exit 1; }
  fi
  entries=$((entries + 1))
done < "$MANIFEST"

while IFS="$tab" read -r state relative source extra; do
  [ -n "$state" ] || continue
  if [ -z "$relative" ]; then
    relative=$state
    state=existing
  fi
  target="$HOME/$relative"

  if [ "$DRY_RUN" = true ]; then
    if [ "$state" = new ]; then
      info "Would remove newly managed link $target"
    else
      info "Would restore $target from $BACKUP/$relative"
    fi
    continue
  fi

  rm "$target"
  if [ "$state" = existing ]; then
    saved="$BACKUP/$relative"
    mkdir -p "$(dirname "$target")"
    mv "$saved" "$target"
  fi
done < "$MANIFEST"
unset tab

if [ "$DRY_RUN" = true ]; then
  info "Dry run complete: $entries manifest entry(s) validated."
else
  info "Restored backup $STAMP ($entries manifest entry(s))."
  info "Managed files remain at: $ROOT"
fi
