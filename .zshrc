# ~/.zshrc
# Shell interativo: rápido, previsível e com poucas dependências no caminho crítico.

# PATH -----------------------------------------------------------------------
typeset -U path PATH
path=(
  "$HOME/.opencode/bin"
  /opt/homebrew/bin
  /opt/homebrew/sbin
  "$HOME/.local/bin"
  "$HOME/bin"
  $path
)
export PATH

# Ambiente -------------------------------------------------------------------
export LANG="${LANG:-en_US.UTF-8}"
export EDITOR="${EDITOR:-vim}"
export VISUAL="$EDITOR"
export HOMEBREW_NO_ENV_HINTS=1

# Histórico ------------------------------------------------------------------
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=20000
export SAVEHIST=20000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# Comportamento --------------------------------------------------------------
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt PUSHD_IGNORE_DUPS

# Teclas ---------------------------------------------------------------------
bindkey -v
export KEYTIMEOUT=1

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[f' forward-word
bindkey '^[b' backward-word

# Completion -----------------------------------------------------------------
autoload -Uz compinit
_compdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump"
[[ -d "${_compdump:h}" ]] || mkdir -p "${_compdump:h}"
compinit -d "$_compdump"
unset _compdump

zstyle ':completion:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*' format '%F{#f97316}%d%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-prompt '%F{#6b7280}%S%p%s%f'
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'
zstyle ':completion:*' max-errors 2 numeric
zstyle ':completion:*' select-prompt '%F{#6b7280}%SScrolling: current selection at %p%s%f'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands
zstyle ':completion:*:descriptions' format '%F{#f97316}%d%f'
zstyle ':completion:*:messages' format '%F{#9ca3af}%d%f'
zstyle ':completion:*:warnings' format '%F{#ef4444}no matches%f'
zstyle ':completion:*:corrections' format '%F{#fb923c}%d (errors: %e)%f'

[[ -n "${LS_COLORS:-}" ]] && zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

if command -v mole >/dev/null 2>&1; then
  eval "$(mole completion zsh 2>/dev/null)"
fi

has-zsh-completion() {
  local dir
  for dir in $fpath; do
    [[ -r "$dir/$1" ]] && return 0
  done
  return 1
}

if (( $+functions[compdef] )) && command -v uv >/dev/null 2>&1; then
  if has-zsh-completion _uv; then
    autoload -Uz _uv
    compdef _uv uv
  else
    eval "$(uv generate-shell-completion zsh)"
  fi
fi

if (( $+functions[compdef] )) && command -v uvx >/dev/null 2>&1; then
  if has-zsh-completion _uvx; then
    autoload -Uz _uvx
    compdef _uvx uvx
  else
    eval "$(uvx --generate-shell-completion zsh)"
  fi
fi
unset -f has-zsh-completion

# Sugestões de comandos ------------------------------------------------------
# Usa histórico primeiro e completion depois; visual discreto no tema Modern.
typeset -ga ZSH_AUTOSUGGEST_STRATEGY
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=30
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6b7280'

# Plugins leves --------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ -o zle && -f "$ZINIT_HOME/zinit.zsh" ]]; then
  source "$ZINIT_HOME/zinit.zsh"

  zinit ice wait"0" lucid atload'_zsh_autosuggest_start'
  zinit light zsh-users/zsh-autosuggestions

  zinit ice wait"0" lucid
  zinit light zdharma-continuum/fast-syntax-highlighting

  zinit ice wait"0" lucid blockf atpull'zinit creinstall -q .'
  zinit light zsh-users/zsh-completions
fi
unset ZINIT_HOME

# Ferramentas opcionais ------------------------------------------------------
if [[ -t 0 && -o zle && -x /opt/homebrew/bin/fzf ]]; then
  [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]] && source /opt/homebrew/opt/fzf/shell/completion.zsh
fi

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh --cmd cd)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# nvm sob demanda: preserva Node sem atrasar todo terminal novo.
export NVM_DIR="$HOME/.nvm"
load-nvm() {
  unset -f nvm node npm npx yarn pnpm
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
}
nvm() { load-nvm; nvm "$@"; }
node() { load-nvm; node "$@"; }
npm() { load-nvm; npm "$@"; }
npx() { load-nvm; npx "$@"; }
yarn() { load-nvm; yarn "$@"; }
pnpm() { load-nvm; pnpm "$@"; }

# Aliases --------------------------------------------------------------------
alias c='clear'
alias e='$EDITOR'
alias v='$EDITOR'
alias reload='exec zsh'

alias g='git'
alias ga='git add'
alias gap='git add -p'
alias gb='git branch'
alias gc='git commit'
alias gca='git commit -a'
alias gcam='git commit -am'
alias gco='git checkout'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate --all'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gs='git status -sb'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias l='eza --group-directories-first'
  alias la='eza -a --group-directories-first'
  alias ll='eza -lh --group-directories-first'
  alias lla='eza -lah --group-directories-first'
else
  alias l='ls -CF'
  alias la='ls -A'
  alias ll='ls -lh'
  alias lla='ls -lah'
fi

command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'

# Funções --------------------------------------------------------------------
mkcd() {
  [[ -n "$1" ]] || return 1
  mkdir -p -- "$1" && builtin cd -- "$1"
}

fh() {
  command -v fzf >/dev/null 2>&1 || return 1
  local selected
  selected="$(fc -rl 1 | fzf --height 40% --reverse --border | sed 's/^[ ]*[0-9]\+[ ]*//')"
  [[ -n "$selected" ]] && print -z -- "$selected"
}

fe() {
  command -v fzf >/dev/null 2>&1 || return 1
  local file
  file="$(fzf)"
  [[ -n "$file" ]] && "$EDITOR" "$file"
}
