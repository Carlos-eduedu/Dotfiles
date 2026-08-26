if [[ -t 0 && -o zle ]] && command -v fzf >/dev/null 2>&1 && command -v brew >/dev/null 2>&1; then
  fzf_prefix="$(brew --prefix fzf 2>/dev/null)"
  [[ -r "$fzf_prefix/shell/key-bindings.zsh" ]] && source "$fzf_prefix/shell/key-bindings.zsh"
  [[ -r "$fzf_prefix/shell/completion.zsh" ]] && source "$fzf_prefix/shell/completion.zsh"
  unset fzf_prefix
fi

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh --cmd cd)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Homebrew's nvm formula stores nvm.sh outside NVM_DIR; NVM_DIR holds versions.
export NVM_DIR="$HOME/.nvm"
if command -v brew >/dev/null 2>&1; then
  nvm_prefix="$(brew --prefix nvm 2>/dev/null)"
  [[ -s "$nvm_prefix/nvm.sh" ]] && source "$nvm_prefix/nvm.sh"
  unset nvm_prefix
fi
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
