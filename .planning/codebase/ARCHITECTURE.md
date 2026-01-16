# Architecture

**Analysis Date:** 2026-01-16

## Pattern Overview

**Overall:** Nx Monorepo with Layered Architecture (Angular Frontend + NestJS Backend)

**Key Characteristics:**
- Monorepo managed by Nx with strict module boundaries
- Full-stack TypeScript (Angular 21 + NestJS 11)
- Layered library architecture with enforced dependency rules
- Facade Pattern for state management
- Standalone Angular components with signals

## Layers

**Shell Layer:**
- Purpose: Application bootstrap and route orchestration
- Location: `libs/[scope]/shell/` (to be created)
- Contains: Route configurations, layout shells
- Depends on: Feature, Data-Access, UI, Util
- Used by: Application entry points

**Feature Layer:**
- Purpose: Smart components, pages, feature-specific logic
- Location: `libs/[scope]/feature-*/`
- Contains: Components with facades, pages, local components
- Depends on: Data-Access, UI, Util
- Used by: Shell, routes

**Data-Access Layer:**
- Purpose: State management, facades, repositories (Frontend)
- Location: `libs/[scope]/data-access/`
- Contains: Facades with signals, repositories, guards
- Depends on: Domain, Util
- Used by: Features

**Data-Source Layer:**
- Purpose: Backend services, controllers, entities (NestJS)
- Location: `libs/[scope]/data-source/`
- Contains: Controllers, services, entities, NestJS modules
- Depends on: Domain, Util
- Used by: API application

**Domain Layer:**
- Purpose: DTOs, interfaces, enums shared between frontend/backend
- Location: `libs/[scope]/domain/`
- Contains: TypeScript interfaces, DTOs with class-validator
- Depends on: Util only
- Used by: Data-Access, Data-Source

**UI Layer:**
- Purpose: Presentational (dumb) components
- Location: `libs/shared/ui-*/`
- Contains: Reusable visual components, no business logic
- Depends on: Other UI, Util
- Used by: Features, Shell

**Util Layer:**
- Purpose: Pure functions, helpers, constants
- Location: `libs/shared/utils/`
- Contains: Formatters, validators, constants, injection tokens
- Depends on: Other Util only
- Used by: All layers

## Data Flow

**Frontend Request Flow:**

1. User interacts with Component (presentational)
2. Component calls Facade method
3. Facade orchestrates Repository (in Data-Access)
4. Repository makes HTTP call to API
5. Response transforms through Domain DTOs
6. Facade updates signal state
7. Component re-renders via signal subscription

**Backend Request Flow:**

1. HTTP request arrives at NestJS
2. Controller receives and validates (via DTOs)
3. Service processes business logic
4. Entity interacts with database
5. Response serialized through DTOs
6. HTTP response returned

**State Management:**
- Angular Signals for reactive state in Facades
- Computed signals for derived state
- No NgRx/BehaviorSubject - pure signals approach

## Key Abstractions

**Facade Pattern:**
- Purpose: Encapsulate all business logic and state
- Examples: `libs/[scope]/data-access/src/lib/facades/`
- Pattern: Injectable service with private signal state, public computed signals, action methods

**Repository Pattern:**
- Purpose: Abstract HTTP/data access from business logic
- Examples: `libs/[scope]/data-access/src/lib/repositories/`
- Pattern: Injectable service wrapping HttpClient

**Injection Tokens:**
- Purpose: Environment-specific configuration
- Examples: `libs/shared/utils/src/tokens/site-url.ts`
- Pattern: InjectionToken with value provided in app.config.ts

## Entry Points

**Web Application:**
- Location: `apps/web/src/main.ts`
- Triggers: Browser loads index.html
- Responsibilities: Bootstrap Angular app with appConfig

**API Application:**
- Location: `apps/api/src/main.ts`
- Triggers: Node process starts
- Responsibilities: Create NestJS app, set global prefix, listen on port

**App Configuration:**
- Location: `apps/web/src/app/app.config.ts`
- Triggers: During Angular bootstrap
- Responsibilities: Configure providers, router, PrimeNG theme, locale

## Error Handling

**Strategy:** Try-catch in Facades with error signals

**Patterns:**
- Facades catch errors and set error state signals
- Components display error state from facade
- No error handling in presentational components

**Example Flow:**
```typescript
// In Facade
try {
  const data = await this.repository.getData();
  this.dataState.set(data);
} catch (error) {
  this.errorState.set('Failed to load data');
}
```

## Cross-Cutting Concerns

**Logging:**
- Backend: NestJS Logger (`Logger.log()`)
- Frontend: console for development only

**Validation:**
- Backend: class-validator decorators on DTOs in data-source
- Frontend: Angular reactive forms with validators

**Authentication:**
- Configuration prepared for Google OAuth and reCAPTCHA
- Auth token storage via localStorage keys defined in environment

**Theming:**
- PrimeNG with custom Aura preset
- Dark mode via `.p-dark` class toggle
- Theme preference stored in localStorage

**Internationalization:**
- Angular LOCALE_ID set to pt-BR
- PrimeNG translation configured via providePrimeNG
- Translation files in `apps/web/src/l18n/`

## Dependency Matrix

| From / To     | Shell | Feature | Data-Access | Data-Source | Domain | UI | Util |
|---------------|:-----:|:-------:|:-----------:|:-----------:|:------:|:--:|:----:|
| Shell         |   -   |    Y    |      Y      |      -      |   -    | Y  |  Y   |
| Feature       |   -   |    -    |      Y      |      -      |   -    | Y  |  Y   |
| Data-Access   |   -   |    -    |      -      |      -      |   Y    | -  |  Y   |
| Data-Source   |   -   |    -    |      -      |      -      |   Y    | -  |  Y   |
| Domain        |   -   |    -    |      -      |      -      |   -    | -  |  Y   |
| UI            |   -   |    -    |      -      |      -      |   -    | Y  |  Y   |
| Util          |   -   |    -    |      -      |      -      |   -    | -  |  Y   |

---

*Architecture analysis: 2026-01-16*
