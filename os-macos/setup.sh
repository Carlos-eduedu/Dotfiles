#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_ROOT="${DOTFILES_BACKUP_ROOT:-$HOME/.dotfiles-backup}"
PACKAGES=(shell tmux ghostty eza starship git nvim)
MODE="${1:-all}"
BACKUP_DIR=""

usage() {
  cat <<'EOF'
Uso: ./setup.sh [brew|stow]

Sem argumento, instala dependências do Brewfile e aplica todos os pacotes Stow.
  brew  Instala o conteúdo de os-macos/Brewfile.
  stow  Cria links de arquivo com GNU Stow (--no-folding).
EOF
}

prepare_backup() {
  [[ -n "$BACKUP_DIR" ]] && return
  BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BACKUP_DIR"
  chmod 700 "$BACKUP_ROOT" "$BACKUP_DIR"
}

backup_target() {
  local target="$1" source="${2:-}" relative
  [[ -e "$target" || -L "$target" ]] || return
  if [[ -L "$target" ]]; then
    [[ -n "$source" && "$(readlink "$target")" == "$source" ]] && return
    rm "$target"
    return
  fi
  prepare_backup
  relative="${target#$HOME/}"
  mkdir -p "$BACKUP_DIR/$(dirname "$relative")"
  mv "$target" "$BACKUP_DIR/$relative"
  printf 'Backup: %s → %s\n' "$target" "$BACKUP_DIR/$relative"
}

ensure_zsh_bootstrap() {
  local bootstrap
  bootstrap=$'# Bootstrap local: a configuração compartilhada é gerenciada por GNU Stow.\n[[ -r "$HOME/.zshrc.shared" ]] && source "$HOME/.zshrc.shared"\n[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"\n'
  if [[ -f "$HOME/.zshrc" ]] && cmp -s <(printf '%s' "$bootstrap") "$HOME/.zshrc"; then
    return
  fi
  backup_target "$HOME/.zshrc"
  printf '%s' "$bootstrap" > "$HOME/.zshrc"
}

apply_stow() {
  command -v stow >/dev/null || { echo "GNU Stow não está instalado. Execute ./setup.sh brew." >&2; exit 1; }
  mkdir -p "$HOME/.config"
  ensure_zsh_bootstrap

  # Remove links legados de diretórios; diretórios reais são preservados para
  # que --no-folding possa criar links de arquivos dentro deles.
  for target in "$HOME/.zsh" "$HOME/.config/ghostty/themes" "$HOME/.config/nvim"; do
    [[ -L "$target" ]] && backup_target "$target"
  done
  backup_target "$HOME/.tmux.conf" "$DOTFILES_DIR/tmux/.tmux.conf"
  backup_target "$HOME/.config/ghostty/config" "$DOTFILES_DIR/ghostty/.config/ghostty/config"
  backup_target "$HOME/.config/eza/theme.yml" "$DOTFILES_DIR/eza/.config/eza/theme.yml"
  backup_target "$HOME/.config/starship.toml" "$DOTFILES_DIR/starship/.config/starship.toml"
  backup_target "$HOME/.config/git/config" "$DOTFILES_DIR/git/.config/git/config"
  backup_target "$HOME/.config/git/ignore" "$DOTFILES_DIR/git/.config/git/ignore"
  backup_target "$HOME/.config/git/commit-template" "$DOTFILES_DIR/git/.config/git/commit-template"

  for package in "${PACKAGES[@]}"; do
    stow --no-folding -d "$DOTFILES_DIR" -t "$HOME" "$package"
  done
  echo "Pacotes aplicados: ${PACKAGES[*]}"
  [[ -z "$BACKUP_DIR" ]] || echo "Backup: $BACKUP_DIR"
}

case "$MODE" in
  all)
    brew bundle install --file "$DOTFILES_DIR/os-macos/Brewfile" --no-lock || echo "Aviso: houve falhas no Brew Bundle; continuando."
    apply_stow
    ;;
  brew) brew bundle install --file "$DOTFILES_DIR/os-macos/Brewfile" --no-lock ;;
  stow) apply_stow ;;
  -h|--help) usage ;;
  *) usage >&2; exit 2 ;;
esac
