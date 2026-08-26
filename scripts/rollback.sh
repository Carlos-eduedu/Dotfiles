#!/bin/sh
# Restore a backup created by install.sh. Refuses to replace non-symlink targets.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BACKUP_ROOT=${DOTFILES_BACKUP_ROOT:-"$HOME/.dotfiles-backups"}
STAMP=${1:?Usage: rollback.sh TIMESTAMP}
BACKUP="$BACKUP_ROOT/$STAMP"
MANIFEST="$BACKUP/manifest"

[ -r "$MANIFEST" ] || { printf 'Backup manifest not found: %s\n' "$MANIFEST" >&2; exit 1; }

tab=$(printf '\t')
while IFS="$tab" read -r state relative; do
  [ -n "$state" ] || continue
  # Manifests created before the typed format contain only the relative path.
  if [ -z "$relative" ]; then
    relative=$state
    state=existing
  fi
  target="$HOME/$relative"
  [ -L "$target" ] || { printf 'Refusing to replace non-link target: %s\n' "$target" >&2; exit 1; }
  rm "$target"
  if [ "$state" = new ]; then
    continue
  fi
  saved="$BACKUP/$relative"
  [ -e "$saved" ] || [ -L "$saved" ] || { printf 'Missing backup: %s\n' "$saved" >&2; exit 1; }
  mkdir -p "$(dirname "$target")"
  mv "$saved" "$target"
done < "$MANIFEST"
unset tab

printf 'Restored backup: %s\n' "$BACKUP"
printf 'Managed files remain at: %s\n' "$ROOT"
