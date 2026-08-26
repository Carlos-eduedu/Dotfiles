# Dotfiles

Configurações pessoais modulares para macOS e zsh. Este diretório é uma cópia de trabalho local do repositório original; alterações não são enviadas ao remoto automaticamente.

## Estrutura

- `zsh/`: inicialização, aliases, funções e integrações opcionais.
- `tmux/`: configuração do tmux compatível com Ghostty.
- `ghostty/`: configuração e temas do Ghostty.
- `nvim/`: configuração modular do Neovim baseada no LazyVim Starter.
- `scripts/install.sh`: cria links simbólicos e backups datados.
- `scripts/rollback.sh`: restaura um backup criado pelo instalador.

## Instalar

Somente links e backups, sem instalar software:

```sh
./scripts/install.sh
```

Para restaurar um Mac novo com Homebrew, dependências e plugins do tmux:

```sh
git clone https://github.com/Carlos-eduedu/Dotfiles.git ~/Developer/Dotfiles
cd ~/Developer/Dotfiles
./scripts/install.sh --restore
```

`--restore` pode baixar e executar o instalador oficial do Homebrew quando ele não existir, instalar o conteúdo do `Brewfile` e executar o instalador de plugins do TPM. São operações de rede e alteração do sistema feitas apenas por essa opção explícita.

Opções individuais:

```sh
./scripts/install.sh --bootstrap-homebrew
./scripts/install.sh --install-dependencies
./scripts/install.sh --install-tmux-plugins
```

O instalador não usa `sudo` diretamente e move os arquivos anteriores para `~/.dotfiles-backups/TIMESTAMP/` antes de criar links.

## Reverter

Use o timestamp mostrado pelo instalador:

```sh
./scripts/rollback.sh TIMESTAMP
```

O rollback só substitui links simbólicos; ele se recusa a sobrescrever arquivos ou diretórios comuns.

## Configuração local e segredos

Crie `~/.zshrc.local` para valores específicos desta máquina. Esse arquivo é carregado ao fim do zsh e nunca deve ser versionado:

```sh
export EXAMPLE_API_KEY='[REDACTED]'
```

Mantenha permissões restritas:

```sh
chmod 600 ~/.zshrc.local
```

## Dependências

`Brewfile` declara: `bat`, `eza`, `fzf`, `gh`, `git`, `neovim`, `nvm`, `ripgrep`, `starship`, `tmux`, `uv`, `zoxide` e o cask Ghostty.

As integrações zsh continuam condicionais à presença das ferramentas. O NVM é instalado, mas nenhuma versão de Node é presumida; instale a versão desejada após o restore, por exemplo `nvm install --lts`.

A configuração do Neovim usa o [LazyVim Starter](https://www.lazyvim.org/installation). Na primeira abertura, o `lazy.nvim` baixa o gerenciador e os plugins declarados pelo LazyVim. Execute `:LazyHealth` depois dessa primeira sincronização.

Preferências locais estão em `nvim/lua/config/`; plugins e extras devem ser declarados explicitamente em `nvim/lua/plugins/`.

## Atualizar

Revise alterações primeiro e faça commit/push apenas quando desejar:

```sh
git status
git diff
```
