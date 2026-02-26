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
| `/plan` | Planeja uma task (WORK-xxxx) com investigação e criação de DEV_PRD |
| `/orchestrate` | Orquestra multiplas tasks em paralelo (classificação, análise, PRDs) |
| `/spec` | Converte DEV_PRDs aprovadas em specs executáveis |
| `/task` | Implementa uma spec seguindo padrões |
| `/task-team` | Implementa multiplas specs em paralelo via Agent Teams |
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

### Agentes Especializados

```
.claude/agents/               → Agentes do pipeline de orquestração
├── orchestrator.md           → Coordena multi-task workflows
├── bug-investigator.md       → Investiga bugs (root cause, data flow)
├── enhancement-analyst.md    → Analisa melhorias (business rules, reuso)
├── prd-writer.md             → Cria DEV_PRDs legíveis para review
├── spec-writer.md            → Converte PRDs em specs executáveis
└── implementer.md            → Teammate que implementa 1 spec end-to-end

.agent/Agents/                → 15+ sub-agentes de desenvolvimento
├── @coder, @test-writer, @docs-writer
├── @debugger, @explorer
├── @qa-runner, @arch-validator, @code-reviewer
└── @ux-researcher, @ui-designer
```

### Estrutura .agent/

```
.agent/
├── Agents/      → Sub-agentes de desenvolvimento
├── System/      → Padrões técnicos
├── SOPs/        → Procedimentos (inclui orchestration_workflow.md)
├── Tasks/       → PRDs, DEV_PRDs, Specs e templates
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
# Sincroniza a estrutura de contextos (de dentro do _base)
./scripts/sync-context.sh ~/projects/meu-projeto

# Ou com preview
./scripts/sync-context.sh ~/projects/meu-projeto --dry-run
```

### Atualizar Projeto Existente

```bash
# De dentro do projeto alvo (auto-detecta _base)
.claude/hooks/setup.sh --update

# Preview sem fazer alterações
.claude/hooks/setup.sh --update --dry-run

# Com _base customizado
.claude/hooks/setup.sh --update --base ~/dev/_base

# De dentro do _base, apontando para o projeto
.claude/hooks/setup.sh --update --target ~/projects/meu-projeto
```

---

## Scripts e Setup

### setup.sh --update

Atualiza projetos existentes com a configuração mais recente do _base. Roda de dentro do projeto alvo.

```bash
# Preview do que seria atualizado
.claude/hooks/setup.sh --update --dry-run

# Aplica atualizações (auto-detecta _base)
.claude/hooks/setup.sh --update

# Especifica o _base manualmente
.claude/hooks/setup.sh --update --base ~/Development/_base

# Sem sincronizar MCP ou Tasks específicas
.claude/hooks/setup.sh --update --no-mcp --no-tasks
```

| Flag | Descrição |
|------|-----------|
| `--base <path>` | Caminho do _base (auto-detectado se omitido) |
| `--target <path>` | Caminho do projeto alvo (default: projeto atual) |
| `--dry-run` | Mostra o que seria feito sem fazer alterações |
| `--force` | Sobrescreve todos os arquivos sem backup |
| `--no-mcp` | Não sincroniza .mcp.json |
| `--no-tasks` | Não sincroniza .agent/Tasks/ (exceto templates) |
| `--verbose` | Mostra progresso detalhado |

**O que sincroniza**: `.claude/agents/`, `.claude/commands/`, `.claude/hooks/`, `.agent/SOPs/`, `.agent/Tasks/`, `.agent/System/`, `.agent/Agents/`, `.ruler/`, `CLAUDE.md`, `.claudeignore`

**O que preserva**: `settings.local.json` (pessoal), `Tasks/README.md` (projeto-específico)

### sync-context.sh

Sincroniza a estrutura de contextos para um projeto existente (roda de dentro do _base).

```bash
# Básico - sincroniza tudo
./scripts/sync-context.sh ~/projects/meu-projeto

# Preview sem fazer alterações
./scripts/sync-context.sh ~/projects/meu-projeto --dry-run

# Combinações
./scripts/sync-context.sh ~/projects/meu-projeto --no-mcp --no-tasks --verbose
```

### init-context.sh

Inicializa a estrutura de contextos em qualquer projeto, baixando do repositório remoto.

```bash
./scripts/init-context.sh
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

### Task Individual

```
1. /plan WORK-1234           → Investiga e cria DEV_PRD
2. Revisa DEV_PRD, marca "aprovado"
3. /spec                     → Gera SPEC executável
4. /task                     → Implementa a spec
5. Hooks validam lint/test/build no commit
```

### Multi-Task (Orquestração)

```
1. /orchestrate WORK-1234 WORK-1235 WORK-1236
   → Classifica cada task (bug/enhancement/feature)
   → Analisa todas em paralelo (agentes especializados)
   → Gera DEV_PRDs para cada uma

2. Dev revisa e aprova cada DEV_PRD

3. /spec
   → Converte PRDs aprovadas em specs executáveis

4. /task-team
   → Implementa specs em paralelo (Agent Teams + worktrees)
   → Cada teammate trabalha em isolamento
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
│   ├── Agents/                # Sub-agentes de desenvolvimento
│   │   ├── analysis/          # @explorer, @debugger
│   │   ├── automation/        # @git-operator, @nx-operator, @e2e-tester
│   │   ├── design/            # @ux-researcher, @ui-designer
│   │   ├── development/       # @coder, @test-writer, @docs-writer
│   │   ├── planning/          # @task-planner
│   │   └── quality/           # @qa-runner, @arch-validator, @code-reviewer
│   ├── Plans/                 # Planos em andamento
│   ├── SOPs/                  # Procedimentos padrão
│   │   └── orchestration_workflow.md  # Workflow multi-task
│   ├── System/                # Documentação técnica
│   └── Tasks/                 # PRDs, DEV_PRDs, Specs
│       ├── TEMPLATE_dev_prd.md    # Template para DEV_PRDs
│       └── TEMPLATE_spec.md       # Template para Specs
├── .claude/                   # Configuração Claude Code
│   ├── agents/                # Agentes do pipeline de orquestração
│   │   ├── orchestrator.md    # Coordena multi-task workflows
│   │   ├── bug-investigator.md
│   │   ├── enhancement-analyst.md
│   │   ├── prd-writer.md
│   │   ├── spec-writer.md
│   │   └── implementer.md
│   ├── commands/              # Slash commands
│   │   ├── orchestrate.md     # /orchestrate - Multi-task
│   │   ├── plan.md            # /plan - Single task
│   │   ├── spec.md            # /spec - Gerar specs
│   │   ├── task.md            # /task - Implementar
│   │   └── task-team.md       # /task-team - Paralelo
│   ├── hooks/                 # Scripts de hooks
│   │   └── setup/             # Setup scripts
│   │       ├── init.sh        # Dev setup
│   │       ├── init-only.sh   # CI setup
│   │       ├── update.sh      # Sync _base config
│   │       └── maintenance.sh # Manutenção
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
