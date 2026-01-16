# Coding Conventions

**Analysis Date:** 2026-01-16

## Naming Patterns

**Files:**
- Components: `[name].ts` for component class, `[name].html` for template (e.g., `apps/web/src/app/app.ts`, `apps/web/src/app/app.html`)
- Services: `[name].service.ts` (e.g., `apps/api/src/app/app.service.ts`)
- Controllers: `[name].controller.ts` (e.g., `apps/api/src/app/app.controller.ts`)
- Modules: `[name].module.ts` (e.g., `apps/api/src/app/app.module.ts`)
- Tests: `[name].spec.ts` (e.g., `apps/api/src/app/app.controller.spec.ts`)
- Configuration: `[name].config.ts` (e.g., `apps/web/src/app/app.config.ts`)
- Routes: `[name].routes.ts` (e.g., `apps/web/src/app/app.routes.ts`)
- Tokens: `[name].ts` in `/tokens/` directory (e.g., `libs/shared/utils/src/tokens/site-url.ts`)

**Functions:**
- Use camelCase with verb-first naming: `getData`, `calculateTotal`, `validateUser`
- Boolean functions: Use `is/has/can/should` prefix: `isActive`, `hasPermission`
- Maximum 5 statements per function - refactor if exceeding
- Maximum 3 parameters - use object parameter for more

**Variables:**
- Use camelCase: `currentUser`, `totalAmount`
- Constants: SCREAMING_SNAKE_CASE: `MAX_RETRY_COUNT`, `API_BASE_URL`
- Booleans: `is/has/can/should` prefix: `isLoading`, `hasError`

**Types:**
- Classes: PascalCase: `UserService`, `PaymentGateway`
- Interfaces: PascalCase without prefix: `User`, `ApiResponse`
- Types: PascalCase: `UserId`, `PaymentStatus`
- Enums: PascalCase with PascalCase members: `UserRole.Admin`

## Code Style

**Formatting:**
- Prettier with single quotes enabled
- Config: `.prettierrc` - `{ "singleQuote": true }`
- Run via lint-staged on pre-commit (Husky)

**Linting:**
- ESLint 9.x with flat config format
- Config files: `eslint.config.mjs` (root), per-app configs extend base
- Uses `@nx/eslint-plugin` for Nx workspace rules
- Angular apps include `@angular-eslint` rules
- Key rules:
  - `@nx/enforce-module-boundaries`: Enforces lib dependency constraints
  - `@angular-eslint/directive-selector`: Attribute prefix `app`, camelCase
  - `@angular-eslint/component-selector`: Element prefix `app`, kebab-case

## Import Organization

**Order:**
1. Angular core imports (`@angular/core`, `@angular/common`, etc.)
2. Third-party libraries (`primeng/*`, `rxjs`, etc.)
3. Workspace libs (`@shared/utils`, `@shared/*`, etc.)
4. Relative imports (`./`, `../`)

**Path Aliases:**
- `@shared/utils`: `libs/shared/utils/src/index.ts`
- `@shared/utils/*`: `libs/shared/utils/src/*` (for direct imports)
- Prefer direct imports over barrel imports for performance

**Pattern:**
```typescript
// Angular imports
import { Component, input, output } from '@angular/core';

// PrimeNG imports
import { ButtonModule } from 'primeng/button';

// Shared imports
import { SITE_URL } from '@shared/utils/tokens/site-url';

// Component imports
import { HeaderComponent } from './header.component';
```

## Error Handling

**Patterns:**
- Use custom error classes for domain exceptions:
  ```typescript
  class ValidationError extends Error {
    constructor(message: string, public readonly field: string) {
      super(message);
      this.name = 'ValidationError';
    }
  }
  ```
- Use Result pattern for explicit error handling
- Early returns to avoid deep nesting
- NestJS uses built-in exception filters

## Logging

**Framework:**
- Backend: `@nestjs/common` Logger
- Frontend: `console.error` for error handling in bootstrap

**Patterns:**
- Backend: `Logger.log()` for application startup and key events
- Frontend: Minimal logging, primarily for bootstrap errors

## Comments

**When to Comment:**
- TODO comments with ticket reference: `// TODO(TICKET-123): Implement retry logic`
- JSDoc for public APIs consumed externally
- JSDoc for complex algorithms requiring explanation

**Forbidden Comments:**
- Obvious comments explaining what code does
- Changelog comments (use git history)
- Commented-out code (delete it)
- Closing brace comments (`} // end if`)

**JSDoc Usage:**
- Use for public APIs and library functions
- Include `@param` and `@returns` annotations
- Example from codebase:
  ```typescript
  /**
   * InjectionToken for the site URL (public-facing website)
   * Used for generating QR codes and external links
   */
  export const SITE_URL = new InjectionToken<string>('SITE_URL');
  ```

## Function Design

**Size:** Maximum 5 statements per function

**Parameters:** Maximum 3 parameters; use object parameter for more

**Return Values:**
- Early returns to reduce nesting
- Explicit return types in TypeScript
- Use Result pattern for operations that can fail

## Module Design

**Exports:**
- Barrel files (`index.ts`) export public API
- Prefer direct imports for internal use
- Pattern: `libs/[scope]/[lib]/src/index.ts`

**Barrel Files:**
- Keep minimal - only export what's truly public
- Use `export { X } from './path'` format
- Example: `libs/shared/utils/src/index.ts`

## Angular-Specific Conventions

**Components:**
- Use standalone components (no NgModules)
- Use signals for state management: `input()`, `output()`, `signal()`
- Use `@if`/`@for` control flow syntax
- Components should be presentational (dumb)
- Logic goes in facades in data-access layer

**Templates:**
- Use `data-testid` attributes for testing
- Avoid `*ngIf`/`*ngFor` (use `@if`/`@for`)
- Avoid `ngClass`/`ngStyle` (use class binding)

**PrimeNG:**
- Use component selectors: `p-button`, `p-inputtext`, `p-select`
- Avoid directive syntax: `pButton`, `pInputText`
- Use `#template` for template references

## NestJS-Specific Conventions

**Controllers:**
- Use decorators: `@Controller()`, `@Get()`, `@Post()`, etc.
- Inject services via constructor
- Keep thin - delegate to services

**Services:**
- Use `@Injectable()` decorator
- Single responsibility principle
- Return typed data

**Modules:**
- Group related controllers and services
- Export only what's needed by other modules

## Git Conventions

**Commit Messages:**
- Follow Conventional Commits specification
- Enforced by commitlint (Husky)
- Format: `<type>(scope): <short message>`
- Max 120 characters in first line
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`, `build`

**Pre-commit Hooks:**
- `.husky/pre-commit`: Runs lint-staged
- `.husky/commit-msg`: Validates commit message format

---

*Convention analysis: 2026-01-16*
