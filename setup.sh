#!/usr/bin/env bash
set -euo pipefail
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  Darwin) exec "$DOTFILES_DIR/os-macos/setup.sh" "$@" ;;
  Linux)  echo "O suporte a Linux ainda não foi configurado." >&2; exit 1 ;;
  *)      echo "Sistema operacional não suportado." >&2; exit 1 ;;
esac
