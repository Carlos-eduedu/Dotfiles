# Neovim

Configuração baseada no [LazyVim Starter](https://www.lazyvim.org/installation), com tema Studio1804 e navegação integrada ao tmux.

Na primeira execução, `lazy.nvim` e os plugins do lockfile podem ser baixados. O `tree-sitter` CLI declarado no `Brewfile` é necessário para instalar ou atualizar parsers do `nvim-treesitter`. Depois do bootstrap, verificações de atualização são manuais para evitar operações de rede implícitas:

```vim
:Lazy check
:LazyHealth
```

Os atalhos `<C-h/j/k/l>` atravessam splits e panes do tmux; `<C-s>` salva o buffer. Preferências ficam em `lua/config/` e plugins ou overrides em `lua/plugins/`.
