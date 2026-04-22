# Scripts

Scripts para gerenciar a estrutura de contextos de IA.

**Scripts disponíveis**:

| Script | Propósito |
|--------|-----------|
| `setup.sh --update` | Atualiza projeto existente com a base (roda de dentro do alvo) |
| `sync-context.sh` | Sincroniza estrutura completa para um alvo (roda do _base) |
| `init-context.sh` | Inicializa estrutura em projeto novo (baixa do GitHub) |
| `update-ai-guard.sh` | Aplica APENAS AI-Guard (performance + segurança + arquitetura) |

## setup.sh --update

Atualiza projetos existentes com a configuração mais recente do `_base`. Diferente do `sync-context.sh`, este script roda **de dentro do projeto alvo** e auto-detecta a localização do `_base`.

### Uso

```bash
# Preview do que seria atualizado
.claude/hooks/setup.sh --update --dry-run

# Aplica atualizações (auto-detecta _base)
.claude/hooks/setup.sh --update

# Especifica o _base manualmente
.claude/hooks/setup.sh --update --base ~/Development/_base

# Atualiza de dentro do _base, apontando para outro projeto
.claude/hooks/setup.sh --update --target ~/projects/meu-projeto

# Sem sincronizar MCP ou Tasks específicas
.claude/hooks/setup.sh --update --no-mcp --no-tasks --verbose
```

### Opções

| Flag | Descrição |
|------|-----------|
| `--base <path>` | Caminho para o repositório _base (auto-detectado se omitido) |
| `--target <path>` | Caminho do projeto alvo (default: raiz do projeto atual) |
| `--dry-run` | Mostra o que seria feito sem fazer alterações |
| `--force` | Sobrescreve todos os arquivos sem criar backups |
| `--no-mcp` | Não sincroniza .mcp.json |
| `--no-tasks` | Não sincroniza .agent/Tasks/ (exceto templates TEMPLATE_*) |
| `--verbose` | Mostra progresso detalhado arquivo por arquivo |

### O que é sincronizado

```
.claude/agents/   → Agentes do pipeline de orquestração
.claude/commands/  → Slash commands
.claude/hooks/     → Scripts de hooks e setup
.agent/SOPs/       → Procedimentos padrão
.agent/Tasks/      → Templates (TEMPLATE_dev_prd.md, TEMPLATE_spec.md)
.agent/System/     → Documentação técnica
.agent/Agents/     → Sub-agentes de desenvolvimento
.ruler/            → Regras de injeção
CLAUDE.md          → Instruções principais
.claudeignore      → Exclusões de contexto
```

### Arquivos protegidos (nunca sobrescritos)

- `.claude/settings.local.json` (configurações pessoais)
- `.agent/Tasks/README.md` (específico do projeto)

### Quando usar

- Quando o `_base` recebe novos agentes, commands ou regras
- Ao adotar features novas como orquestração multi-task
- Para manter projetos existentes em sincronia com as últimas práticas

---

## sync-context.sh

Sincroniza a estrutura de contextos para um projeto existente.

### Uso

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

### Opções

| Flag | Descrição |
|------|-----------|
| `--dry-run` | Mostra o que seria feito sem fazer alterações |
| `--force` | Sobrescreve todos os arquivos sem perguntar |
| `--no-mcp` | Não sincroniza .mcp.json |
| `--no-tasks` | Não sincroniza .agent/Tasks/ (exceto README) |
| `--minimal` | Apenas arquivos essenciais (commands, hooks, base rules) |
| `--verbose` | Mostra progresso detalhado |
| `--help` | Mostra ajuda |

### O que é sincronizado

```
.agent/           → Documentação e agentes
.claude/          → Commands, hooks, skills, settings
.ruler/           → Regras de injeção
.claudeignore     → Exclusões de contexto
.mcp.json         → Configuração de MCPs
CLAUDE.md         → Instruções principais
```

### Arquivos ignorados

- `.DS_Store` e arquivos de sistema
- `.claude/settings.local.json` (configurações locais do usuário)
- PRDs específicos quando `--no-tasks` é usado

---

## init-context.sh

Inicializa a estrutura de contextos em qualquer projeto, baixando do repositório remoto.

### Uso Local

```bash
# No diretório atual
./scripts/init-context.sh

# Em outro diretório
./scripts/init-context.sh ~/projects/novo-projeto
```

### Uso Remoto (quando o repositório estiver público)

```bash
# Inicializa no diretório atual
curl -fsSL https://raw.githubusercontent.com/USER/REPO/main/scripts/init-context.sh | bash

# Inicializa em outro diretório
curl -fsSL https://raw.githubusercontent.com/USER/REPO/main/scripts/init-context.sh | bash -s ~/projects/meu-projeto
```

---

## update-ai-guard.sh

Aplica **apenas** a stack de auditoria AI-Guard (3 agents + 3 skills + 1 slash command + 3 docs espelho). Ideal para projetos que já têm `.agent/` e `.claude/` configurados e querem adicionar só o novo.

### Uso

```bash
# Preview
./scripts/update-ai-guard.sh ~/projects/meu-projeto --dry-run

# Aplica
./scripts/update-ai-guard.sh ~/projects/meu-projeto

# Com detalhes
./scripts/update-ai-guard.sh ~/projects/meu-projeto --verbose
```

### Arquivos sincronizados

```
.claude/skills/performance-auditor/SKILL.md
.claude/skills/security-auditor/SKILL.md
.claude/skills/architecture-reviewer/SKILL.md
.claude/agents/performance-auditor.md
.claude/agents/security-auditor.md
.claude/agents/architecture-reviewer.md
.claude/commands/audit-report.md
.agent/Agents/quality/@performance-auditor.md
.agent/Agents/quality/@security-auditor.md
.agent/Agents/quality/@architecture-reviewer.md
```

### O que fazer depois

1. Adicionar linha `AI-Guard` na tabela Agent Categories do `CLAUDE.md` e `.claude/CLAUDE.md`
2. Atualizar `.agent/Agents/README.md` (seção quality)
3. Rodar `/audit-report` no Claude Code

### Quando usar

- Projeto existente que **já sincronizou a base** e quer só o novo pacote AI-Guard
- Evitar conflitos com ajustes locais em outros arquivos da base
- Cherry-pick da feature sem sobrescrever mais nada

---

## Fluxo Recomendado

### Projeto Novo

```bash
# 1. Cria o projeto
mkdir meu-projeto && cd meu-projeto
git init

# 2. Inicializa contexto
../path/to/_base/scripts/init-context.sh .

# 3. Configura para seu stack
#    - Edita .agent/README.md (nome, stack)
#    - Edita .mcp.json (API keys)
#    - Remove docs desnecessários de .agent/System/

# 4. Commit
git add .
git commit -m "chore: initialize AI context structure"
```

### Projeto Existente

```bash
# 1. Sincroniza estrutura
../path/to/_base/scripts/sync-context.sh . --dry-run  # preview
../path/to/_base/scripts/sync-context.sh .            # aplica

# 2. Review e ajusta
git diff

# 3. Commit
git add .agent .claude .ruler .claudeignore .mcp.json CLAUDE.md
git commit -m "chore: sync AI context structure from base"
```

### Atualizar Projeto

Quando a base for atualizada, há duas opções:

```bash
# Opção 1: De dentro do projeto alvo (recomendado)
cd ~/projects/meu-projeto
.claude/hooks/setup.sh --update --dry-run    # preview
.claude/hooks/setup.sh --update              # aplica

# Opção 2: De dentro do _base (via sync-context)
./scripts/sync-context.sh ~/projects/meu-projeto --no-tasks --no-mcp
```

---

## Personalização Pós-Sync

### 1. Identificação do Projeto

Edite `.agent/README.md`:

```yaml
project: "@meu-projeto/source"
type: Nx Monorepo
package_manager: pnpm  # ou npm, yarn, bun

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
