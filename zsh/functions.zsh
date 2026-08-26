mkcd() {
  [[ -n "$1" ]] || return 1
  mkdir -p -- "$1" && builtin cd -- "$1"
}

fh() {
  command -v fzf >/dev/null 2>&1 || return 1
  local selected
  selected="$(fc -rl 1 | fzf --no-sort | sed 's/^[ ]*[0-9]\+[ ]*//')"
  [[ -n "$selected" ]] && print -z -- "$selected"
}

fe() {
  command -v fzf >/dev/null 2>&1 || return 1
  local file
  local -a preview
  command -v bat >/dev/null 2>&1 && preview=(--preview 'bat --color=always --style=numbers --line-range=:300 {}')
  file="$(fzf "${preview[@]}")"
  [[ -n "$file" ]] && "$EDITOR" -- "$file"
}
