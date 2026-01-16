# External Integrations

**Analysis Date:** 2026-01-16

## APIs & External Services

**Google Services:**
- Google OAuth - Planned authentication provider
  - Client ID: Configured per environment in `apps/web/src/environments/environment.factory.ts`
  - Auth: `google.clientId` in environment config

**reCAPTCHA:**
- Google reCAPTCHA v3 - Bot protection (planned)
  - Site Key: `recaptcha.siteKey` in environment config
  - Implementation: Not yet integrated

**WebSocket:**
- WebSocket Server - Real-time communication (planned)
  - URL: `environment.websocketUrl`
  - Development: `http://localhost:3333`
  - Production: Not configured

## Data Storage

**Databases:**
- None configured
- Backend (`apps/api/`) is a minimal NestJS scaffold without database integration
- No ORM or database client detected

**File Storage:**
- Local filesystem only
- Static assets in `apps/web/public/`

**Caching:**
- Nx Cloud for CI build caching (ID: `6967a542f863325a8b5f9d75` in `nx.json`)
- No application-level caching configured

## Authentication & Identity

**Auth Provider:**
- Custom (planned)
  - Token storage: `@authToken` in localStorage (key from environment)
  - User data storage: `@userData` in localStorage (key from environment)
  - Implementation: Not yet built

**Planned Providers:**
- Google OAuth (client ID placeholder exists)

## Monitoring & Observability

**Error Tracking:**
- None configured

**Logs:**
- NestJS Logger - Basic logging in backend (`Logger.log()` in `apps/api/src/main.ts`)
- Console-based in frontend

## CI/CD & Deployment

**Hosting:**
- Not specified
- Web app outputs to `dist/apps/web/browser` (SPA-ready)
- API outputs to `dist/apps/api` with generated `package.json`

**CI Pipeline:**
- GitHub Actions (`.github/workflows/ci.yml`)
- Nx Cloud for distributed caching
- Runs: lint, test, build

**Build Outputs:**
- Web: `dist/apps/web/`
- API: `dist/apps/api/` (includes `package.json` and `bun.lock`)

## Environment Configuration

**Required env vars:**
- `PORT` (optional) - API port, defaults to 3000
- `CONTEXT7_API_KEY` - For Context7 MCP server
- `FIRECRAWL_API_KEY` - For Firecrawl MCP server

**Secrets location:**
- `.env` file (gitignored)
- `.env.example` for reference

**Environment Files:**
- `apps/web/src/environments/environment.ts` - Development
- `apps/web/src/environments/environment.hml.ts` - Homolog
- `apps/web/src/environments/environment.prod.ts` - Production
- `apps/web/src/environments/environment.factory.ts` - Factory function

## Webhooks & Callbacks

**Incoming:**
- None configured

**Outgoing:**
- None configured

## API Communication

**Backend-to-Frontend Proxy:**
- Development proxy configured in `apps/web/proxy.conf.json`:
  - `/api` -> `http://localhost:3333`
  - `/api-api` -> `http://localhost:3000`

**API Endpoints:**
- Base URL: `environment.apiUrl`
- Development: `http://localhost:3000/v1`
- Global prefix: `/api` (configured in `apps/api/src/main.ts`)

## Third-Party SDKs

**MCP Integrations (Development Tools):**
- PrimeNG MCP - Component documentation
- Linear - Project management
- Figma - Design collaboration
- Chrome DevTools - Browser debugging

**UI Libraries:**
- PrimeNG - Pre-built components
- Tailwind CSS - Styling utility classes
- tailwindcss-primeui - PrimeNG + Tailwind integration

## Planned Integrations (from environment config)

Based on `apps/web/src/environments/environment.factory.ts`:

1. **REST API** - Backend service communication
   - URL pattern: `{apiUrl}/v1`
   - Auth: Token-based

2. **WebSocket** - Real-time features
   - URL pattern: `{websocketUrl}`
   - Purpose: Not documented

3. **Google OAuth** - Social login
   - Client ID per environment

4. **reCAPTCHA** - Form protection
   - Site key per environment

## Injection Tokens

**Available:**
- `SITE_URL` - Public-facing website URL (`@shared/utils/tokens/site-url.ts`)
  - Used for QR codes, external links
  - Injected via `apps/web/src/app/app.config.ts`

---

*Integration audit: 2026-01-16*
