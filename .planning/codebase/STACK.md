# Technology Stack

**Analysis Date:** 2026-01-16

## Languages

**Primary:**
- TypeScript ~5.9.2 - Used across all apps and libs (Angular, NestJS, shared libraries)

**Secondary:**
- JavaScript (ESM/CJS) - Configuration files (`eslint.config.mjs`, `commitlint.config.js`, `jest.preset.js`)
- CSS - Styling with Tailwind CSS

## Runtime

**Environment:**
- Node.js 22.x (detected: v22.21.1)
- Bun 1.3.x (detected: 1.3.6) - Primary package manager and script runner

**Package Manager:**
- Bun
- Lockfile: `bun.lock` (present)

## Frameworks

**Core:**
- Angular ~21.0.0 - Frontend web application (`apps/web/`)
- NestJS ^11.0.0 - Backend API (`apps/api/`)

**Testing:**
- Jest ^30.0.2 - Unit testing for all projects
- jest-preset-angular ~16.0.0 - Angular-specific Jest configuration
- ts-jest ^29.4.0 - TypeScript support for Jest
- @nestjs/testing ^11.0.0 - NestJS testing utilities

**Build/Dev:**
- Nx 22.3.3 - Monorepo build system and tooling
- Webpack via @nx/webpack - Backend bundling
- @angular/build ~21.0.0 - Angular application builder
- SWC ~1.5.7 - Fast TypeScript/JavaScript compilation

## Key Dependencies

**Critical (Frontend):**
- RxJS ~7.8.0 - Reactive programming for Angular
- PrimeNG ^21.0.3 - UI component library
- @primeuix/themes ^2.0.2 - PrimeNG theme system
- Tailwind CSS ^4.1.18 - Utility-first CSS framework
- tailwindcss-primeui ^0.6.1 - PrimeNG Tailwind integration

**Critical (Backend):**
- @nestjs/platform-express ^11.0.0 - Express HTTP adapter for NestJS
- reflect-metadata ^0.1.13 - Decorator metadata support

**Infrastructure:**
- tslib ^2.3.0 - TypeScript runtime helpers

## Configuration

**Environment:**
- Environment-based configuration via `apps/web/src/environments/`
- Environment factory pattern: `environmentFactory('development' | 'homolog' | 'production')`
- `.env` file for local secrets (gitignored)
- Three deployment targets: development, homolog, production

**Build:**
- `nx.json` - Nx workspace configuration
- `tsconfig.base.json` - Base TypeScript configuration
- `eslint.config.mjs` - ESLint flat config
- `.prettierrc` - Prettier (single quotes enabled)
- `commitlint.config.js` - Conventional commits enforcement

**TypeScript Path Aliases:**
```typescript
"@shared/utils": ["libs/shared/utils/src/index.ts"],
"@shared/utils/*": ["libs/shared/utils/src/*"]
```

## Platform Requirements

**Development:**
- Node.js 22.x
- Bun 1.3.x
- Git with Husky hooks configured

**Production:**
- Web: Static file hosting (SPA)
- API: Node.js runtime (Express via NestJS)

## Nx Plugins

- `@nx/webpack/plugin` - Webpack build integration
- `@nx/eslint/plugin` - ESLint integration
- `@nx/angular` - Angular support
- `@nx/nest` - NestJS support
- `@nx/jest` - Jest testing support
- `@nx/js` - JavaScript/TypeScript support

## MCP (Model Context Protocol) Servers

Configured in `mcp.json`:
- `primeng` - PrimeNG MCP
- `context7` - Context7 API (HTTP)
- `gemini-cli` - Gemini MCP tool
- `linear-server` - Linear integration (HTTP)
- `firecrawl` - Firecrawl MCP
- `chrome-devtools` - Chrome DevTools MCP
- `nx-mcp` - Nx MCP
- `figma` - Figma integration (HTTP)
- `angular-cli` - Angular CLI MCP

## Git Hooks (Husky)

**Pre-commit:**
- `bunx lint-staged` - Runs prettier and eslint on staged files

**Commit-msg:**
- `bunx --no-install commitlint --edit` - Enforces conventional commits

## CI/CD

**GitHub Actions:**
- Location: `.github/workflows/ci.yml`
- Runner: `ubuntu-latest`
- Triggers: Push to `main`, Pull requests
- Uses: Bun (latest), Nx Cloud integration
- Commands: `bun nx run-many -t lint test build`

---

*Stack analysis: 2026-01-16*
