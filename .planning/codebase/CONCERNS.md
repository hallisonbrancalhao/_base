# Codebase Concerns

**Analysis Date:** 2026-01-16

## Tech Debt

**Incomplete Environment Configuration:**
- Issue: Production and homolog environment configs contain placeholder values (`'---'`) for all critical URLs and API keys
- Files: `apps/web/src/environments/environment.factory.ts`
- Impact: Application cannot be deployed to production/homolog without manual configuration. No validation ensures configs are properly set before build.
- Fix approach: Add build-time validation or runtime checks that fail early if required environment values are placeholders

**Empty Routes Configuration:**
- Issue: Angular routes array is empty, application has no routing structure
- Files: `apps/web/src/app/app.routes.ts`
- Impact: No page navigation possible, app is a single static page. Blocks development of any multi-page features.
- Fix approach: Define at least a default route and shell structure per documented architecture patterns

**Hardcoded Placeholder Data in Template:**
- Issue: Main app template contains hardcoded "Welcome web" text with no i18n
- Files: `apps/web/src/app/app.html`
- Impact: Template is not production-ready, no internationalization despite i18n files existing
- Fix approach: Use translation keys from existing i18n files (`apps/web/src/l18n/`)

**Proxy Configuration Port Mismatch:**
- Issue: Proxy config targets port 3333 for `/api` but API app runs on port 3000 by default
- Files: `apps/web/proxy.conf.json`, `apps/api/src/main.ts`
- Impact: API proxying may not work correctly in development without manual port adjustment
- Fix approach: Align proxy configuration with actual API port (3000) or document expected websocket server on 3333

**Shared Utils Library Architecture Concern:**
- Issue: `@shared/utils` lib imports `@angular/core` (InjectionToken), coupling a "shared" library to Angular
- Files: `libs/shared/utils/src/tokens/site-url.ts`
- Impact: Library cannot be reused by NestJS backend or other non-Angular contexts despite being in "shared" scope
- Fix approach: Move Angular-specific tokens to a separate `@shared/angular-utils` or `@web/utils` library

## Known Bugs

**No Critical Bugs Detected:**
- This is a fresh/starter codebase with minimal implementation
- No runtime bugs can be identified without actual feature code

## Security Considerations

**Console Error Exposure:**
- Risk: Bootstrap errors are logged to console without sanitization
- Files: `apps/web/src/main.ts`
- Current mitigation: None
- Recommendations: Implement proper error boundary and error reporting service; avoid console.error in production

**No API Security Middleware:**
- Risk: NestJS API has no authentication, validation, or rate limiting configured
- Files: `apps/api/src/app/app.module.ts`, `apps/api/src/main.ts`
- Current mitigation: None - fresh boilerplate
- Recommendations: Add helmet, rate-limiter, CORS configuration, and authentication guards before any sensitive endpoints

**Environment Files Not Validated:**
- Risk: Environment factory returns configs without validating required values are set
- Files: `apps/web/src/environments/environment.factory.ts`
- Current mitigation: None
- Recommendations: Add runtime validation using zod or class-validator to ensure configs are complete

**No CORS Configuration:**
- Risk: API allows requests from any origin by default
- Files: `apps/api/src/main.ts`
- Current mitigation: None
- Recommendations: Configure CORS with specific allowed origins in NestJS bootstrap

## Performance Bottlenecks

**No Significant Bottlenecks Detected:**
- Codebase is minimal starter template (~500 lines total)
- No complex data processing or heavy computations present

**Potential Future Concern - Bundle Size:**
- Problem: PrimeNG and full i18n files imported
- Files: `apps/web/src/app/app.config.ts`, `apps/web/src/l18n/*.ts`
- Cause: Full library imports vs. selective imports
- Improvement path: Use tree-shakeable PrimeNG imports; lazy-load translations

## Fragile Areas

**Theme Initialization Script:**
- Files: `apps/web/src/index.html` (inline script)
- Why fragile: Inline JavaScript in HTML relies on localStorage API and CSS class conventions; no TypeScript type safety
- Safe modification: Move to typed service after app bootstrap; add unit tests for theme persistence
- Test coverage: None (inline script cannot be unit tested)

**Environment Factory:**
- Files: `apps/web/src/environments/environment.factory.ts`
- Why fragile: No compile-time or runtime validation; easy to deploy with broken configs
- Safe modification: Add zod schema validation; add deployment checks
- Test coverage: None

## Scaling Limits

**Single API Instance:**
- Current capacity: One NestJS instance on single port
- Limit: Single process, no horizontal scaling configured
- Scaling path: Add PM2/cluster mode or container orchestration config

**No Database Configuration:**
- Current capacity: No persistence layer
- Limit: Cannot store any data
- Scaling path: Add TypeORM/Prisma with connection pooling

## Dependencies at Risk

**reflect-metadata Outdated:**
- Risk: Version 0.1.13 is significantly outdated (current stable is 0.2.x)
- Impact: Potential compatibility issues with newer TypeScript/NestJS features
- Migration plan: Update to 0.2.x and verify decorator metadata still works

**Potential Angular/Nx Version Lock:**
- Risk: Using Angular 21 (experimental/canary) with Nx 22.3.3
- Impact: May encounter undocumented bugs or breaking changes
- Migration plan: Consider stable Angular version for production

## Missing Critical Features

**No HttpClient Configuration:**
- Problem: Angular app has no HttpClient provider configured
- Blocks: Any API calls from frontend

**No Authentication System:**
- Problem: No auth guards, interceptors, or user session management
- Blocks: Any protected routes or user-specific features

**No Global Error Handler:**
- Problem: Only console.error on bootstrap failure
- Blocks: Proper error tracking and user feedback

**No State Management:**
- Problem: No facade pattern implementation despite documented architecture requiring it
- Blocks: Complex feature development following project conventions

## Test Coverage Gaps

**Frontend App Has Zero Tests:**
- What's not tested: All Angular components, configs, routing
- Files: `apps/web/src/app/app.ts`, `apps/web/src/app/app.config.ts`
- Risk: Regressions undetected in core app setup
- Priority: High

**Shared Utils Library Has No Tests:**
- What's not tested: SITE_URL injection token functionality
- Files: `libs/shared/utils/src/tokens/site-url.ts`
- Risk: Token misconfiguration undetected
- Priority: Medium

**Environment Factory Not Tested:**
- What's not tested: Environment switching logic, config structure
- Files: `apps/web/src/environments/environment.factory.ts`
- Risk: Deployment with wrong environment configs
- Priority: High

**i18n Translations Not Validated:**
- What's not tested: Translation key completeness across locales
- Files: `apps/web/src/l18n/pt-br.ts`, `apps/web/src/l18n/en.ts`, `apps/web/src/l18n/es.ts`
- Risk: Missing translations in production
- Priority: Low (not actively used yet)

---

*Concerns audit: 2026-01-16*
