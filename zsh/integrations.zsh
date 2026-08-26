# Shared, restrained UI for fzf. ANSI colors also work without a Nerd Font.
export FZF_DEFAULT_OPTS='--height=60% --layout=reverse --border=rounded --info=inline --prompt=›  --pointer=› --marker=✓ --color=bg+:#1f2937,bg:#000000,spinner:#f97316,hl:#fb923c,fg:#d1d5db,header:#9ca3af,info:#38bdf8,pointer:#f97316,marker:#22c55e,fg+:#ffffff,prompt:#f97316,hl+:#fb923c,border:#374151'
if command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
if command -v bat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers --line-range=:300 {}"'
fi

if [[ -t 0 && -o zle ]] && command -v fzf >/dev/null 2>&1; then
  fzf_prefix="${HOMEBREW_PREFIX:-}/opt/fzf"
  [[ -r "$fzf_prefix/shell/key-bindings.zsh" ]] && source "$fzf_prefix/shell/key-bindings.zsh"
  [[ -r "$fzf_prefix/shell/completion.zsh" ]] && source "$fzf_prefix/shell/completion.zsh"
  unset fzf_prefix
fi

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh --cmd cd)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Load NVM only when a Node command is first used. This preserves NVM's normal
# behavior while keeping its shell script off the startup path.
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
_NVM_LAZY_SCRIPT=
[[ -s "$NVM_DIR/nvm.sh" ]] && _NVM_LAZY_SCRIPT="$NVM_DIR/nvm.sh"
if [[ -z "$_NVM_LAZY_SCRIPT" && -n "${HOMEBREW_PREFIX:-}" && -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]]; then
  _NVM_LAZY_SCRIPT="$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
fi

if [[ -n "$_NVM_LAZY_SCRIPT" ]]; then
  _load_nvm() {
    unfunction nvm node npm npx corepack 2>/dev/null
    source "$_NVM_LAZY_SCRIPT"
  }
  nvm() { _load_nvm && nvm "$@"; }
  node() { _load_nvm && node "$@"; }
  npm() { _load_nvm && npm "$@"; }
  npx() { _load_nvm && npx "$@"; }
  corepack() { _load_nvm && corepack "$@"; }
fi
