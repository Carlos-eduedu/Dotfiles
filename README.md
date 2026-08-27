# Dotfiles macOS

Configurações pessoais gerenciadas por [GNU Stow](https://www.gnu.org/software/stow/) com links de arquivo (`--no-folding`). Cada diretório de primeiro nível é um pacote Stow que espelha `$HOME`; `os-macos/` contém arquivos específicos do macOS e não é stowado.

## Pacotes

- `shell/`: `~/.zshrc.shared` e módulos em `~/.zsh/`.
- `tmux/`, `ghostty/`, `eza/`, `starship/`, `git/`, `nvim/`: configurações em `$HOME` ou `~/.config`.
- `os-macos/Brewfile`: dependências Homebrew.

`~/.zshrc` é um bootstrap local: carrega `~/.zshrc.shared` e, se existir, `~/.zshrc.local`. A identidade do Git fica em `~/.config/git/config.local`. Arquivos `*.local` não são versionados.

## Aplicar

```sh
./setup.sh        # Brewfile e todos os pacotes Stow
./setup.sh brew   # somente dependências
./setup.sh stow   # somente links
```

O instalador preserva arquivos comuns conflitantes em `~/.dotfiles-backup/<timestamp>/`; links antigos são substituídos. Antes de versionar mudanças, execute uma varredura de segredos.
