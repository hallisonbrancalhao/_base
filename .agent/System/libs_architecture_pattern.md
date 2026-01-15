# Libs Architecture Pattern - Nx Monorepo

**Version**: 1.0.0
**Last Update**: 2025-01-11

---

## 1. Conceitos Fundamentais

### 1.1 O que é ESCOPO (Scope)?

**ESCOPO** é um **diretório de primeiro nível** dentro de `libs/` que agrupa bibliotecas relacionadas por contexto, funcionalidade ou domínio de negócio.

```
libs/
├── admin/        ← ESCOPO (agrupa libs do painel admin)
├── auth/         ← ESCOPO (agrupa libs de autenticação)
├── public/       ← ESCOPO (agrupa libs de páginas públicas)
└── shared/       ← ESCOPO (agrupa libs compartilhadas)
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
├── data-access/      ← LIB (biblioteca real)
│   ├── project.json  ← Configuração Nx
│   ├── src/
│   │   ├── index.ts  ← Public API
│   │   └── lib/      ← Código fonte
│   └── tsconfig.json
├── data-source/    ← LIB (biblioteca real)
│   ├── project.json
│   ├── src/
│   │   ├── index.ts
│   │   └── lib/
│   └── tsconfig.json
├── feature-dashboard/  ← LIB
└── feature-users/      ← LIB
```

**Características da LIB:**
- TEM `project.json` (configuração Nx)
- TEM `src/index.ts` (public API)
- TEM path alias em `tsconfig.base.json`
- PODE ser importada: `import { X } from '@project/admin/data-access'`

---

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
├── data-access/         # Facades e serviços
├── data-source/         # Fontes de dados backend / DTOs com class-validator - sempre implementando as interfaces do domain
├── domain/              # DTOs, Interfaces, Enums
├── ui-components/      # Componentes UI (opcional)
├── utils/               # Utilitários (opcional)
├── feature-shell/       # Shell de rotas (opcional)
├── feature-[name]/      # Features/páginas
└── ...                  # Outras libs de features ou outros.
```

---

### 2.2 Escopos de Domínio (Domain Scopes)

Agrupam libs relacionadas a uma **entidade de negócio** do sistema.

| Escopo | Entidade | Frontend + Backend |
|--------|----------|-------------------|
| `user/` | Usuário | `data-access`, `data-source`, `domain` |
| `product/` | Produto | `data-access`, `data-source`, `domain` |
| `lead/` | Lead | `data-access`, `data-source`, `domain`, `feature-*` |

**Estrutura padrão:**
```
libs/[escopo-dominio]/
├── data-access/         # Frontend: Facades, Repositories
├── data-source/         # Backend: Controllers, Services, Entities, / DTOs com class-validator - sempre implementando as interfaces do domain
├── domain/              # Compartilhado: DTOs, Interfaces, Enums
└── feature-[name]/      # (Opcional) Features específicas
```

---

### 2.3 Escopos de Infraestrutura (Infrastructure Scopes) para aplicações compartilhadas

Agrupam libs de suporte técnico e infraestrutura.

| Escopo | Descrição |
|--------|-----------|
| `shared/` | Código compartilhado entre todos os escopos |
| `backend/` | Infraestrutura exclusiva do backend |
| `web/` | Shell e configurações da aplicação web |

**Estrutura `shared/`:**
```
libs/shared/
├── domain/          # Models compartilhados globalmente
├── ui-components/   # Componentes UI reutilizáveis
├── utils/           # Funções utilitárias puras
├── menu/            # Serviço de menu dinâmico
└── offline/         # Suporte offline
```

---

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
│   ├── public-shell.component.ts    # Shell rotas públicas
│   ├── auth-shell.component.ts      # Shell rotas autenticadas
│   └── routes.ts                    # Configuração de rotas
└── src/index.ts
```

**Regras:**
- ✅ PODE: importar features, data-access, UI
- ✅ PODE: definir rotas lazy-loaded
- ❌ NÃO PODE: ter lógica de negócio
- ❌ NÃO PODE: importar domain diretamente

---

### 3.3 Feature Libraries

**Propósito:** Páginas e smart components com lógica de apresentação.

```
libs/admin/feature-users/
├── src/lib/
│   ├── components/
│   │   ├── users-list/
│   │   │   ├── users-list.component.ts
│   │   └── user-detail/
│   └── components/                      # Componentes locais
└── src/index.ts
```

**Regras:**
- ✅ PODE: importar componentes UI
- ✅ PODE: ter componentes locais não exportados
- ✅ PODE: usar facades (de data-access)
- ❌ NÃO PODE: importar outra feature
- ❌ NÃO PODE: fazer HTTP diretamente
- ❌ NÃO PODE: importar domain diretamente

---

### 3.4 Data-Access Libraries

**Propósito:** State management, facades, repositories (Frontend).

```
libs/user/data-access/
├── src/lib/
│   ├── facades/
│   │   └── user.facade.ts           # State management com signals
│   ├── repositories/
│   │   └── user.repository.ts       # Abstração HTTP
│   ├── services/
│   │   └── user-validation.service.ts
│   └── guards/
│       └── user-auth.guard.ts
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
│   ├── controllers/
│   │   └── user.controller.ts       # REST endpoints
│   ├── services/
│   │   └── user.service.ts          # Business logic
│   ├── entities/
│   │   └── user.entity.ts           # TypeORM entity
│   └── user.module.ts               # NestJS module
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
│   ├── dtos/
│   │   ├── user.dto.ts
│   │   ├── create-user.dto.ts
│   │   └── update-user.dto.ts
│   ├── interfaces/
│   │   └── user.interface.ts
│   └── enums/
│       └── user-status.enum.ts
└── src/index.ts
```

**Regras:**
- ✅ PODE: exportar tipos, interfaces, DTOs
- ✅ PODE: usar class-validator (decorators)
- ❌ NÃO PODE: ter lógica de negócio
- ❌ NÃO PODE: importar Angular ou NestJS
- ❌ NÃO PODE: importar outras libs (exceto util)

---

### 3.7 UI Libraries

**Propósito:** Componentes visuais reutilizáveis (dumb/presentational).

```
libs/shared/ui-components/
├── src/lib/
│   ├── header/
│   │   └── header.component.ts
│   ├── footer/
│   │   └── footer.component.ts
│   └── buttons/
│       └── action-button.component.ts
└── src/index.ts
```

**Regras:**
- ✅ PODE: receber inputs, emitir outputs
- ✅ PODE: importar outras libs UI
- ✅ PODE: usar PrimeNG, Tailwind
- ❌ NÃO PODE: injetar services
- ❌ NÃO PODE: ter estado interno complexo
- ❌ NÃO PODE: fazer HTTP

---

### 3.8 Util Libraries

**Propósito:** Funções puras, helpers, constantes.

```
libs/shared/utils/
├── src/lib/
│   ├── formatters/
│   │   ├── currency.util.ts
│   │   └── date.util.ts
│   ├── validators/
│   │   └── cpf.validator.ts
│   └── constants/
│       └── regex.constants.ts
└── src/index.ts
```

**Regras:**
- ✅ PODE: ter funções puras
- ✅ PODE: exportar constantes
- ❌ NÃO PODE: ter dependências Angular/NestJS
- ❌ NÃO PODE: ter estado
- ❌ NÃO PODE: importar outras libs (exceto util)

---

## 5. Regras de Dependência

### 5.1 Diagrama de Dependências

```
                    ┌─────────────────────────────────────────┐
                    │                  SHELL                   │
                    │            (web/shell)                   │
                    └─────────────────┬───────────────────────┘
                                      │
                    ┌─────────────────▼───────────────────────┐
                    │               FEATURES                   │
                    │    (admin/feature-*, public/feature-*)   │
                    └─────────────────┬───────────────────────┘
                                      │
          ┌───────────────────────────┼───────────────────────┐
          │                           │                       │
┌─────────▼─────────┐    ┌────────────▼────────────┐    ┌─────▼─────┐
│   DATA-ACCESS     │    │          UI             │    │   UTIL    │
│ (*/data-access)   │    │ (shared/ui-components)  │    │(shared/*) │
└─────────┬─────────┘    └─────────────────────────┘    └───────────┘
          │          
          │          
          │          
┌─────────▼─────────┐
│      DOMAIN       │
│   (*/domain)      │
└───────────────────┘
```

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
```

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

### 7.2 Configuração ESLint

```json
{
  "@nx/enforce-module-boundaries": [
    "error",
    {
      "depConstraints": [
        {
          "sourceTag": "type:shell",
          "onlyDependOnLibsWithTags": ["type:feature", "type:data-access", "type:ui", "type:util"]
        },
        {
          "sourceTag": "type:feature",
          "onlyDependOnLibsWithTags": ["type:data-access", "type:ui", "type:util"]
        },
        {
          "sourceTag": "type:data-access",
          "onlyDependOnLibsWithTags": ["type:domain", "type:util"]
        },
        {
          "sourceTag": "type:data-source",
          "onlyDependOnLibsWithTags": ["type:domain", "type:util"]
        },
        {
          "sourceTag": "type:domain",
          "onlyDependOnLibsWithTags": ["type:util"]
        },
        {
          "sourceTag": "type:ui",
          "onlyDependOnLibsWithTags": ["type:ui", "type:util"]
        },
        {
          "sourceTag": "type:util",
          "onlyDependOnLibsWithTags": ["type:util"]
        }
      ]
    }
  ]
}
```

---

## 8. Checklist para Criar Nova Lib

### 8.1 Nova Feature

```bash
nx g @nx/angular:library feature-[name] --directory=libs/[escopo]
```

- [ ] Adicionar tags: `scope:[escopo]`, `type:feature`
- [ ] Criar facade local se necessário
- [ ] Importar apenas de data-access e UI
- [ ] NÃO exportar componentes internos

### 8.2 Novo Domínio (Entidade)

```bash
# Criar as 3 libs padrão
nx g @nx/angular:library data-access --directory=libs/[entidade]
nx g @nx/angular:library domain --directory=libs/[entidade]
nx g @nx/nest:library data-source --directory=libs/[entidade]
```

- [ ] Criar DTOs em domain
- [ ] Criar facade em data-access
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

## 9. Exemplos Práticos

### 9.1 Importações Corretas

```typescript
// ✅ Feature importando data-access
// libs/admin/feature-users/src/lib/pages/users-list.component.ts
import { UserFacade } from '@project/user/data-access';

// ✅ Data-access importando domain
// libs/user/data-access/src/lib/facades/user.facade.ts
import { UserDto, CreateUserDto } from '@project/user/domain';

// ✅ Feature importando UI
// libs/admin/feature-users/src/lib/pages/users-list.component.ts
import { DataTableComponent } from '@project/shared/ui-components';

// ✅ Qualquer lib importando util
import { formatCpf } from '@project/shared/utils';
```

### 9.2 Importações Proibidas

```typescript
// ❌ Feature importando outra feature
import { DashboardComponent } from '@project/admin/feature-dashboard';

// ❌ Feature importando domain diretamente
import { UserDto } from '@project/user/domain';

// ❌ Data-access importando feature
import { UsersListComponent } from '@project/admin/feature-users';

// ❌ UI importando data-access
import { UserFacade } from '@project/user/data-access';

// ❌ Domain importando data-access
import { UserFacade } from '@project/user/data-access';
```

---

## 10. Resumo Visual

```
┌─────────────────────────────────────────────────────────────────┐
│                         ESCOPOS                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │   APLICAÇÃO  │  │   DOMÍNIO    │  │ INFRAESTRUTURA│          │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤           │
│  │ admin/       │  │ user/        │  │ shared/      │           │
│  │ public/      │  │ tenant/      │  │ backend/     │           │
│  │ client/      │  │ proposal/    │  │ web/         │           │
│  │ simulator/   │  │ product/     │  │              │           │
│  │              │  │ lead/        │  │              │           │
│  │              │  │ rbac/        │  │              │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                          LIBS                                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  shell ──► feature-* ──► data-access ──► domain                 │
│                │              │              │                   │
│                ▼              │              │                   │
│               ui ◄────────────┘              │                   │
│                │                             │                   │
│                ▼                             ▼                   │
│              util ◄──────────────────────────┘                  │
│                                                                  │
│  data-source ──► domain ──► util   (Backend)                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

**Este padrão é replicável para qualquer projeto Nx monorepo Angular/NestJS.**
