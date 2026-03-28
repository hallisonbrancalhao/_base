# Testing, CI/CD & DevOps

## Conceito

A estrategia de qualidade combina **testes unitarios com Jest**, **lint com ESLint** (incluindo module boundaries), **CI com GitHub Actions** e **deploy com Docker + Azure**. O monorepo otimiza tudo via **affected commands** - so testa e builda o que mudou.

---

## 1. Estrategia de Testes

### Configuracao Jest

```typescript
// jest.config.ts (raiz)
import { getJestProjectsAsync } from '@nx/jest';

export default async () => ({
  projects: await getJestProjectsAsync(),
});

// jest.preset.js
const nxPreset = require('@nx/jest/preset').default;
module.exports = { ...nxPreset };
```

### Per-Project Config

```typescript
// packages/career/domain/jest.config.ts
export default {
  displayName: 'career-domain',
  preset: '../../../jest.preset.js',
  transform: {
    '^.+\\.[tj]s$': ['ts-jest', { tsconfig: '<rootDir>/tsconfig.spec.json' }],
  },
  moduleFileExtensions: ['ts', 'js', 'html'],
  coverageDirectory: '../../../coverage/packages/career/domain',
};
```

### Organizacao de Testes

```
packages/career/domain/src/
├── server/
│   └── use-cases/
│       ├── create-job-opening.ts
│       └── create-job-opening.spec.ts    # Teste do use case
├── client/
│   └── use-cases/
│       ├── find-job-openings.ts
│       └── find-job-openings.spec.ts
└── test-setup.ts                         # Setup do ambiente de teste
```

### Testando Use Cases

```typescript
// create-job-opening.spec.ts
describe('CreateJobOpeningUseCase', () => {
  let useCase: CreateJobOpeningUseCase;
  let mockService: jest.Mocked<JobOpeningsService>;

  beforeEach(() => {
    mockService = {
      create: jest.fn(),
      find: jest.fn(),
      findOne: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    } as any;

    useCase = new CreateJobOpeningUseCase(mockService);
  });

  it('should create a job opening', async () => {
    const data = { title: 'Dev Senior', mode: 'remote' };
    const expected = { id: '1', ...data };
    mockService.create.mockResolvedValue(expected);

    const result = await useCase.execute(data);

    expect(result).toEqual(expected);
    expect(mockService.create).toHaveBeenCalledWith(data);
  });
});
```

**Principio**: Use Cases sao testados com mocks dos ports - zero dependencia de infraestrutura.

---

## 2. Lint & Module Boundaries

### ESLint como Guardiao de Arquitetura

```bash
# Lint todos os pacotes afetados
pnpm exec nx affected -t lint

# Fix automatico
pnpm exec nx run-many -t lint --fix
```

### O que o lint verifica

1. **Regras TypeScript**: Tipagem estrita, no-any, etc.
2. **Module Boundaries**: Imports entre camadas (ver 10-MODULE-BOUNDARIES.md)
3. **Code Style**: Prettier integration
4. **Best Practices**: ESLint recommended + Angular/NestJS rules

### Pre-commit Hook

```bash
# .husky/pre-commit
npx nx affected -t lint test --parallel=10
```

Antes de cada commit, lint e test rodam nos pacotes afetados.

---

## 3. CI Pipeline (GitHub Actions)

### Pull Request CI

```yaml
# .github/workflows/ci.yml
name: CI
on:
  pull_request:

jobs:
  main:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0           # Historico completo para affected

      - uses: pnpm/action-setup@v4
        with:
          version: 9.12.1

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'            # Cache de dependencias

      - run: pnpm install --frozen-lockfile

      - uses: nrwl/nx-set-shas@v4  # Define SHAs para affected

      # Executa lint, test e build APENAS nos pacotes afetados
      - run: pnpm exec nx affected -t lint test build --parallel=10
```

**Otimizacoes**:
- `fetch-depth: 0`: Historico completo para `nx affected` funcionar
- `cache: 'pnpm'`: Cache de node_modules entre runs
- `--parallel=10`: Ate 10 pacotes em paralelo
- `nx affected`: So testa o que mudou (nao o monorepo inteiro)

---

## 4. Deploy Pipeline

### Frontend → GitHub Pages

```yaml
build-deploy-front:
  runs-on: ubuntu-latest
  steps:
    - run: pnpm install --frozen-lockfile
    - run: pnpm exec nx build devmx --verbose

    - uses: peaceiris/actions-gh-pages@v4
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./dist/apps/devmx/browser
```

### Backend → Docker → Azure

```yaml
build-back:
  runs-on: ubuntu-latest
  steps:
    - uses: docker/build-push-action@v5
      with:
        context: .
        file: ./Dockerfile.server
        push: true
        tags: registry.azurecr.io/devmx-server:latest

deploy:
  needs: build-back
  runs-on: ubuntu-latest
  steps:
    - uses: azure/webapps-deploy@v3
      with:
        app-name: devmx-server
        images: registry.azurecr.io/devmx-server:latest
```

---

## 5. Docker

### Backend Dockerfile

```dockerfile
FROM node:22-alpine
ENV PORT=3000
WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --frozen-lockfile

COPY . .
RUN pnpm nx build server --verbose

EXPOSE $PORT
CMD ["node", "dist/apps/server/main.js"]
```

### Docker Compose (Desenvolvimento)

```yaml
services:
  mongodb:
    image: mongo:latest
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${DB_USER}
      MONGO_INITDB_ROOT_PASSWORD: ${DB_PASS}
    ports:
      - 27017:27017

  server:
    build:
      context: .
      dockerfile: Dockerfile.server
    environment:
      - DB_HOST=mongodb
      - JWT_SECRET=${JWT_SECRET}
    ports:
      - 8080:3000
    depends_on:
      - mongodb

  devmx:
    build:
      context: .
      dockerfile: Dockerfile.front
    ports:
      - 4200:4200
    depends_on:
      - server
```

---

## 6. Affected Commands

O conceito mais poderoso do Nx: **so executar o que foi afetado pela mudanca**.

```bash
# Se mudou packages/career/domain/src/...
# Nx calcula o grafo de dependencias e determina:
# - career-domain (mudou)
# - career-data-access (depende de career-domain)
# - career-data-source (depende de career-domain)
# - career-resource (depende de career-data-source)
# - career-feature-shell (depende de career-data-access)
# - server (depende de career-resource)
# - devmx (depende de career-feature-shell)

pnpm exec nx affected -t lint test build
# Executa APENAS nesses pacotes, nao em todo o monorepo
```

---

## 7. Cache de Build

```json
// nx.json
{
  "targetDefaults": {
    "build": {
      "cache": true,
      "dependsOn": ["^build"]
    },
    "lint": { "cache": true },
    "test": { "cache": true }
  }
}
```

- Se nenhum arquivo mudou desde o ultimo build → **resultado do cache**
- `dependsOn: ["^build"]`: Build dependencias antes de buildar o pacote
- Cache local em `.nx/cache/`

---

## 8. Scripts de Desenvolvimento

```json
{
  "scripts": {
    "dev": "concurrently \"docker:compose:only:mongo\" \"nx run-many -t serve --projects=server,devmx\"",
    "affected": "nx affected -t lint test build",
    "lint:fix": "nx run-many -t lint --fix",
    "docker:compose": "docker compose up -d --build",
    "docker:compose:only:mongo": "docker compose up -d mongodb",
    "commit": "cz"
  }
}
```

---

## 9. Commit Convention

```javascript
// config/cz.config.js
module.exports = {
  types: [
    { value: 'feat',     name: 'feat:     Nova funcionalidade' },
    { value: 'fix',      name: 'fix:      Correcao de bug' },
    { value: 'docs',     name: 'docs:     Documentacao' },
    { value: 'style',    name: 'style:    Formatacao' },
    { value: 'refactor', name: 'refactor: Refatoracao' },
    { value: 'perf',     name: 'perf:     Performance' },
    { value: 'test',     name: 'test:     Testes' },
    { value: 'build',    name: 'build:    Build e dependencias' },
    { value: 'ci',       name: 'ci:       CI/CD' },
    { value: 'chore',    name: 'chore:    Tarefas gerais' },
    { value: 'revert',   name: 'revert:   Reverter commit' },
  ],
  scopes: [], // Populado automaticamente pelos packages
};
```

---

## Fluxo Completo: Codigo → Producao

```
1. Developer faz mudanca
   ↓
2. Pre-commit hook: nx affected -t lint test
   ↓ (se falhar, commit bloqueado)
3. Push para branch
   ↓
4. PR criado
   ↓
5. CI: nx affected -t lint test build --parallel=10
   ↓ (se falhar, PR bloqueado)
6. Code review + aprovacao
   ↓
7. Merge para main
   ↓
8. Deploy pipeline:
   - Frontend: build → GitHub Pages
   - Backend: Docker build → Azure Container Registry → Azure Web App
```

---

## Como Aplicar em Qualquer Projeto

1. **Jest com preset compartilhado** - config consistente em todo pacote
2. **Testes unitarios nos Use Cases** - mock dos ports
3. **ESLint com module boundaries** - arquitetura enforced automaticamente
4. **Pre-commit hooks** - lint e test antes de cada commit
5. **Affected commands** - so testa o que mudou
6. **Cache de build** - evita re-executar o que nao mudou
7. **CI em PRs** - lint + test + build no pipeline
8. **Docker multi-stage** - builds otimizados para producao
9. **Commit convention** - mensagens padronizadas com Commitizen
10. **Deploy separado** front/back - independencia de deploy
