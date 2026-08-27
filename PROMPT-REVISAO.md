# Prompt para revisão completa dos dotfiles

```text
Atue como engenheiro sênior especializado em macOS, dotfiles, Zsh, ferramentas CLI, terminal, segurança e performance. Trabalhe de modo deliberado: use as Skills instaladas quando forem pertinentes, avalie criticamente o próprio processo e incorpore melhorias comprovadas nas próximas etapas da revisão.

Faça uma revisão completa do repositório atual de dotfiles. Considere, no mínimo:

- Zsh, aliases, funções, completion e integrações.
- Ghostty e seus temas.
- tmux, atalhos, clipboard, terminal e plugins TPM.
- Neovim/LazyVim, plugins, opções, keymaps e tempo de inicialização.
- Git, ignore global e template de commits.
- Starship, fzf, eza, bat, ripgrep, zoxide e NVM.
- Brewfile e dependências declaradas.
- Scripts de instalação, restore, backup, dry-run e rollback.
- README e demais documentos operacionais.

## Objetivos

Identifique problemas e proponha melhorias nas seguintes áreas:

1. Correção e segurança.
2. Performance mensurável.
3. Integração entre ferramentas.
4. Usabilidade e facilidade de descoberta.
5. Consistência visual com a paleta Studio1804.
6. Portabilidade e compatibilidade com macOS Intel e Apple Silicon.
7. Idempotência, manutenção e documentação.

Não adicione configurações apenas por preferência pessoal. Toda recomendação deve apresentar evidência observável, benefício objetivo e forma de validação.

## Skills e autoaprimoramento contínuo

Antes de cada etapa relevante, identifique se existe uma Skill local adequada e leia integralmente seu `SKILL.md`, seguindo as instruções aplicáveis. Para este repositório, priorize:

- `dotfiles-mac` para estrutura, instalação e restauração de dotfiles no macOS.
- `shell-env` para Zsh, aliases, funções, terminal e integrações de shell.
- `tmux` para configuração e testes isolados do tmux.
- `ghostty-config` para opções, temas, atalhos e validação do Ghostty.
- `neovim` para LazyVim, plugins, keymaps e saúde do Neovim.

Use uma Skill apenas quando seu escopo for realmente aplicável; a Skill complementa, mas não substitui, a inspeção direta dos arquivos e as evidências. Se houver lacuna de conhecimento ou de fluxo, registre-a e use `find-skills` para procurar uma Skill adequada **somente após autorização explícita para acesso à rede e instalação**.

Durante o trabalho, mantenha um ciclo de melhoria:

1. Declare a hipótese, o método e a limitação antes de uma análise ou teste importante.
2. Após cada resultado, verifique se a evidência sustenta a conclusão e corrija o plano, a classificação ou o método quando necessário.
3. Reutilize aprendizados confirmados nas etapas seguintes, sem transformar suposições em regras permanentes.
4. Ao finalizar, faça uma retrospectiva objetiva: quais Skills e métodos ajudaram, quais lacunas permaneceram e qual melhoria concreta deve orientar a próxima revisão.

## Restrições

- Investigue todo o repositório antes de editar qualquer arquivo.
- Leia integralmente os arquivos relevantes e mapeie suas dependências.
- Preserve segredos, identidade Git, arquivos locais e dados do usuário.
- Não execute instalações, downloads, operações de rede, commits, pushes ou comandos destrutivos sem autorização explícita.
- Não altere configurações externas ao repositório.
- Teste scripts somente em HOME, diretórios e sockets temporários.
- Não abra ou reutilize sessões tmux reais durante testes.
- Não carregue `~/.zshrc.local` durante benchmarks isolados.
- Não inicialize plugins ou gerenciadores de pacotes de forma que possam baixar conteúdo.
- Mantenha integrações opcionais condicionais à existência dos comandos.
- Evite novas dependências e preserve funcionamento em instalações parciais.
- Não declare sucesso enquanto houver testes relevantes falhando.
- Não faça commit; apresente o diff para revisão.

## Processo obrigatório

### 1. Estado inicial e preparação orientada por Skills

Antes da análise:

- Liste as Skills locais disponíveis e associe cada área da auditoria à Skill aplicável.
- Leia os `SKILL.md` relevantes integralmente antes de usar uma Skill e registre quais instruções específicas serão seguidas.
- Registre `git status --short`.
- Diferencie alterações preexistentes das alterações feitas durante a tarefa.
- Liste arquivos, diretórios e links simbólicos do repositório.
- Identifique quais destinos gerenciados já estão ligados ao repositório.
- Registre versões e disponibilidade das ferramentas sem instalar nada.

### 2. Inventário e relações

Produza um inventário contendo:

- Ferramentas e responsabilidades.
- Dependências obrigatórias e opcionais.
- Variáveis de ambiente.
- Arquivos instalados e respectivos destinos.
- Fluxos de bootstrap, instalação, backup e rollback.
- Atalhos e funções disponíveis.
- Pontos de integração entre Ghostty, tmux, Zsh, Neovim, Git e clipboard.
- Cores e papéis semânticos compartilhados.
- Configurações duplicadas, contraditórias, obsoletas ou não utilizadas.

### 3. Auditoria técnica

Revise especialmente:

#### Zsh

- Tempo de inicialização frio e quente.
- Processos externos executados no startup.
- Segurança e cache do `compinit`.
- Completion, matcher-list e correção aproximada.
- Lazy loading do NVM.
- Inicialização de Starship, fzf e zoxide.
- Ordem e duplicação de PATH, FPATH, MANPATH e INFOPATH.
- Aliases que alteram comandos fundamentais.
- Funções com problemas de quoting, globbing ou nomes contendo espaços.
- Códigos de saída ao carregar a configuração.

#### Ghostty e tmux

- True color, terminfo, CSI-u e extended keys.
- Escape time, passthrough, foco e responsividade.
- Clipboard do macOS e OSC 52.
- Conflitos de atalhos com Neovim e aplicações TUI.
- Navegação entre splits e panes.
- Segurança ao fechar sessões e superfícies.
- TPM, plugins ausentes e operações automáticas.
- Status bar, mensagens e excesso de informação permanente.

#### Neovim

- Startup headless e plugins carregados cedo.
- Plugins redundantes ou configurações mortas.
- Lazy loading, checker automático e operações de rede implícitas.
- Integração com Git, clipboard, tmux e terminal.
- Keymaps conflitantes.
- True color, bordas, highlights e statusline.
- Integridade de `lazy-lock.json`.

#### CLI e tema

- Consistência entre Ghostty, tmux, Starship, fzf, eza e Neovim.
- Uso coerente de fundo, superfície, texto, muted, accent, success, warning, error, info e inactive.
- Contraste, legibilidade e excesso de negrito, sublinhado ou cor.
- Sobrescritas causadas por `EZA_COLORS`, `LS_COLORS`, `BAT_THEME` ou variáveis locais.
- Funcionamento sem Nerd Fonts quando viável.

#### Git e scripts

- Validade e portabilidade das opções Git.
- Possíveis custos em repositórios grandes.
- Validação de argumentos e códigos de saída.
- Quoting e segurança de caminhos.
- Path traversal e validação de manifestos.
- Preflight antes de alterações.
- Idempotência e colisões de backup.
- Dry-run realmente livre de efeitos colaterais.
- Rollback previsível diante de arquivos ausentes ou modificados.
- Separação entre links locais, instalações e operações de rede.

### 4. Classificação dos achados

Para cada achado, informe:

- Categoria: problema confirmado, melhoria provável, hipótese de benchmark ou preferência estética.
- Evidência exata, incluindo arquivo e linha quando possível.
- Impacto: alto, médio ou baixo.
- Esforço: alto, médio ou baixo.
- Risco: alto, médio ou baixo.
- Solução recomendada.
- Arquivos afetados.
- Teste necessário para validar.

Não trate uma hipótese como problema confirmado.

### 5. Plano antes da implementação

Monte um plano incremental nesta ordem:

1. Segurança e correções funcionais.
2. Regressões e inconsistências.
3. Performance comprovada.
4. Integrações que removem etapas manuais.
5. Consistência visual.
6. Refatorações e documentação.

Antes de editar, apresente o inventário, os achados e o plano. Solicite aprovação para mudanças de comportamento, novos atalhos, novas dependências ou alterações visuais amplas.

### 6. Implementação aprovada

Após aprovação:

- Faça alterações pequenas e relacionadas.
- Preserve o comportamento existente quando não houver motivo objetivo para mudá-lo.
- Evite reescrever arquivos inteiros sem necessidade.
- Comente apenas decisões não óbvias.
- Atualize o README quando o uso ou comportamento mudar.
- Não altere lockfiles sem necessidade.
- Não inclua arquivos preexistentes não relacionados no diff.

### 7. Validação e revisão do método

Execute apenas testes locais e não destrutivos disponíveis, incluindo quando aplicável:

- `sh -n` e `zsh -n`.
- ShellCheck, shfmt ou Stylua somente se já instalados.
- Install, dry-run, idempotência e rollback em HOME temporário.
- Testes com caminhos contendo espaços.
- Rollback com manifesto inválido ou backup ausente.
- Startup isolado do Zsh, com várias amostras e mediana.
- Ghostty `+validate-config`.
- tmux com HOME e socket isolados.
- Neovim headless e `--startuptime` sem sincronizar plugins.
- Parsing da configuração Git.
- Parsing do TOML do Starship e YAML do eza.
- Execução do eza com `EZA_CONFIG_DIR` temporário, se já estiver instalado.
- `git diff --check`, inspeção do diff e varredura por segredos.

Compare benchmarks antes e depois usando o mesmo método. Informe limitações e variabilidade das medições.

Antes de concluir, faça uma revisão adversarial do próprio trabalho: confirme que as Skills foram usadas dentro do escopo, que nenhuma conclusão excede as evidências, que os testes cobrem as alterações e que o plano foi atualizado com os aprendizados obtidos.

## Formato da resposta final

Apresente:

1. Resumo executivo.
2. Estado inicial e alterações preexistentes.
3. Inventário de ferramentas e integrações.
4. Problemas confirmados.
5. Melhorias prováveis e hipóteses.
6. Plano aprovado e escopo implementado.
7. Alterações realizadas por arquivo.
8. Benchmarks antes e depois.
9. Testes executados e resultados.
10. Riscos, limitações e itens adiados.
11. Diff/status final.
12. Próximos passos recomendados.
13. Skills usadas, instruções relevantes aplicadas e lacunas identificadas.
14. Retrospectiva de autoaprimoramento: ajustes de método, aprendizados confirmados e melhoria recomendada para a próxima revisão.

Se nenhuma mudança for necessária, diga isso claramente. O objetivo é manter um ambiente rápido, seguro, integrado, minimalista e fácil de restaurar — não maximizar a quantidade de configuração.
```
