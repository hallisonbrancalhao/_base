# Monorepo Architecture (Arquitetura de Monorepo)

## Conceito

Um monorepo e um **unico repositorio** que contem multiplos projetos (apps e bibliotecas) com **build system unificado**, **dependencias compartilhadas** e **tooling consistente**. Diferente de um monolito, cada pacote e independente e pode ser deployado separadamente.

---

## Estrutura de Diretorios

```
monorepo/
├── apps/                          # Aplicacoes deployaveis
│   ├── frontend/                  # Angular app
│   └── server/                    # NestJS app
│
├── packages/                      # Bibliotecas compartilhadas
│   ├── shared/                    # Cross-cutting concerns
│   │   ├── api-interfaces/        # Contratos (types, DTOs)
│   │   ├── data-access/           # Data access compartilhado
│   │   ├── data-source/           # Data source compartilhado
│   │   ├── resource/              # Resource compartilhado
│   │   ├── ui-global/             # Componentes UI reutilizaveis
│   │   ├── util-authn/            # Auth utilities
│   │   ├── util-data/             # DI, store, helpers
│   │   └── util-errors/           # Error handling
│   │
│   ├── {domain}/                  # Dominio de negocio (vertical slice)
│   │   ├── domain/                # Use Cases, Ports, DTOs
│   │   ├── data-access/           # Frontend data management
│   │   ├── data-source/           # Backend data management
│   │   ├── resource/              # Backend API endpoints
│   │   ├── feature-shell/         # Shell routing + layout
│   │   ├── feature-admin/         # Admin pages
│   │   ├── feature-page/          # Public pages
│   │   └── ui-shared/             # Domain-specific UI
│   ...
│
├── tools/                         # Tooling do monorepo
│   └── plugin/                    # Nx generators customizados
│
├── config/                        # Configuracoes compartilhadas
├── docs/                          # Documentacao
├── diagrams/                      # Diagramas de arquitetura
├── assets/                        # Assets e seeds
│
├── nx.json                        # Config do Nx
├── tsconfig.base.json             # Path aliases
├── package.json                   # Dependencias e scripts
├── .eslintrc.json                 # Regras de lint (boundaries)
└── docker-compose.yml             # Ambiente local
```

---

## Vertical Slice por Dominio

Cada dominio e um **slice vertical** completo da aplicacao:

```
packages/career/
├── domain/           → Regras de negocio (Use Cases, Ports)
├── data-access/      → Frontend: Facades, State, Providers
├── data-source/      → Backend: Schemas, Services, DTOs
├── resource/         → Backend: Controllers, Modules
├── feature-shell/    → Frontend: Rotas, Shell
├── feature-admin/    → Frontend: Admin pages
├── feature-page/     → Frontend: Public pages
└── ui-shared/        → Frontend: Componentes especificos
```

**Beneficios**:
- Um dominio pode ser desenvolvido por um time independente
- Adicionar um novo dominio = copiar a estrutura e implementar
- Cada dominio tem suas proprias regras de negocio isoladas

---

## Nx: O Build System

### Affected Commands

Nx detecta quais pacotes foram afetados por mudancas:

```bash
# Executa lint, test e build APENAS nos pacotes afetados
pnpm exec nx affected -t lint test build --parallel=10
```

### Cache

Resultados de build sao cacheados - se nada mudou, nao re-executa:

```json
// nx.json
{
  "targetDefaults": {
    "build": {
      "cache": true,
      "dependsOn": ["^build"]  // Build dependencias primeiro
    },
    "lint": { "cache": true },
    "test": { "cache": true }
  }
}
```

### Dependency Graph

Nx constroi automaticamente o grafo de dependencias baseado nos imports:

```bash
pnpm exec nx graph  # Visualiza o grafo de dependencias
```

### Named Inputs

Definem quais arquivos invalidam o cache:

```json
{
  "namedInputs": {
    "default": ["{projectRoot}/**/*", "sharedGlobals"],
    "production": [
      "default",
      "!{projectRoot}/.eslintrc.json",
      "!{projectRoot}/jest.config.[jt]s",
      "!{projectRoot}/**/?(*.)+(spec|test).[jt]s?(x)"
    ],
    "sharedGlobals": ["{workspaceRoot}/.github/workflows/ci.yml"]
  }
}
```

---

## Path Aliases (tsconfig.base.json)

Cada pacote tem um alias que abstrai sua localizacao fisica:

```json
{
  "compilerOptions": {
    "paths": {
      "@devmx/career-domain":          ["packages/career/domain/src/index.ts"],
      "@devmx/career-data-access":     ["packages/career/data-access/src/index.ts"],
      "@devmx/career-data-source":     ["packages/career/data-source/src/index.ts"],
      "@devmx/career-resource":        ["packages/career/resource/src/index.ts"],
      "@devmx/career-feature-shell":   ["packages/career/feature-shell/src/index.ts"],
      "@devmx/career-feature-admin":   ["packages/career/feature-admin/src/index.ts"],
      "@devmx/career-ui-shared":       ["packages/career/ui-shared/src/index.ts"]
    }
  }
}
```

**Convencao de nomenclatura**: `@devmx/{scope}-{layer}`

### Sub-entry Points

Pacotes podem ter multiplos entry points:

```json
{
  "@devmx/shared-api-interfaces":         ["...src/index.ts"],
  "@devmx/shared-api-interfaces/client":  ["...src/client.ts"],
  "@devmx/shared-api-interfaces/server":  ["...src/server.ts"]
}
```

---

## Package.json por Pacote

Cada pacote tem seu proprio `project.json` (Nx) com configuracao de build:

```json
{
  "name": "career-domain",
  "sourceRoot": "packages/career/domain/src",
  "projectType": "library",
  "tags": ["scope:career", "type:domain"],
  "targets": {
    "build": {
      "executor": "@nx/js:tsc",
      "options": {
        "outputPath": "dist/packages/career/domain",
        "tsConfig": "packages/career/domain/tsconfig.lib.json"
      }
    },
    "test": {
      "executor": "@nx/jest:jest",
      "options": {
        "jestConfig": "packages/career/domain/jest.config.ts"
      }
    },
    "lint": {
      "executor": "@nx/eslint:lint"
    }
  }
}
```

---

## Composicao de Aplicacao

### Backend (server)

```typescript
// apps/server/src/app.module.ts
@Module({
  imports: [
    // Infraestrutura compartilhada
    SharedResourceModule.forRoot(env),
    SharedDatabaseModule,
    SharedMailerModule,

    // Cada dominio registra seus controllers e providers
    AccountResourceModule,
    AcademyResourceModule,
    AlbumResourceModule,
    CareerResourceModule,
    EventResourceModule,
    LearnResourceModule,
    LocationResourceModule,
    PresentationResourceModule,
  ],
})
export class AppModule {}
```

### Frontend (app)

```typescript
// apps/devmx/src/app/app.config.ts
export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(appRoutes, withViewTransitions(), withHashLocation()),
    provideHttpClient(withInterceptors([authInterceptor, loaderInterceptor])),

    // Providers de cada dominio
    ...provideAccount(),
    ...provideCareer(),
    ...provideEvent(),
    ...provideAlbum(),
  ],
};
```

---

## Scripts de Desenvolvimento

```json
{
  "scripts": {
    "dev": "concurrently \"docker:compose:only:mongo\" \"nx run-many -t serve --projects=server,devmx\"",
    "affected": "nx affected -t lint test build",
    "lint:fix": "nx run-many -t lint --fix",
    "commit": "cz"
  }
}
```

---

## Adicionar Novo Dominio

Para adicionar um novo dominio (ex: `blog`):

1. **Criar a estrutura de pacotes**:
   ```
   packages/blog/domain/
   packages/blog/data-access/
   packages/blog/data-source/
   packages/blog/resource/
   packages/blog/feature-shell/
   ```

2. **Tagar cada pacote**:
   ```json
   { "tags": ["scope:blog", "type:domain"] }
   ```

3. **Adicionar path aliases** no `tsconfig.base.json`

4. **Registrar no app** (AppModule/appConfig)

5. **Ou usar o Nx Generator customizado**:
   ```bash
   nx generate @devmx/dx-dev:entity blog
   ```

---

## Como Aplicar em Qualquer Projeto

1. **Separe apps de packages** - apps consomem, packages fornecem
2. **Crie um scope por dominio** com vertical slice completo
3. **Use shared para cross-cutting** - tipos, UI, utilities
4. **Configure path aliases** com convencao consistente (`@org/scope-layer`)
5. **Tague pacotes** para enforcement de boundaries
6. **Use build caching** - so re-builda o que mudou
7. **Crie generators** para automatizar criacao de novos dominios
8. **Barrel exports** controlam API publica de cada pacote
