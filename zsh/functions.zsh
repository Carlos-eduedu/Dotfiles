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
