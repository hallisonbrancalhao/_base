# AI Context Base

Template de Nx Workspace pré-configurado para desenvolvimento assistido por IA.

Clone, escolha seu framework, e tenha tudo pronto para usar com Claude Code ou qualquer outro agente.

---

## O que está incluso

### Nx Workspace

Arquitetura de libs documentada com:
- Regras de dependência entre libs
- Module boundaries com tags
- Padrões de código (Clean Architecture, Facade Pattern)

### MCPs Pré-configurados

| MCP | Propósito |
|-----|-----------|
| `nx-mcp` | Entende o workspace Nx |
| `context7` | Docs atualizadas de qualquer lib |
| `chrome-devtools` | Testes E2E direto no browser |
| `figma` | Contexto do design |
| `linear` | Integração com tasks |
| `firecrawl` | Web scraping |
| `angular-cli` | Operações Angular CLI |
| `primeng` | Docs PrimeNG |

### Commands Customizados

| Command | Propósito |
|---------|-----------|
| `/plan` | Planeja feature com sub-agentes |
| `/task` | Implementa seguindo padrões |
| `/review` | Code review automatizado |
| `/validate` | Roda lint, test, build |
| `/commit` | Gera commit convencional |
| `/debug` | Investigação de bugs |
| `/e2e` | Testes E2E |
| `/pr` | Cria/revisa PRs |
| `/affected` | Análise de impacto |

### Hooks Automatizados

| Hook | Função |
|------|--------|
| `UserPromptSubmit` | Injeta regras de arquitetura quando detecta implementação |
| `PreToolUse` (Bash) | Valida lint/test/build antes de commits |
| `PostToolUse` (ExitPlanMode) | Cria PRD automaticamente após aprovação |
| `PostToolUse` (Write/Edit) | Auto-formata arquivos TS/HTML |
| `SessionStart` | Carrega git log e arquivos alterados |
| `Setup` | Executa `pnpm install` no --init |

### Estrutura .agent/

```
.agent/
├── Agents/      → 15+ sub-agentes especializados
│   ├── @coder, @test-writer, @docs-writer
│   ├── @debugger, @explorer
│   ├── @qa-runner, @arch-validator, @code-reviewer
│   └── @ux-researcher, @ui-designer
├── System/      → Padrões técnicos
├── SOPs/        → Procedimentos
├── Tasks/       → PRDs
└── Plans/       → Planos em andamento
```

---

## Quick Start

### Novo Projeto

```bash
# Clone o repositório
git clone https://github.com/halissonbrancalhao/ai-context-base.git meu-projeto
cd meu-projeto

# Remove o git history
rm -rf .git
git init

# Instala dependências
pnpm install

# Configura para seu stack
# Edite .agent/README.md e .mcp.json
```

### Projeto Existente

```bash
# Sincroniza a estrutura de contextos
./scripts/sync-context.sh ~/projects/meu-projeto

# Ou com preview
./scripts/sync-context.sh ~/projects/meu-projeto --dry-run
```

---

## Scripts

### sync-context.sh

Sincroniza a estrutura de contextos para um projeto existente.

```bash
# Básico - sincroniza tudo
./scripts/sync-context.sh ~/projects/meu-projeto

# Preview sem fazer alterações
./scripts/sync-context.sh ~/projects/meu-projeto --dry-run

# Força sobrescrever tudo
./scripts/sync-context.sh ~/projects/meu-projeto --force

# Não sincroniza .mcp.json (projeto já tem config própria)
./scripts/sync-context.sh ~/projects/meu-projeto --no-mcp

# Não sincroniza PRDs (mantém os do projeto)
./scripts/sync-context.sh ~/projects/meu-projeto --no-tasks

# Modo minimal - apenas essenciais
./scripts/sync-context.sh ~/projects/meu-projeto --minimal

# Combinações
./scripts/sync-context.sh ~/projects/meu-projeto --no-mcp --no-tasks --verbose
```

#### Opções

| Flag | Descrição |
|------|-----------|
| `--dry-run` | Mostra o que seria feito sem fazer alterações |
| `--force` | Sobrescreve todos os arquivos sem perguntar |
| `--no-mcp` | Não sincroniza .mcp.json |
| `--no-tasks` | Não sincroniza .agent/Tasks/ (exceto README) |
| `--minimal` | Apenas arquivos essenciais (commands, hooks, base rules) |
| `--verbose` | Mostra progresso detalhado |
| `--help` | Mostra ajuda |

#### O que é sincronizado

```
.agent/           → Documentação e agentes
.claude/          → Commands, hooks, skills, settings
.ruler/           → Regras de injeção
.claudeignore     → Exclusões de contexto
.mcp.json         → Configuração de MCPs
CLAUDE.md         → Instruções principais
```

#### Arquivos ignorados

- `.DS_Store` e arquivos de sistema
- `.claude/settings.local.json` (configurações locais do usuário)
- PRDs específicos quando `--no-tasks` é usado

### init-context.sh

Inicializa a estrutura de contextos em qualquer projeto, baixando do repositório remoto.

```bash
# No diretório atual
./scripts/init-context.sh

# Em outro diretório
./scripts/init-context.sh ~/projects/novo-projeto
```

---

## Personalização

### 1. Identificação do Projeto

Edite `.agent/README.md`:

```yaml
project: "@meu-projeto/source"
type: Nx Monorepo
package_manager: pnpm

stack:
  frontend: React 19+      # ou Angular, Vue, etc
  backend: Express 5+      # ou NestJS, Fastify, etc
  ui: shadcn/ui            # ou PrimeNG, MUI, etc
  css: Tailwind 4+
  test: Vitest             # ou Jest
```

### 2. MCPs

Edite `.mcp.json` e adicione suas API keys:

```json
{
  "mcpServers": {
    "context7": {
      "headers": {
        "CONTEXT7_API_KEY": "sua-api-key"
      }
    }
  }
}
```

### 3. Documentação do Stack

Em `.agent/System/`, mantenha apenas docs relevantes:

**Para React:**
- Remova: `angular_*.md`, `primeng_*.md`, `nestjs_*.md`
- Adicione: `react_best_practices.md`, `nextjs_reference.md`

**Para Angular:**
- Mantenha: `angular_*.md`, `primeng_*.md`
- Remova: `react_*.md`

### 4. Settings Locais

Crie `.claude/settings.local.json` para configurações pessoais (não commitado):

```json
{
  "permissions": {
    "allow": ["Bash(pnpm *)"]
  }
}
```

---

## Fluxo de Trabalho

### Como funciona

```
1. Você digita /plan
2. Hook detecta e injeta contexto de arquitetura
3. Sub-agentes rodam em paralelo (Explore + Plan + UX Research)
4. PRD é gerado com YAML estruturado
5. Você implementa com /task
6. No commit, hooks validam lint/test/build
7. Se passar, commit acontece. Se falhar, bloqueia.
```

### Pipeline de Feature

```
@nx-operator      → Gera libs
       ↓
@coder (domain)   → Interfaces, DTOs
       ↓
@coder (data)     → Facades, repositories
       ↓
@coder (feature)  → Components
       ↓
@test-writer      → Unit tests
       ↓
@qa-runner        → lint, test, build
       ↓
@git-operator     → Commit
```

---

## Estrutura de Pastas

```
.
├── .agent/                    # Documentação AI
│   ├── Agents/                # Definições de agentes
│   │   ├── analysis/          # @explorer, @debugger
│   │   ├── automation/        # @git-operator, @nx-operator, @e2e-tester
│   │   ├── design/            # @ux-researcher, @ui-designer
│   │   ├── development/       # @coder, @test-writer, @docs-writer
│   │   ├── planning/          # @task-planner
│   │   └── quality/           # @qa-runner, @arch-validator, @code-reviewer
│   ├── Plans/                 # Planos em andamento
│   ├── Prompts/               # Templates de prompts
│   ├── SOPs/                  # Procedimentos padrão
│   ├── System/                # Documentação técnica
│   └── Tasks/                 # PRDs
├── .claude/                   # Configuração Claude Code
│   ├── commands/              # Slash commands
│   ├── hooks/                 # Scripts de hooks
│   ├── skills/                # Skills dos agentes
│   └── settings.json          # Configurações e hooks
├── .ruler/                    # Regras de injeção
├── scripts/                   # Scripts utilitários
│   ├── sync-context.sh        # Sincroniza contextos
│   ├── init-context.sh        # Inicializa contextos
│   └── README.md              # Documentação scripts
├── .claudeignore              # Exclusões de contexto
├── .mcp.json                  # MCPs configurados
├── CLAUDE.md                  # Instruções principais
└── README.md                  # Este arquivo
```

---

## Comandos Úteis

```bash
# Desenvolvimento
pnpm start                          # Serve web + api

# Verificação
pnpm nx affected:lint --base=main
pnpm nx affected:test --base=main
pnpm nx affected:build --base=main

# Gerar libs
pnpm nx g @nx/angular:lib [name] --directory=[scope] --standalone
pnpm nx g @nx/js:lib domain --directory=[scope]
```

---

## Contribuindo

1. Fork o repositório
2. Crie sua branch (`git checkout -b feature/minha-feature`)
3. Commit suas mudanças (`git commit -m 'feat: adiciona feature'`)
4. Push para a branch (`git push origin feature/minha-feature`)
5. Abra um Pull Request

---

## Licença

MIT

---

## Links

- [Nx Documentation](https://nx.dev)
- [Claude Code](https://claude.ai/code)
- [MCP Servers](https://modelcontextprotocol.io)
