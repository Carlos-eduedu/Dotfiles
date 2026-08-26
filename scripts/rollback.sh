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
while IFS="$tab" read -r state relative; do
  [ -n "$state" ] || continue
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
  case "$seen" in
    *"|$relative|"*) printf 'Duplicate path in backup manifest: %s\n' "$relative" >&2; exit 1 ;;
  esac
  seen="$seen$relative|"

  target="$HOME/$relative"
  [ -L "$target" ] || { printf 'Refusing to replace non-link target: %s\n' "$target" >&2; exit 1; }
  if [ "$state" = existing ]; then
    saved="$BACKUP/$relative"
    [ -e "$saved" ] || [ -L "$saved" ] || { printf 'Missing backup: %s\n' "$saved" >&2; exit 1; }
  fi
  entries=$((entries + 1))
done < "$MANIFEST"

while IFS="$tab" read -r state relative; do
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
