# Module Boundaries (Fronteiras de Modulo)

## Conceito

Module Boundaries e a tecnica de **enforcement automatizado** das regras de dependencia entre camadas. Em vez de confiar em convencao (documentacao, code review), as regras sao codificadas e verificadas pelo linter em cada commit.

---

## Tagging System

Cada pacote no monorepo recebe **tags** que classificam seu escopo e tipo:

```json
// packages/career/domain/project.json
{
  "tags": ["scope:career", "type:domain"]
}

// packages/shared/ui-global/project.json
{
  "tags": ["scope:shared", "type:ui"]
}

// apps/server/project.json
{
  "tags": ["scope:server", "type:app"]
}
```

**Duas dimensoes de tags**:
- `scope:X` - A qual dominio o pacote pertence (career, account, shared, etc.)
- `type:X` - Qual camada arquitetural (domain, data, feature, resource, ui, api, util, app)

---

## Matriz de Dependencias Permitidas

A regra central: **quem pode importar de quem**.

```
Camada que IMPORTA  │  Pode importar DE:
────────────────────┼──────────────────────────────────
type:api            │  type:api
type:util           │  type:api, type:util
type:domain         │  type:api, type:util, type:domain
type:data           │  type:api, type:util, type:domain, type:data
type:ui             │  type:api, type:util, type:ui
type:feature        │  type:api, type:util, type:data, type:ui, type:feature
type:resource       │  type:api, type:util, type:data, type:resource
type:app            │  type:api, type:util, type:data, type:ui, type:feature, type:resource
```

### Regras Criticas (O que NAO pode)

| Proibido | Motivo |
|----------|--------|
| `domain` → `data` | Dominio nao conhece infraestrutura |
| `domain` → `feature` | Dominio nao conhece UI |
| `domain` → `resource` | Dominio nao conhece controllers |
| `ui` → `data` | UI puro nao acessa dados diretamente |
| `ui` → `domain` | UI puro nao conhece regras de negocio |
| `ui` → `feature` | UI reutilizavel nao depende de features |
| `feature` → `resource` | Frontend nao importa backend |
| `resource` → `feature` | Backend nao importa frontend |
| `resource` → `ui` | Backend nao importa componentes UI |

---

## Configuracao ESLint

```json
{
  "rules": {
    "@nx/enforce-module-boundaries": [
      "error",
      {
        "enforceBuildableLibDependsOnBuildableLib": true,
        "allow": [],
        "depConstraints": [
          {
            "sourceTag": "type:api",
            "onlyDependOnLibsWithTags": ["type:api"]
          },
          {
            "sourceTag": "type:util",
            "onlyDependOnLibsWithTags": ["type:api", "type:util"]
          },
          {
            "sourceTag": "type:domain",
            "onlyDependOnLibsWithTags": ["type:api", "type:util", "type:domain"]
          },
          {
            "sourceTag": "type:data",
            "onlyDependOnLibsWithTags": ["type:api", "type:util", "type:domain", "type:data"]
          },
          {
            "sourceTag": "type:ui",
            "onlyDependOnLibsWithTags": ["type:api", "type:util", "type:ui"]
          },
          {
            "sourceTag": "type:feature",
            "onlyDependOnLibsWithTags": [
              "type:api", "type:util", "type:data", "type:ui", "type:feature"
            ]
          },
          {
            "sourceTag": "type:resource",
            "onlyDependOnLibsWithTags": [
              "type:api", "type:util", "type:data", "type:resource"
            ]
          },
          {
            "sourceTag": "type:app",
            "onlyDependOnLibsWithTags": [
              "type:api", "type:util", "type:data", "type:ui",
              "type:feature", "type:resource"
            ]
          }
        ]
      }
    ]
  }
}
```

---

## Visualizacao da Hierarquia

```
                    ┌─────────┐
                    │   APP   │  Pode importar tudo
                    └────┬────┘
              ┌──────────┼──────────┐
        ┌─────▼─────┐         ┌────▼─────┐
        │  FEATURE  │         │ RESOURCE │  Frontend / Backend
        └─────┬─────┘         └────┬─────┘
         ┌────┼────┐               │
    ┌────▼──┐ │ ┌──▼──┐      ┌────▼────┐
    │  UI   │ │ │ DATA │      │  DATA   │  Apresentacao / Dados
    └───┬───┘ │ └──┬───┘      └────┬────┘
        │     │    │               │
        │     │ ┌──▼──────────────▼─┐
        │     │ │      DOMAIN       │  Regras de negocio
        │     │ └────────┬──────────┘
        │     │          │
        └─────┼──────────┤
              │     ┌────▼────┐
              │     │  UTIL   │  Utilitarios puros
              │     └────┬────┘
              │          │
              └──────────┤
                    ┌────▼────┐
                    │   API   │  Contratos e tipos
                    └─────────┘
```

---

## Excecoes Controladas

Em casos especificos, excecoes sao explicitamente permitidas:

```json
{
  "allow": [
    "@devmx/account-data-access",
    "@devmx/academy-data-access",
    "@devmx/presentation-data-access",
    "@devmx/learn-data-access"
  ]
}
```

Excecoes sao **documentadas e justificadas** - nunca silenciosas.

---

## Scope Boundaries

Alem do tipo, o **escopo** pode restringir dependencias entre dominios:

```
scope:career  →  scope:career, scope:shared    OK
scope:career  →  scope:account                 DEPENDE DA REGRA
scope:career  →  scope:event                   POTENCIALMENTE PROIBIDO
```

**Principio**: Cada dominio deve ser o mais autonomo possivel. Dependencias entre dominios passam pelo `scope:shared`.

---

## Path Aliases como Fronteira

Os path aliases no `tsconfig.base.json` reforcam as fronteiras:

```json
{
  "@devmx/career-domain":       ["packages/career/domain/src/index.ts"],
  "@devmx/career-data-access":  ["packages/career/data-access/src/index.ts"],
  "@devmx/career-data-source":  ["packages/career/data-source/src/index.ts"],
  "@devmx/career-resource":     ["packages/career/resource/src/index.ts"],
  "@devmx/career-feature-shell":["packages/career/feature-shell/src/index.ts"]
}
```

**Barrel exports** (`index.ts`) controlam o que e publico:

```typescript
// packages/career/domain/src/index.ts
export * from './lib/dtos';  // Apenas DTOs sao publicos
// Use cases exportados via client.ts e server.ts separados
```

---

## Split Client/Server

Uma fronteira adicional: separar exports de frontend e backend no mesmo pacote:

```json
{
  "@devmx/shared-api-interfaces":        ["packages/shared/api-interfaces/src/index.ts"],
  "@devmx/shared-api-interfaces/client": ["packages/shared/api-interfaces/src/client.ts"],
  "@devmx/shared-api-interfaces/server": ["packages/shared/api-interfaces/src/server.ts"]
}
```

- Frontend importa de `@devmx/shared-api-interfaces/client`
- Backend importa de `@devmx/shared-api-interfaces/server`
- Ambos podem importar de `@devmx/shared-api-interfaces` (compartilhado)

---

## Como Funciona no CI

```yaml
# .github/workflows/ci.yml
- run: pnpm exec nx affected -t lint test build --parallel=10
```

1. `nx affected` detecta quais pacotes mudaram
2. `lint` executa ESLint com `@nx/enforce-module-boundaries`
3. Se alguem importou de uma camada proibida → **build falha**
4. PR nao pode ser mergeado com violacao de fronteira

---

## Como Aplicar em Qualquer Projeto

1. **Defina suas camadas** (api, domain, data, feature, ui, resource, util, app)
2. **Tague cada pacote** com `scope:X` e `type:X`
3. **Configure a matriz de dependencias** no ESLint
4. **Use barrel exports** para controlar API publica de cada pacote
5. **Separe client/server** quando um pacote serve ambos
6. **Execute lint no CI** - fronteiras devem ser enforced automaticamente
7. **Documente excecoes** - nunca adicione `allow` sem justificativa
8. **Revise periodicamente** - conforme o projeto cresce, fronteiras podem precisar de ajuste
