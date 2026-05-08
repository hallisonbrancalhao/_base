# .agent Documentation Structure

## 🤖 Sub-Agent Execution Protocol

---

## Communication Style

- No filler phrases ("I get it", "Awesome, here's what I'll do", "Great question")
- Direct, efficient responses — code/config first, explanations when needed
- Admit uncertainty rather than guess
- Consider token efficiency in all additions

---

All tasks **MUST** be delegated to specialized sub-agents. The primary agent acts as orchestrator only.

> **Full documentation**: `.agent/Agents/README.md`

---

### Agent Categories

| Category        | Agents                                                                | Purpose                                                                                                      |
| --------------- | --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| **Quality**     | `@qa-runner`, `@arch-validator`, `@code-reviewer`                     | Validation & compliance                                                                                      |
| **AI-Guard**    | `@performance-auditor`, `@security-auditor`, `@architecture-reviewer` | Auditoria de código gerado por IA (N+1, race, leak, SAST, secrets, SCA, tradeoffs, DR) — via `/audit-report` |
| **Development** | `@coder`, `@test-writer`, `@docs-writer`                              | Code generation                                                                                              |
| **Automation**  | `@e2e-tester`, `@git-operator`, `@nx-operator`                        | DevOps & tooling                                                                                             |
| **Analysis**    | `@explorer`, `@debugger`                                              | Research & investigation                                                                                     |

---

## 📁 Overview

The `.agent/` folder contains all critical project documentation organized to provide complete context to developers and AI assistants. This documentation is separate from code but essential for understanding the project.

👉 Read `.agent/README.md` for:

- Complete folder structure
- When to use Tasks/, System/, SOPs/
- Documentation workflow
- AI assistant rules
- Quick index of all documents

# Core Rules for AI Assistants

## 🎯 Primary Directive

Architecture (Always Read First)

| Document                                                              | Purpose                            |
| --------------------------------------------------------------------- | ---------------------------------- |
| [TypeScript Clean Code](.agent/System/typescript_clean_code.md)       | Naming, functions, comments policy |
| [Nx Architecture Rules](.agent/System/nx_architecture_rules.md)       | Lib dependencies & boundaries      |
| [Libs Architecture](.agent/System/libs_architecture_pattern.md)       | Scope/Lib structure                |
| [Interface-DTO Patterns](.agent/System/interface-dto-architecture.md) | DTO conventions                    |
| [Barrel Best Practices](.agent/System/barrel_best_practices.md)       | Export rules                       |

## 🎯 Primary Directive

**READ FIRST**: `.agent/README.md` - This file contains the complete structure and purpose of the `.agent/` folder.

**CODE PATTERN**

- Without explicit instructions, always follow the established code patterns in `.agent/System/` documentation. Without comments, assume the latest documented best practices apply.

**COMMIT PATTERN**

- Follow the commit message conventions in `.agent/SOPs/git_commit_instructions.md`.

### Import Organization

→ See `.agent/System/base_rules.md`

✅ Group imports by type: Angular, third-party libs, PrimeNG, shared, components  
❌ NO random import order, NO mixed dependencies without clear sections

**Pattern**:

```typescript
// Angular imports
import { Component, input, output } from '@angular/core';
import { signal } from '@angular/core';

// PrimeNG imports
import { ButtonModule } from 'primeng/button';

// Shared imports
import { SharedService } from '@shared/services/shared.service';

// Component imports
import { HeaderComponent } from './header.component';
```

---

## 📚 All Documentation is in `.agent/`

```
.agent/
├── README.md              ← START HERE
├── Tasks/                 ← PRDs (optional, local)
├── System/                ← Technical docs
└── SOPs/                  ← Procedures
```

---

# MCP Launchpad (Your gateway to ALL MCPs!)

You have access to the MCP Launchpad (`mcpl`), a unified CLI for discovering and executing tools from multiple MCP servers. The user may configure and change their MCP configuration at any time. So if your task requires a tool or functionality outside of your current capabilities, it's critical that you always check the MCP Launchpad for available tools that may be useful.

## Available MCP Servers

| Server            | Type  | Purpose                                      |
| ----------------- | ----- | -------------------------------------------- |
| `primeng`         | stdio | PrimeNG component documentation and examples |
| `context7`        | http  | Context7 AI-powered documentation            |
| `gemini-cli`      | stdio | Google Gemini AI integration                 |
| `linear-server`   | http  | Linear issue tracking integration            |
| `firecrawl`       | stdio | Web scraping and crawling                    |
| `chrome-devtools` | stdio | Chrome DevTools debugging                    |
| `nx-mcp`          | stdio | Nx workspace tools and generators            |
| `figma`           | http  | Figma design integration                     |
| `angular-cli`     | stdio | Angular CLI and documentation                |

## Important: Always Discover Before Calling

Tool names vary between MCP servers. **Never guess tool names** - always discover them first.

If you're unsure of the tool name, **always search first**. The `mcpl search` command is the most efficient way to find relevant tools across all MCP servers.

### Recommended Workflow

1. **Search first** to find the right tool (shows required params):

   ```bash
   mcpl search "component"           # Find PrimeNG/Angular components
   mcpl search "scrape"              # Find firecrawl scraping tools
   mcpl search "issue"               # Find Linear issue tools
   ```

2. **Call with required params**:
   ```bash
   mcpl call primeng get_component '{"name": "button"}'
   mcpl call angular-cli list_projects '{}'
   mcpl call nx-mcp run_generator '{"generator": "@nx/angular:component"}'
   ```

### Alternative: List Server Tools

If you know which server to use but not the tool name:

```bash
mcpl list primeng        # PrimeNG component tools
mcpl list angular-cli    # Angular CLI tools
mcpl list nx-mcp         # Nx workspace tools
mcpl list figma          # Figma design tools
mcpl list linear-server  # Linear issue tracking
mcpl list firecrawl      # Web scraping tools
```

### Get Example Calls

For complex tools, use `inspect --example` to get a ready-to-use example:

```bash
mcpl inspect angular-cli search_documentation --example
mcpl inspect figma get_design_context --example
mcpl inspect nx-mcp affected --example
```

## Common Use Cases

### Angular Development

```bash
mcpl call angular-cli search_documentation '{"query": "signals"}'
mcpl call angular-cli get_best_practices '{"workspacePath": "/path/to/angular.json"}'
mcpl call angular-cli find_examples '{"query": "reactive forms"}'
```

### PrimeNG Components

```bash
mcpl call primeng get_component '{"name": "table"}'
mcpl call primeng search_components '{"query": "input"}'
```

### Nx Workspace

```bash
mcpl call nx-mcp list_projects '{}'
mcpl call nx-mcp run_generator '{"generator": "@nx/angular:library", "options": {"name": "shared-ui"}}'
mcpl call nx-mcp affected '{"target": "test"}'
```

### Figma Integration

```bash
mcpl call figma get_design_context '{"nodeId": "123:456", "fileKey": "abc123"}'
mcpl call figma get_screenshot '{"nodeId": "123:456", "fileKey": "abc123"}'
```

### Linear Issues

```bash
mcpl call linear-server list_issues '{}'
mcpl call linear-server create_issue '{"title": "Bug fix", "teamId": "TEAM-1"}'
```

### Web Scraping (Firecrawl)

```bash
mcpl call firecrawl scrape '{"url": "https://example.com"}'
mcpl call firecrawl crawl '{"url": "https://docs.example.com", "maxDepth": 2}'
```

## Error Recovery

If a tool call fails, mcpl provides helpful suggestions:

- **Tool not found**: Shows similar tool names from that server
- **Missing parameters**: Shows required params and an example call
- **Validation errors**: Shows expected parameter types

### Troubleshooting Commands

```bash
mcpl verify                 # Test all server connections
mcpl session status         # Check daemon and server connection status
mcpl session stop           # Restart daemon (stops current, auto-restarts on next call)
mcpl config                 # Show current configuration
mcpl call <server> <tool> '{}' --no-daemon  # Bypass daemon for debugging
```

### Common Issues

- **Server not connecting**: Run `mcpl verify` to test connections
- **Stale connections**: Run `mcpl session stop` then retry
- **Timeout errors**: Server may be slow; increase with `MCPL_CONNECTION_TIMEOUT=120`
- **HTTP servers (context7, linear, figma)**: Check API keys and network connectivity

## Quick Reference

```bash
# Show help
mcpl --help

# Find tools
mcpl search "<query>"                    # Search all tools (returns 5 by default)
mcpl search "<query>" --limit 10         # Get more results
mcpl list                                # List all MCP servers
mcpl list <server>                       # List tools for a server

# Get tool details
mcpl inspect <server> <tool>             # Full schema
mcpl inspect <server> <tool> --example   # Schema + example call

# Execute tools
mcpl call angular-cli list_projects '{}'
mcpl call primeng get_component '{"name": "dialog"}'
mcpl call nx-mcp affected '{"target": "build"}'
mcpl call figma get_screenshot '{"nodeId": "1:2", "fileKey": "xyz"}'

# Verify servers
mcpl verify                              # Test all servers are working
```

## ⚡ Essential Rules

### 🚫 REGRAS CRÍTICAS — Não negociáveis

#### 1. DTOs com decorators são EXCLUSIVAMENTE backend

Frontend (`type:data-access`, `type:feature`, `type:ui`, `type:app` — `apps/web|mobile`) NUNCA importa `*.dto.ts` que contenha decorators de `class-validator`/`class-transformer`. Esses decorators chamam `Reflect.getMetadata` em runtime e quebram o boot do app no browser (Vite/esbuild + reflect-metadata IIFE).

✅ FE consome: `interfaces/*.interface.ts`, `enums/`, `types/`, `schemas/` (Zod)
❌ FE proibido: `dtos/*.dto.ts`, `dtos/*.decorator.ts`, pacotes `class-validator` e `class-transformer`

**Sincronia BE↔FE:** toda classe DTO/Entity do BE faz `implements IXxx`.

**Enforcement obrigatório** — `eslint.config.mjs` (`@nx/enforce-module-boundaries`):

```js
{ sourceTag: 'type:data-access', bannedExternalImports: ['class-validator', 'class-transformer'] },
{ sourceTag: 'type:feature',     bannedExternalImports: ['class-validator', 'class-transformer'] },
{ sourceTag: 'type:ui',          bannedExternalImports: ['class-validator', 'class-transformer'] },
{ sourceTag: 'type:app',         bannedExternalImports: ['class-validator', 'class-transformer'] },
```

→ Detalhes em `.agent/System/interface-dto-architecture.md` e `.agent/System/nx_architecture_rules.md`.

#### 2. Web é signal-first SEM zone.js

`apps/web` usa `provideZonelessChangeDetection()`. Proibido `NgZone`, `zone.js`, `setTimeout` para forçar CD. Tudo via `signal()`, `computed()`, `effect()`, `input()`, `output()`.

---

### BASE

→ See `.agent/System/base_rules.md`

### Angular

→ See `.agent/System/angular_best_practices.md`

✅ Standalone components, signals, `input()`/`output()`, `@if`/`@for`  
❌ NO NgModules, decorators, `*ngIf`/`*ngFor`, `ngClass`/`ngStyle`

### Testing

→ See `.agent/System/angular_unit_testing_guide.md`

✅ Mock all, use schemas, `data-testid`, `componentRef.setInput()`  
❌ NO `componentInstance` internals, `querySelector()`, manual lifecycle

### PrimeNG

→ See `.agent/System/primeng_best_practices.md`

✅ Use `p-button`, `p-inputtext`, `p-select`, `p-date-picker`, `#template`  
❌ NO directives (`pButton`, `pInputText`, `pDropdown`, `pTemplate`)

### Dark Mode

→ See `.agent/System/dark_mode_reference.md`

✅ PrimeNG surface colors (`surface-0` to `surface-950`), `dark:` prefix  
❌ NO Tailwind colors (`gray-*`), arbitrary colors, inline styles

### Responsive Design

→ See `.agent/System/responsive_design_guide.md`

✅ Mobile-first, Tailwind breakpoints (`sm:`, `md:`, `lg:`), min 44px touch targets  
❌ NO fixed widths without breakpoints, small text on mobile (< 16px)

### Architecture

→ See `.agent/System/project_architecture.md`

✅ Facade Pattern, Repository Pattern, Component Pattern (dumb/presentational)  
❌ NO business logic in components, NO direct HTTP in components

### Git

→ See `.agent/SOPs/git_commit_instructions.md`

`feat:` | `fix:` | `docs:` | `refactor:` | `test:` | `chore:`

---

## 📋 Workflow

```
1. Read .agent/README.md
2. Follow .agent/System/ and .agent/SOPs/
3. Update .agent/ after changes
```

---

# Barrel Exports - Boas Praticas

## Regra Fundamental

**SEMPRE prefira imports diretos ao inves de imports via barrel.**

```typescript
// CORRETO - Import direto
import { StoreDto } from '@store/domain/dtos/store.dto';
import { UserEntity } from '@backend/database/entities/user.entity';

// INCORRETO - Import via barrel
import { StoreDto } from '@store/domain';
import { UserEntity } from '@backend/database';
```

## Estrutura de Paths no tsconfig.base.json

### Configuracao Obrigatoria

```json
{
  "compilerOptions": {
    "paths": {
      // Path para barrel (manter para retrocompatibilidade)
      "@store/domain": ["libs/store/domain/src/index.ts"],

      // Path para imports diretos (PREFERIDO)
      "@store/domain/*": ["libs/store/domain/src/lib/*"]
    }
  }
}
```

### Padrao de Nomenclatura

```
@{scope}/{lib}/*

Exemplos:
@store/domain/*
@user/data-access/*
@payment/api/*
@backend/shared/*
@shared/ui/*
```

# Padroes de Import por Camada

### 1. Domain Layer (DTOs, Interfaces, Models)

```typescript
// DTOs
import { StoreDto } from '@store/domain/dtos/store.dto';
import { CreateUserDto } from '@user/domain/dtos/create-user.dto';

// Interfaces
import { IStoreRepository } from '@store/domain/interfaces/store-repository.interface';

// Models
import { StoreModel } from '@store/domain/models/store.model';

// Enums
import { StoreStatus } from '@store/domain/enums/store-status.enum';



## 1. Conceitos Fundamentais

### 1.1 O que é ESCOPO (Scope)?

**ESCOPO** é um **diretório de primeiro nível** dentro de `libs/` que agrupa bibliotecas relacionadas por contexto, funcionalidade ou domínio de negócio.

```

libs/
├── admin/ ← ESCOPO (agrupa libs do painel admin)
├── auth/ ← ESCOPO (agrupa libs de autenticação)
├── public/ ← ESCOPO (agrupa libs de páginas públicas)
└── shared/ ← ESCOPO (agrupa libs compartilhadas)

```

**Características do ESCOPO:**
- NÃO é uma biblioteca por si só
- NÃO tem `project.json`, `package.json` ou `src/`
- É apenas uma **pasta organizacional**
- Agrupa múltiplas bibliotecas relacionadas

---

### 1.2 O que é LIB (Library)?

**LIB** é uma **biblioteca Nx real** que contém código executável, tem sua própria configuração e pode ser importada por outras libs ou apps.

```

libs/admin/
├── data-access/ ← LIB (biblioteca real)
│ ├── project.json ← Configuração Nx
│ ├── src/
│ │ ├── index.ts ← Public API
│ │ └── lib/ ← Código fonte
│ └── tsconfig.json
├── data-source/ ← LIB (biblioteca real)
│ ├── project.json
│ ├── src/
│ │ ├── index.ts
│ │ └── lib/
│ └── tsconfig.json
├── feature-dashboard/ ← LIB
└── feature-users/ ← LIB

```


## 2. Tipos de ESCOPOS

### 2.1 Escopos de Aplicação (Application Scopes)

Agrupam libs relacionadas a uma área específica da aplicação frontend.

| Escopo | Descrição | Exemplo de Libs |
|--------|-----------|-----------------|
| `admin/` | Painel administrativo | `feature-dashboard`, `feature-users`, `data-access` |
| `public/` | Páginas públicas | `feature-home`, `feature-about`, `data-access` |
| `client/` | Área do cliente | `feature-proposals`, `data-access`, `domain` |
| `simulator/` | Fluxo do simulador | `feature-step-*`, `data-access` |

**Estrutura padrão:**
```

libs/[escopo-aplicacao]/
├── data-access/ # Facades e serviços
├── data-source/ # Fontes de dados backend / DTOs com class-validator - sempre implementando as interfaces do domain
├── domain/ # DTOs, Interfaces, Enums
├── ui-components/ # Componentes UI (opcional)
├── utils/ # Utilitários (opcional)
├── feature-shell/ # Shell de rotas (opcional)
├── feature-[name]/ # Features/páginas
└── ... # Outras libs de features ou outros.

```


## 3. Tipos de LIBS

### 3.1 Tabela de Tipos

| Tipo | Sufixo/Nome | Responsabilidade | Pode Depender de |
|------|-------------|------------------|------------------|
| **Shell** | `shell` | Routing, bootstrap | feature, data-access, ui, util |
| **Feature** | `feature-*` | Páginas, smart components | data-access, ui, util |
| **Data-Access** | `data-access` | Facades, state, repositories | domain, util |
| **Data-Source** | `data-source` | Backend services, controllers, / DTOs com class-validator - sempre implementando as interfaces do domain | domain, util |
| **Domain** | `domain` | DTOs, interfaces, enums | util (apenas) |
| **UI** | `ui-*` | Componentes visuais puros | ui, util |
| **Util** | `utils`, `util-*` | Funções puras, helpers | util (apenas) |

---

### 3.2 Shell Libraries

**Propósito:** Orquestração de rotas e configuração da aplicação.

```

libs/web/shell/
├── src/lib/
│ ├── public-shell.component.ts # Shell rotas públicas
│ ├── auth-shell.component.ts # Shell rotas autenticadas
│ └── routes.ts # Configuração de rotas
└── src/index.ts

```

**Regras:**
- ✅ PODE: importar features, data-access, UI
- ✅ PODE: definir rotas lazy-loaded
- ❌ NÃO PODE: ter lógica de negócio
- ❌ NÃO PODE: importar domain diretamente

---


### 3.4 Data-Access Libraries

**Propósito:** State management, facades, repositories (Frontend).

```

libs/user/data-access/
├── src/lib/
│ ├── facades/
│ │ └── user.facade.ts # State management com signals
│ ├── repositories/
│ │ └── user.repository.ts # Abstração HTTP
│ ├── services/
│ │ └── user-validation.service.ts
│ └── guards/
│ └── user-auth.guard.ts
└── src/index.ts

```

**Regras:**
- ✅ PODE: importar domain (DTOs, interfaces)
- ✅ PODE: usar HttpClient
- ✅ PODE: gerenciar estado com signals
- ❌ NÃO PODE: importar features
- ❌ NÃO PODE: importar componentes UI
- ❌ NÃO PODE: ter componentes visuais

---


### 3.5 Data-Source Libraries

**Propósito:** Backend services, controllers, entities (NestJS).

```

libs/user/data-source/
├── src/lib/
│ ├── controllers/
│ │ └── user.controller.ts # REST endpoints
│ ├── services/
│ │ └── user.service.ts # Business logic
│ ├── entities/
│ │ └── user.entity.ts # TypeORM entity
│ └── user.module.ts # NestJS module
└── src/index.ts

```

**Regras:**
- ✅ PODE: importar domain (DTOs, interfaces)
- ✅ PODE: usar TypeORM, NestJS
- ❌ NÃO PODE: importar código Angular
- ❌ NÃO PODE: ter dependências frontend

---


### 3.6 Domain Libraries

**Propósito:** Modelos, DTOs, interfaces, enums compartilhados.

```

libs/user/domain/
├── src/lib/
│ ├── dtos/
│ │ ├── user.dto.ts
│ │ ├── create-user.dto.ts
│ │ └── update-user.dto.ts
│ ├── interfaces/
│ │ └── user.interface.ts
│ └── enums/
│ └── user-status.enum.ts
└── src/index.ts

```

**Regras:**
- ✅ PODE: exportar tipos, interfaces, DTOs
- ✅ PODE: usar class-validator (decorators)
- ❌ NÃO PODE: ter lógica de negócio
- ❌ NÃO PODE: importar Angular ou NestJS
- ❌ NÃO PODE: importar outras libs (exceto util)

---

### 3.8 Util Libraries

**Propósito:** Funções puras, helpers, constantes.

```

libs/shared/utils/
├── src/lib/
│ ├── formatters/
│ │ ├── currency.util.ts
│ │ └── date.util.ts
│ ├── validators/
│ │ └── cpf.validator.ts
│ └── constants/
│ └── regex.constants.ts
└── src/index.ts

````

**Regras:**
- ✅ PODE: ter funções puras
- ✅ PODE: exportar constantes
- ❌ NÃO PODE: ter dependências Angular/NestJS
- ❌ NÃO PODE: ter estado
- ❌ NÃO PODE: importar outras libs (exceto util)

---

## 5. Regras de Dependência


### 5.2 Matriz de Dependências Permitidas

| From ↓ / To → | Shell | Feature | Data-Access | Data-Source | Domain | UI | Util |
|---------------|:-----:|:-------:|:-----------:|:-----------:|:------:|:--:|:----:|
| **Shell**     | ❌    | ✅      | ✅          | ❌          | ❌     | ✅ | ✅   |
| **Feature**   | ❌    | ❌      | ✅          | ❌          | ❌     | ✅ | ✅   |
| **Data-Access**| ❌   | ❌      | ❌          | ❌          | ✅     | ❌ | ✅   |
| **Data-Source**| ❌   | ❌      | ❌          | ❌          | ✅     | ❌ | ✅   |
| **Domain**    | ❌    | ❌      | ❌          | ❌          | ❌     | ❌ | ✅   |
| **UI**        | ❌    | ❌      | ❌          | ❌          | ❌     | ✅ | ✅   |
| **Util**      | ❌    | ❌      | ❌          | ❌          | ❌     | ❌ | ✅   |

---

## 6. Path Aliases (tsconfig.base.json)

### 6.1 Padrão de Nomenclatura

```typescript
{
  "paths": {
    // Padrão: @[projeto]/[escopo]/[tipo]
    "@project/admin/data-access": ["libs/admin/data-access/src/index.ts"],
    "@project/admin/feature-dashboard": ["libs/admin/feature-dashboard/src/index.ts"],

    // Domínios seguem mesmo padrão
    "@project/user/domain": ["libs/user/domain/src/index.ts"],
    "@project/user/data-access": ["libs/user/data-access/src/index.ts"],
    "@project/user/data-source": ["libs/user/data-source/src/index.ts"],

    // Shared
    "@project/shared/ui-components": ["libs/shared/ui-components/src/index.ts"],
    "@project/shared/utils": ["libs/shared/utils/src/index.ts"],

    // Web shell
    "@project/web/shell": ["libs/web/shell/src/index.ts"]
  }
}
````

---

## 7. Tags para Enforce Module Boundaries

### 7.1 Definição de Tags

Cada lib deve ter tags em seu `project.json`:

```json
// libs/admin/feature-dashboard/project.json
{
  "tags": ["scope:admin", "type:feature"]
}

// libs/user/data-access/project.json
{
  "tags": ["scope:user", "type:data-access"]
}

// libs/user/domain/project.json
{
  "tags": ["scope:user", "type:domain"]
}
```

---

## 8. Checklist para Criar Nova Lib

### 8.1 Nova Feature

```bash
# nx g @nx/angular:library feature-[name] --directory=libs/[escopo]
nx g @nx/js:library --directory=libs/[entidade]/feature-[name] --bundler=none --linter=eslint --name=[name] --unitTestRunner=jest --minimal=true --tags=type:feature,scope:[escopo]
```

- [ ] Adicionar tags: `scope:[escopo]`, `type:feature`
- [ ] Criar facade local se necessário
- [ ] Importar apenas de data-access e UI
- [ ] NÃO exportar componentes internos

### 8.2 Novo Domínio (Entidade)

```bash
# Criar as 3 libs padrão

nx g @nx/js:library --directory=libs/[entidade]/data-access --bundler=none --linter=eslint --name=utils --unitTestRunner=jest --minimal=true --tags=type:data-access,scope:[entidade]

nx g @nx/js:library --directory=libs/[entidade]/domain --bundler=none --linter=eslint --name=domain --unitTestRunner=jest --minimal=true --tags=type:domain,scope:[entidade]

nx g @nx/js:library --directory=libs/[entidade]/data-source --bundler=none --linter=eslint --name=data-source --unitTestRunner=jest --minimal=true --tags=type:data-source,scope:[entidade]
```

- [ ] Criar DTOs e interfaces em domain
- [ ] Criar facade e repository em data-access (facade em /application e repository em /infrastructure)
- [ ] Criar controller/service em data-source
- [ ] Adicionar tags corretas em cada lib

### 8.3 Nova UI Lib

```bash
nx g @nx/angular:library [name] --directory=libs/shared/ui-[name]
```

- [ ] Adicionar tags: `scope:shared`, `type:ui`
- [ ] Componentes DEVEM ser presentational (dumb)
- [ ] NÃO injetar serviços
- [ ] Usar apenas Input/Output

---

## 🎭 State Management: Facade Pattern

All component logic and state management **MUST** be handled through the **Facade Pattern**. Components should be "dumb" (presentational) and only consume and display data from facades.

### Facade Responsibilities

Facades are responsible for:

- ✅ Managing component state (using signals or state management)
- ✅ Handling business logic
- ✅ Orchestrating API calls via data-access services
- ✅ Exposing observables/signals for components to consume
- ✅ Coordinating multiple data sources if needed

### Component Responsibilities

Components **must**:

- ✅ Be presentational only (dumb/stateless)
- ✅ Subscribe to facade observables/signals
- ✅ Emit user actions back to the facade
- ✅ Contain minimal to no business logic
- ✅ Focus solely on template rendering and user interaction

---

## ✅ Best Practices Checklist

### When Creating New Feature

- [ ] Create facade in data-access library
- [ ] Facade handles all business logic
- [ ] Component only renders and emits events
- [ ] Facade uses data-access services (not API directly)
- [ ] Component tests mock facade
- [ ] Facade tests mock data-access

### When Creating New Library

- [ ] Tag library with correct type (`type:feature`, `type:ui`, etc.)
- [ ] Verify dependencies follow rules
- [ ] Run `nx lint` to check for violations
- [ ] Document library purpose in README

### Code Review Checklist

- [ ] No business logic in components
- [ ] Components use facade pattern
- [ ] Dependency graph follows rules
- [ ] No circular dependencies
- [ ] Tests follow separation (facade vs component)

## 9. Comments Policy

### 9.1 Forbidden Comments

```typescript
// FORBIDDEN - obvious comments
const count = 0; // initialize count to zero

// FORBIDDEN - changelog comments
// Changed by John on 2024-01-15
// Modified to fix bug #123

// FORBIDDEN - commented-out code
// function oldImplementation() { }

// FORBIDDEN - closing brace comments
} // end if
} // end for
} // end class
```

### 9.2 Allowed Comments

```typescript
// ALLOWED - TODO with ticket reference
// TODO(TICKET-123): Implement retry logic

// ALLOWED - public API documentation (JSDoc)
/**
 * Calculates compound interest.
 * @param principal - Initial investment amount
 * @param rate - Annual interest rate (decimal)
 * @param periods - Number of compounding periods
 * @returns Final amount after interest
 */
function calculateCompoundInterest(principal: number, rate: number, periods: number): number {
  return principal * Math.pow(1 + rate, periods);
}
```
