# Scripts

Scripts para gerenciar a estrutura de contextos de IA.

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

Quando a base for atualizada:

```bash
# Sincroniza apenas atualizações, mantendo PRDs e MCP
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
