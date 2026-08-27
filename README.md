# Dotfiles

Configurações pessoais modulares para macOS e zsh. Este diretório é uma cópia de trabalho local do repositório original; alterações não são enviadas ao remoto automaticamente.

## Estrutura

- `zsh/`: inicialização, aliases, funções e integrações opcionais.
- `tmux/`: configuração do tmux compatível com Ghostty.
- `ghostty/`: configuração e temas do Ghostty.
- `eza/`: cores de arquivos e metadados alinhadas à paleta do terminal.
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

O instalador não usa `sudo` diretamente. Antes de qualquer operação externa ou alteração de link, ele valida todas as fontes e destinos locais para evitar instalações parciais por colisões previsíveis. Arquivos anteriores são movidos para `~/.dotfiles-backups/TIMESTAMP/`; a raiz, o backup e o manifesto usam permissões privadas. Execuções idempotentes não criam backups vazios. Se a etapa opcional do TPM falhar depois da criação dos links, o erro informa o backup e o comando exato de rollback. Para inspecionar todas as ações sem modificar arquivos nem instalar software:

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

O rollback valida o manifesto inteiro antes de agir, aceita manifestos antigos para os mesmos destinos gerenciados e só substitui links que ainda apontem para a fonte esperada deste repositório. Links alterados pelo usuário, arquivos comuns, diretórios, backups ausentes e caminhos não gerenciados são recusados.

## Configuração local e segredos

Crie `~/.zshrc.local` para valores específicos desta máquina. Esse arquivo é carregado ao fim do zsh e nunca deve ser versionado:

```sh
export EXAMPLE_API_KEY='[REDACTED]'
```

Mantenha permissões restritas:

```sh
chmod 600 ~/.zshrc.local
```

A identidade Git também é local: o instalador cria `~/.config/git/config.local` com permissão `600`. Por segurança, ele recusa symlinks e objetos que não sejam arquivos regulares nesse caminho. Defina a identidade sem alterar os arquivos gerenciados:

```ini
[user]
    name = Seu Nome
    email = voce@example.com
# signingkey = ...  # opcional; não ative assinatura sem uma chave configurada
```

## Dependências

`Brewfile` declara: `bat`, `eza`, `fzf`, `gh`, `git`, `neovim`, `nvm`, `ripgrep`, `starship`, `tree-sitter-cli`, `tmux`, `uv`, `zoxide` e os casks Ghostty e DuckDuckGo. O CLI do `tree-sitter` é necessário para instalar ou atualizar parsers nas versões atuais do `nvim-treesitter`; a fórmula `tree-sitter` fornece somente a biblioteca.

As integrações zsh continuam condicionais à presença das ferramentas. O NVM é carregado sob demanda no primeiro uso de `nvm`, `node`, `npm`, `npx` ou `corepack`; nenhuma versão de Node é presumida. Instale a versão desejada após o restore, por exemplo `nvm install --lts`.

`fzf` usa `ripgrep` como fonte de arquivos quando disponível e `bat` para previews. O completion do Zsh agrupa e descreve resultados, prioriza correspondências rápidas e só tenta correção aproximada de um caractere como fallback. Após instalar uma ferramenta com novas completions, force uma atualização com `completion-rebuild`.

Dentro do tmux, `<C-h/j/k/l>` navega entre splits do Neovim e panes do tmux sem plugin adicional. Os mesmos atalhos navegam panes a partir do shell; use o prefixo seguido de `h/j/k/l` como alternativa explícita. O Ghostty permite escrita no clipboard, mas pede confirmação antes de responder a leituras solicitadas por aplicações. TPM não baixa plugins ao carregar o tmux: `tmux-sensible`, `tmux-resurrect` e `tmux-continuum` só são instalados pela opção explícita `--install-tmux-plugins`. Depois de instalado, o Continuum restaura sessões automaticamente conforme declarado em `tmux/tmux.conf`.

A configuração do Neovim usa o [LazyVim Starter](https://www.lazyvim.org/installation). Na primeira abertura, o `lazy.nvim` baixa o gerenciador e os plugins declarados pelo LazyVim. Execute `:LazyHealth` depois dessa primeira sincronização. O checker periódico fica desativado para evitar rede implícita; use `:Lazy check` quando quiser procurar atualizações.

A configuração Git adota defaults portáteis: status de branch e stash, diffs compactos com detecção de renomes, rebase com autostash, push com upstream automático, ordenação de branches/tags, template de commits e `nvim` como editor. Status de arquivos não rastreados e compressão usam os defaults do Git para evitar custo desproporcional em repositórios grandes. Ela não define nome, e-mail, URLs encurtadas, GPG ou um pager externo, pois esses itens são específicos da máquina ou exigem dependências adicionais.

Preferências locais estão em `nvim/lua/config/`; plugins e extras devem ser declarados explicitamente em `nvim/lua/plugins/`.

## Paleta visual

Ghostty, tmux, eza, Starship, fzf e Neovim compartilham a paleta semântica Studio1804:

| Papel | Cor |
|---|---|
| Fundo | `#000000` |
| Superfície | `#1f2937` |
| Texto / secundário | `#ffffff` / `#9ca3af` |
| Destaque | `#f97316` |
| Sucesso / aviso / erro | `#22c55e` / `#eab308` / `#ef4444` |
| Informação / inativo | `#38bdf8` / `#374151` |

O mapeamento canônico está documentado em `ghostty/themes/studio1804-modern.conf`. As demais ferramentas repetem esses valores porque seus formatos não compartilham uma fonte de configuração. Para usar a alternativa estritamente monocromática, altere `theme` em `ghostty/config` para `studio1804-monochrome.conf`; as outras ferramentas continuam com a paleta semântica moderna. O tema do eza fica em `eza/theme.yml`; `EZA_CONFIG_DIR` garante que ele seja encontrado também no macOS. Variáveis locais `EZA_COLORS` ou `LS_COLORS` podem sobrescrever partes do tema. A configuração evita dependência de Nerd Fonts; símbolos usados possuem fallback Unicode comum.

No macOS, arquivos em `~/Library/Application Support/com.mitchellh.ghostty/` são carregados depois da configuração XDG e podem sobrescrevê-la. Use `ghostty +show-config` para inspecionar os valores efetivos.

## Testes locais

A suíte não acessa a rede e usa apenas cópias do repositório, HOME e backups temporários:

```sh
./scripts/test.sh
```

## Atualizar

Revise alterações primeiro e faça commit/push apenas quando desejar:

```sh
git status
git diff
```
