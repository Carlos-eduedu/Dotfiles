# Dotfiles

Configurações pessoais modulares para macOS e zsh. Este diretório é uma cópia de trabalho local do repositório original; alterações não são enviadas ao remoto automaticamente.

## Estrutura

- `zsh/`: inicialização, aliases, funções e integrações opcionais.
- `tmux/`: configuração do tmux compatível com Ghostty.
- `ghostty/`: configuração e temas do Ghostty.
- `starship/`: prompt compacto alinhado à paleta do terminal.
- `nvim/`: configuração modular do Neovim baseada no LazyVim Starter.
- `git/`: configurações globais, ignore e template de commits do Git.
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

O instalador não usa `sudo` diretamente e move os arquivos anteriores para `~/.dotfiles-backups/TIMESTAMP/` antes de criar links. Execuções idempotentes não criam backups vazios. Para inspecionar todas as ações sem modificar arquivos nem instalar software:

```sh
./scripts/install.sh --restore --dry-run
```

## Reverter

Use o timestamp mostrado pelo instalador:

```sh
./scripts/rollback.sh TIMESTAMP
```

Valide primeiro sem alterar arquivos, se desejar:

```sh
./scripts/rollback.sh --dry-run TIMESTAMP
```

O rollback valida o manifesto inteiro antes de agir, só substitui links simbólicos e se recusa a sobrescrever arquivos ou diretórios comuns.

## Configuração local e segredos

Crie `~/.zshrc.local` para valores específicos desta máquina. Esse arquivo é carregado ao fim do zsh e nunca deve ser versionado:

```sh
export EXAMPLE_API_KEY='[REDACTED]'
```

Mantenha permissões restritas:

```sh
chmod 600 ~/.zshrc.local
```

A identidade Git também é local: o instalador cria `~/.config/git/config.local` com permissão `600`. Defina-a sem alterar os arquivos gerenciados:

```ini
[user]
    name = Seu Nome
    email = voce@example.com
# signingkey = ...  # opcional; não ative assinatura sem uma chave configurada
```

## Dependências

`Brewfile` declara: `bat`, `eza`, `fzf`, `gh`, `git`, `neovim`, `nvm`, `ripgrep`, `starship`, `tmux`, `uv`, `zoxide` e o cask Ghostty.

As integrações zsh continuam condicionais à presença das ferramentas. O NVM é carregado sob demanda no primeiro uso de `nvm`, `node`, `npm`, `npx` ou `corepack`; nenhuma versão de Node é presumida. Instale a versão desejada após o restore, por exemplo `nvm install --lts`.

`fzf` usa `ripgrep` como fonte de arquivos quando disponível e `bat` para previews. Dentro do tmux, `<C-h/j/k/l>` navega entre splits do Neovim e panes do tmux sem plugin adicional. Os mesmos atalhos navegam panes a partir do shell; use o prefixo seguido de `h/j/k/l` como alternativa explícita.

A configuração do Neovim usa o [LazyVim Starter](https://www.lazyvim.org/installation). Na primeira abertura, o `lazy.nvim` baixa o gerenciador e os plugins declarados pelo LazyVim. Execute `:LazyHealth` depois dessa primeira sincronização.

A configuração Git adota um subconjunto portátil do vídeo indicado: status detalhado, diffs compactos, rebase com autostash, push com upstream automático, ordenação de branches/tags, template de commits e `nvim` como editor. Ela não define nome, e-mail, URLs encurtadas, GPG ou um pager externo, pois esses itens são específicos da máquina ou exigem dependências adicionais.

Preferências locais estão em `nvim/lua/config/`; plugins e extras devem ser declarados explicitamente em `nvim/lua/plugins/`.

## Paleta visual

Ghostty, tmux, Starship, fzf e Neovim compartilham a paleta semântica Studio1804:

| Papel | Cor |
|---|---|
| Fundo | `#000000` |
| Superfície | `#1f2937` |
| Texto / secundário | `#ffffff` / `#9ca3af` |
| Destaque | `#f97316` |
| Sucesso / aviso / erro | `#22c55e` / `#eab308` / `#ef4444` |
| Informação / inativo | `#38bdf8` / `#374151` |

O mapeamento canônico está documentado em `ghostty/themes/studio1804-modern.conf`. As demais ferramentas repetem esses valores porque seus formatos não compartilham uma fonte de configuração. A configuração evita dependência de Nerd Fonts; símbolos usados possuem fallback Unicode comum.

## Atualizar

Revise alterações primeiro e faça commit/push apenas quando desejar:

```sh
git status
git diff
```
