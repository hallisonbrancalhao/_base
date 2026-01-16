# Codebase Structure

**Analysis Date:** 2026-01-16

## Directory Layout

```
_base/
├── apps/                   # Deployable applications
│   ├── api/                # NestJS backend application
│   │   ├── src/
│   │   │   ├── app/        # App module, controller, service
│   │   │   ├── assets/     # Static assets
│   │   │   └── main.ts     # Entry point
│   │   └── project.json    # Nx project config
│   └── web/                # Angular frontend application
│       ├── public/         # Static public assets
│       ├── src/
│       │   ├── app/        # Root component, config, routes
│       │   ├── environments/# Environment configs
│       │   ├── l18n/       # Translation files
│       │   └── locale/     # Angular locale data
│       ├── theme.ts        # PrimeNG theme configuration
│       └── project.json    # Nx project config
├── libs/                   # Shared libraries (by scope)
│   └── shared/             # Cross-cutting shared code
│       └── utils/          # Utility functions and tokens
│           └── src/
│               ├── tokens/ # Angular injection tokens
│               └── index.ts# Barrel export
├── .agent/                 # AI assistant documentation
│   ├── Agents/             # Agent configurations
│   ├── System/             # Technical documentation
│   ├── Tasks/              # PRDs and plans
│   └── SOPs/               # Standard procedures
├── .claude/                # Claude Code configuration
│   ├── agents/             # Custom agents
│   ├── commands/           # Slash commands
│   ├── hooks/              # Pre/post hooks
│   └── skills/             # Skill definitions
├── .planning/              # Planning documentation
│   └── codebase/           # Codebase analysis docs
├── .github/                # GitHub workflows
│   └── workflows/          # CI/CD pipelines
├── .husky/                 # Git hooks
├── .vscode/                # VS Code settings
├── nx.json                 # Nx workspace config
├── tsconfig.base.json      # Base TypeScript config
├── package.json            # Dependencies and scripts
└── eslint.config.mjs       # ESLint configuration
```

## Directory Purposes

**apps/:**
- Purpose: Deployable application targets
- Contains: Angular web app, NestJS API
- Key files: `apps/web/src/main.ts`, `apps/api/src/main.ts`

**apps/web/:**
- Purpose: Angular 21 frontend application
- Contains: Root component, routing, environment configs
- Key files:
  - `src/main.ts` - Bootstrap entry
  - `src/app/app.ts` - Root component
  - `src/app/app.config.ts` - App providers
  - `src/app/app.routes.ts` - Route definitions
  - `theme.ts` - PrimeNG theme preset

**apps/api/:**
- Purpose: NestJS 11 backend application
- Contains: Modules, controllers, services
- Key files:
  - `src/main.ts` - NestJS bootstrap
  - `src/app/app.module.ts` - Root module
  - `src/app/app.controller.ts` - Root controller
  - `src/app/app.service.ts` - Root service

**libs/:**
- Purpose: Shared code organized by scope
- Contains: Domain libraries, utilities, UI components
- Key pattern: `libs/[scope]/[type]/`

**libs/shared/utils/:**
- Purpose: Cross-cutting utility code
- Contains: Injection tokens, helpers, formatters
- Key files:
  - `src/index.ts` - Barrel export
  - `src/tokens/site-url.ts` - SITE_URL injection token

**.agent/:**
- Purpose: AI assistant documentation and rules
- Contains: Architecture docs, best practices, SOPs
- Key files:
  - `README.md` - Quick reference
  - `System/libs_architecture_pattern.md` - Lib structure rules
  - `System/nx_architecture_rules.md` - Dependency rules

## Key File Locations

**Entry Points:**
- `apps/web/src/main.ts`: Angular app bootstrap
- `apps/api/src/main.ts`: NestJS app bootstrap

**Configuration:**
- `nx.json`: Nx workspace settings, plugins
- `tsconfig.base.json`: TypeScript paths, compiler options
- `package.json`: Dependencies, npm scripts
- `apps/web/project.json`: Web app build/serve targets
- `apps/api/project.json`: API app build/serve targets

**Core Logic:**
- `apps/web/src/app/app.config.ts`: Angular providers setup
- `apps/web/src/app/app.routes.ts`: Route definitions
- `apps/api/src/app/app.module.ts`: NestJS root module

**Environment:**
- `apps/web/src/environments/environment.ts`: Development config
- `apps/web/src/environments/environment.prod.ts`: Production config
- `apps/web/src/environments/environment.hml.ts`: Homolog config
- `apps/web/src/environments/environment.factory.ts`: Config factory

**Testing:**
- `apps/web/jest.config.cts`: Web app Jest config
- `apps/api/jest.config.cts`: API Jest config
- `libs/shared/utils/jest.config.cts`: Utils lib Jest config

**Styling:**
- `apps/web/src/styles.css`: Global styles
- `apps/web/theme.ts`: PrimeNG theme customization

## Naming Conventions

**Files:**
- Components: `[name].ts` (standalone), `[name].html` (template)
- Services: `[name].service.ts`
- Facades: `[name].facade.ts`
- DTOs: `[name].dto.ts`
- Interfaces: `[name].interface.ts`
- Enums: `[name].enum.ts` or `[name]-status.enum.ts`
- Tokens: `[name].ts` (InjectionToken exports)
- Tests: `[name].spec.ts`

**Directories:**
- Scopes: lowercase, singular (`user/`, `admin/`, `shared/`)
- Lib types: lowercase, hyphenated (`data-access/`, `data-source/`)
- Features: `feature-[name]/`
- UI libs: `ui-[name]/`
- Util libs: `utils/` or `util-[name]/`

**Path Aliases:**
- Pattern: `@[scope]/[lib]` or `@[scope]/[lib]/*`
- Examples:
  - `@shared/utils` - Barrel import
  - `@shared/utils/tokens/site-url` - Direct import (preferred)

## Where to Add New Code

**New Feature (e.g., dashboard):**
- Create lib: `libs/admin/feature-dashboard/`
- Primary code: `libs/admin/feature-dashboard/src/lib/`
- Tests: `libs/admin/feature-dashboard/src/lib/*.spec.ts`
- Tag: `type:feature`, `scope:admin`

**New Domain Entity (e.g., user):**
- Domain lib: `libs/user/domain/` (DTOs, interfaces)
- Data-access lib: `libs/user/data-access/` (facades, repositories)
- Data-source lib: `libs/user/data-source/` (controllers, services)
- Tags: `type:domain`, `type:data-access`, `type:data-source`, `scope:user`

**New UI Component:**
- Location: `libs/shared/ui-[name]/`
- Pattern: Presentational only, Input/Output signals
- Tag: `type:ui`, `scope:shared`

**New Utility Function:**
- Location: `libs/shared/utils/src/lib/[category]/`
- Export in: `libs/shared/utils/src/index.ts`
- Pattern: Pure function, no framework dependencies

**New Injection Token:**
- Location: `libs/shared/utils/src/tokens/`
- Pattern: Export InjectionToken, provide in app.config.ts

**New API Endpoint:**
- Controller: `apps/api/src/app/` or `libs/[scope]/data-source/`
- Service: Co-located with controller
- Module: Register in AppModule or feature module

## Special Directories

**node_modules/:**
- Purpose: NPM dependencies
- Generated: Yes
- Committed: No (in .gitignore)

**dist/:**
- Purpose: Build output
- Generated: Yes (by nx build)
- Committed: No

**.nx/:**
- Purpose: Nx cache and workspace data
- Generated: Yes
- Committed: No

**.angular/:**
- Purpose: Angular build cache
- Generated: Yes
- Committed: No

**.husky/:**
- Purpose: Git hooks (commit-msg, pre-commit)
- Generated: No (configured)
- Committed: Yes

## Library Creation Commands

```bash
# New feature library
nx g @nx/angular:library feature-[name] --directory=libs/[scope] --standalone

# New domain library (types only)
nx g @nx/js:library --directory=libs/[entity]/domain --bundler=none

# New data-access library
nx g @nx/angular:library data-access --directory=libs/[entity] --standalone

# New data-source library (NestJS)
nx g @nx/nest:library data-source --directory=libs/[entity]

# New UI library
nx g @nx/angular:library ui-[name] --directory=libs/shared --standalone

# New util library
nx g @nx/js:library --directory=libs/shared/utils --bundler=none
```

## Project Tags

Each library must have tags in `project.json`:

```json
{
  "tags": ["type:[type]", "scope:[scope]"]
}
```

**Type tags:** `shell`, `feature`, `data-access`, `data-source`, `domain`, `ui`, `util`

**Scope tags:** Application scope (`admin`, `public`) or domain scope (`user`, `product`)

---

*Structure analysis: 2026-01-16*
