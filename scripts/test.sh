#!/bin/sh
# Local, network-free regression tests for install and rollback workflows.
set -eu

SOURCE_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
WORK=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-test.XXXXXX")
trap 'rm -rf "$WORK"' EXIT HUP INT TERM

REPO="$WORK/repo with spaces"
mkdir -p "$REPO"
for item in Brewfile scripts zsh tmux ghostty nvim eza starship git; do
  cp -R "$SOURCE_ROOT/$item" "$REPO/"
done
INSTALL="$REPO/scripts/install.sh"
ROLLBACK="$REPO/scripts/rollback.sh"
PASSED=0

pass() {
  PASSED=$((PASSED + 1))
  printf '[PASS] %s\n' "$1"
}

fail() {
  printf '[FAIL] %s\n' "$1" >&2
  exit 1
}

backup_from_log() {
  awk -F'Backup: ' '/Backup: / { print $2 }' "$1"
}

sh -n "$INSTALL"
sh -n "$ROLLBACK"
zsh -n "$REPO/zsh/zshrc"
pass 'shell syntax'

# Restore dry-run must not create links, local config, backups, or downloads.
HOME_A="$WORK/home A with spaces"
BACKUPS_A="$WORK/backups A with spaces"
mkdir -p "$HOME_A"
HOME="$HOME_A" DOTFILES_BACKUP_ROOT="$BACKUPS_A" "$INSTALL" --restore --dry-run > "$WORK/a.log"
[ -z "$(find "$HOME_A" -mindepth 1 -print -quit)" ] || fail 'restore dry-run changed HOME'
[ ! -e "$BACKUPS_A" ] || fail 'restore dry-run created backup root'
pass 'side-effect-free restore dry-run'

# Fresh install, secure private config, idempotency, and rollback of new links.
HOME_B="$WORK/home B with spaces"
BACKUPS_B="$WORK/backups B with spaces"
mkdir -p "$HOME_B"
HOME="$HOME_B" DOTFILES_BACKUP_ROOT="$BACKUPS_B" "$INSTALL" > "$WORK/b1.log"
BACKUP_B=$(backup_from_log "$WORK/b1.log")
STAMP_B=${BACKUP_B##*/}
[ "$(find "$HOME_B" -type l | wc -l | tr -d ' ')" -eq 10 ] || fail 'fresh install did not create 10 links'
[ -f "$HOME_B/.config/git/config.local" ] || fail 'private Git config was not created'
MODE=$(stat -f '%Lp' "$HOME_B/.config/git/config.local" 2>/dev/null || stat -c '%a' "$HOME_B/.config/git/config.local")
[ "$MODE" = 600 ] || fail 'private Git config mode is not 600'
HOME="$HOME_B" DOTFILES_BACKUP_ROOT="$BACKUPS_B" "$INSTALL" > "$WORK/b2.log"
grep -q 'Already up to date' "$WORK/b2.log" || fail 'second install was not idempotent'
[ "$(find "$BACKUPS_B" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')" -eq 1 ] || fail 'idempotent install created another backup'
HOME="$HOME_B" DOTFILES_BACKUP_ROOT="$BACKUPS_B" "$ROLLBACK" --dry-run "$STAMP_B" > /dev/null
[ "$(find "$HOME_B" -type l | wc -l | tr -d ' ')" -eq 10 ] || fail 'rollback dry-run changed links'
HOME="$HOME_B" DOTFILES_BACKUP_ROOT="$BACKUPS_B" "$ROLLBACK" "$STAMP_B" > /dev/null
[ "$(find "$HOME_B" -type l | wc -l | tr -d ' ')" -eq 0 ] || fail 'rollback did not remove new links'
[ -f "$HOME_B/.config/git/config.local" ] || fail 'rollback removed private Git config'
pass 'install, permissions, idempotency, and rollback with spaces'

# An existing file must be restored byte-for-byte.
HOME_C="$WORK/home C with spaces"
BACKUPS_C="$WORK/backups C with spaces"
mkdir -p "$HOME_C"
printf 'original zsh\n' > "$HOME_C/.zshrc"
HOME="$HOME_C" DOTFILES_BACKUP_ROOT="$BACKUPS_C" "$INSTALL" > "$WORK/c.log"
BACKUP_C=$(backup_from_log "$WORK/c.log")
STAMP_C=${BACKUP_C##*/}
HOME="$HOME_C" DOTFILES_BACKUP_ROOT="$BACKUPS_C" "$ROLLBACK" "$STAMP_C" > /dev/null
[ "$(cat "$HOME_C/.zshrc")" = 'original zsh' ] || fail 'rollback did not restore existing file'
pass 'backup and restoration of an existing file'

# A dangling or non-regular private config must fail before any managed mutation.
HOME_D="$WORK/home D with spaces"
BACKUPS_D="$WORK/backups D with spaces"
VICTIM_D="$WORK/victim outside private config"
mkdir -p "$HOME_D/.config/git"
ln -s "$VICTIM_D" "$HOME_D/.config/git/config.local"
if HOME="$HOME_D" DOTFILES_BACKUP_ROOT="$BACKUPS_D" "$INSTALL" > "$WORK/d.out" 2> "$WORK/d.err"; then
  fail 'dangling private-config symlink was accepted'
fi
[ ! -e "$VICTIM_D" ] || fail 'dangling private-config target was created'
[ "$(find "$HOME_D" -type l | wc -l | tr -d ' ')" -eq 1 ] || fail 'managed links changed before private-config rejection'
grep -q 'Refusing symbolic link' "$WORK/d.err" || fail 'private-config rejection was not explained'
pass 'private Git config symlink rejection'

# Unsafe or incomplete manifests must fail preflight without removing links.
HOME_E="$WORK/home E with spaces"
BACKUPS_E="$WORK/backups E with spaces"
mkdir -p "$HOME_E"
printf 'saved content\n' > "$HOME_E/.zshrc"
HOME="$HOME_E" DOTFILES_BACKUP_ROOT="$BACKUPS_E" "$INSTALL" > "$WORK/e.log"
BACKUP_E=$(backup_from_log "$WORK/e.log")
STAMP_E=${BACKUP_E##*/}
cp "$BACKUP_E/manifest" "$WORK/e.manifest"
printf 'new\t../victim\t%s\n' "$REPO/zsh/zshrc" > "$BACKUP_E/manifest"
if HOME="$HOME_E" DOTFILES_BACKUP_ROOT="$BACKUPS_E" "$ROLLBACK" --dry-run "$STAMP_E" > /dev/null 2>&1; then
  fail 'unsafe manifest was accepted'
fi
[ -L "$HOME_E/.zshrc" ] || fail 'unsafe manifest changed managed link'
cp "$WORK/e.manifest" "$BACKUP_E/manifest"
rm "$BACKUP_E/.zshrc"
if HOME="$HOME_E" DOTFILES_BACKUP_ROOT="$BACKUPS_E" "$ROLLBACK" --dry-run "$STAMP_E" > /dev/null 2>&1; then
  fail 'manifest with missing backup was accepted'
fi
[ -L "$HOME_E/.zshrc" ] || fail 'missing backup changed managed link'
pass 'unsafe and incomplete manifest rejection'

# A post-link TPM failure must preserve the exit status and print recovery steps.
HOME_F="$WORK/home F with spaces"
BACKUPS_F="$WORK/backups F with spaces"
FAKEBIN_F="$WORK/fake bin"
mkdir -p "$HOME_F/.tmux/plugins/tpm" "$FAKEBIN_F"
printf '#!/bin/sh\nexit 42\n' > "$FAKEBIN_F/git"
chmod +x "$FAKEBIN_F/git"
set +e
PATH="$FAKEBIN_F:/usr/bin:/bin" HOME="$HOME_F" DOTFILES_BACKUP_ROOT="$BACKUPS_F" \
  "$INSTALL" --install-tmux-plugins > "$WORK/f.out" 2> "$WORK/f.err"
STATUS_F=$?
set -e
[ "$STATUS_F" -eq 42 ] || fail 'TPM failure status was not preserved'
[ "$(find "$HOME_F" -type l | wc -l | tr -d ' ')" -eq 10 ] || fail 'TPM failure scenario did not reach post-link state'
grep -q 'Failed to clone TPM' "$WORK/f.err" || fail 'TPM failure reason was not reported'
grep -q 'To undo: .*scripts/rollback.sh' "$WORK/f.err" || fail 'TPM rollback command was not reported'
pass 'TPM failure recovery guidance'

# A future completion-cache timestamp must trigger a safe refresh.
HOME_G="$WORK/home G with spaces"
CACHE_G="$WORK/cache G with spaces"
mkdir -p "$HOME_G"
HOME="$HOME_G" XDG_CACHE_HOME="$CACHE_G" zsh -dfc 'source "$1"' audit "$REPO/zsh/zshrc"
FUTURE_G=$(( $(date +%s) + 31536000 ))
printf '%s\n' "$FUTURE_G" > "$CACHE_G/zsh/.zcompdump.last-check"
HOME="$HOME_G" XDG_CACHE_HOME="$CACHE_G" zsh -dfc 'source "$1"' audit "$REPO/zsh/zshrc"
AFTER_G=$(cat "$CACHE_G/zsh/.zcompdump.last-check")
[ "$AFTER_G" -lt "$FUTURE_G" ] || fail 'future completion timestamp bypassed refresh'
pass 'future completion-cache timestamp recovery'

printf '%s\n' "All $PASSED regression groups passed."
