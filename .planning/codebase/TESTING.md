# Testing Patterns

**Analysis Date:** 2026-01-16

## Test Framework

**Runner:**
- Jest 30.x
- Config: `jest.config.ts` (root), per-app configs (`jest.config.cts`)

**Assertion Library:**
- Jest built-in matchers
- `expect()` API

**Run Commands:**
```bash
nx test [project]           # Run tests for a specific project
nx run-many --target=test   # Run all tests
nx affected --target=test   # Run tests for affected projects
```

## Test File Organization

**Location:**
- Co-located with source files
- Pattern: `[name].spec.ts` next to `[name].ts`

**Naming:**
- `*.spec.ts` for unit tests
- Example: `app.controller.spec.ts`, `app.service.spec.ts`

**Structure:**
```
apps/api/src/app/
├── app.controller.ts
├── app.controller.spec.ts
├── app.service.ts
├── app.service.spec.ts
└── app.module.ts
```

## Test Structure

**Suite Organization:**
```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';
import { AppService } from './app.service';

describe('AppController', () => {
  let app: TestingModule;

  beforeAll(async () => {
    app = await Test.createTestingModule({
      controllers: [AppController],
      providers: [AppService],
    }).compile();
  });

  describe('getData', () => {
    it('should return "Hello API"', () => {
      const appController = app.get<AppController>(AppController);
      expect(appController.getData()).toEqual({ message: 'Hello API' });
    });
  });
});
```

**Patterns:**
- Setup pattern: `beforeAll` or `beforeEach` for test module compilation
- Teardown pattern: Use `afterEach` to reset mocks
- Assertion pattern: `expect(actual).toEqual(expected)`

## Mocking

**Framework:** Jest built-in mocking

**NestJS Backend Pattern:**
```typescript
import { Test } from '@nestjs/testing';
import { AppService } from './app.service';

describe('AppService', () => {
  let service: AppService;

  beforeAll(async () => {
    const app = await Test.createTestingModule({
      providers: [AppService],
    }).compile();

    service = app.get<AppService>(AppService);
  });

  describe('getData', () => {
    it('should return "Hello API"', () => {
      expect(service.getData()).toEqual({ message: 'Hello API' });
    });
  });
});
```

**Angular Frontend Pattern:**
```typescript
let mockUserService: jest.Mocked<UserService>;

beforeEach(async () => {
  mockUserService = {
    getUsers: jest.fn(),
    deleteUser: jest.fn()
  } as jest.Mocked<UserService>;

  await TestBed.configureTestingModule({
    declarations: [UserListComponent],
    schemas: [NO_ERRORS_SCHEMA],
    providers: [
      { provide: UserService, useValue: mockUserService }
    ]
  }).compileComponents();
});
```

**What to Mock:**
- All external dependencies (HttpClient, services, APIs)
- All injected services in unit tests
- External modules not under test

**What NOT to Mock:**
- The unit under test
- Simple value objects and DTOs
- Pure utility functions

## Fixtures and Factories

**Test Data:**
```typescript
const mockNotifications = [
  { id: '1', name: 'Notification 1' },
  { id: '2', name: 'Notification 2' }
];

const mockUser = { id: 1, name: 'Alice', email: 'alice@test.com' };
```

**Location:**
- Inline in test files for simple data
- Shared fixtures in test utilities for complex/reused data

## Coverage

**Requirements:** Not enforced (no coverage thresholds configured)

**View Coverage:**
```bash
nx test [project] --coverage
```

**Coverage Directory:**
- `coverage/apps/[app-name]/`
- `coverage/libs/[scope]/[lib-name]/`

## Test Types

**Unit Tests:**
- Scope: Single class/function
- Mock all dependencies
- Fast execution
- Located next to source files

**Integration Tests:**
- Scope: Multiple components together
- Use NestJS Test module
- May use real dependencies where appropriate

**E2E Tests:**
- Framework: Not configured in current codebase
- Would use separate test project if added

## Common Patterns

**Async Testing:**
```typescript
it('should fetch users', async () => {
  mockRepository.getUsers.mockResolvedValue(mockUsers);

  const result = await service.getUsers();

  expect(result).toEqual(mockUsers);
});
```

**Error Testing:**
```typescript
it('should throw error for invalid input', () => {
  expect(() => service.validate(null))
    .toThrow('Invalid input');
});

it('should handle async errors', async () => {
  mockService.getData.mockRejectedValue(new Error('Network error'));

  await expect(service.fetchData()).rejects.toThrow('Network error');
});
```

## Angular-Specific Testing

**Component Testing:**
- Use `TestBed.configureTestingModule()`
- Use `fixture.debugElement.query(By.css('[data-testid="..."]'))`
- Use `fixture.componentRef.setInput()` for input signals
- Use `triggerEventHandler()` for events
- Avoid `componentInstance` for internal methods

**Schemas:**
- Always include `NO_ERRORS_SCHEMA` and `CUSTOM_ELEMENTS_SCHEMA`
- Prevents errors from unknown custom elements

**Standalone Component Pattern:**
```typescript
await TestBed.configureTestingModule({
  imports: [UserProfileComponent]
})
  .overrideComponent(UserProfileComponent, {
    set: {
      imports: [MockTranslatePipe],
      providers: [
        { provide: UserService, useValue: mockUserService }
      ],
      schemas: [NO_ERRORS_SCHEMA, CUSTOM_ELEMENTS_SCHEMA]
    }
  })
  .compileComponents();
```

**Setup for Zoneless Testing:**
```typescript
// apps/web/src/test-setup.ts
import { setupZonelessTestEnv } from 'jest-preset-angular/setup-env/zoneless';

setupZonelessTestEnv({
  errorOnUnknownElements: true,
  errorOnUnknownProperties: true,
});
```

## NestJS-Specific Testing

**Controller Testing:**
```typescript
describe('AppController', () => {
  let app: TestingModule;

  beforeAll(async () => {
    app = await Test.createTestingModule({
      controllers: [AppController],
      providers: [AppService],
    }).compile();
  });

  it('should return data', () => {
    const controller = app.get<AppController>(AppController);
    expect(controller.getData()).toEqual({ message: 'Hello API' });
  });
});
```

**Service Testing:**
```typescript
describe('AppService', () => {
  let service: AppService;

  beforeAll(async () => {
    const app = await Test.createTestingModule({
      providers: [AppService],
    }).compile();

    service = app.get<AppService>(AppService);
  });

  it('should return data', () => {
    expect(service.getData()).toEqual({ message: 'Hello API' });
  });
});
```

## Jest Configuration

**Root Config (`jest.config.ts`):**
```typescript
import type { Config } from 'jest';
import { getJestProjectsAsync } from '@nx/jest';

export default async (): Promise<Config> => ({
  projects: await getJestProjectsAsync(),
});
```

**Preset (`jest.preset.js`):**
```javascript
const nxPreset = require('@nx/jest/preset').default;
module.exports = { ...nxPreset };
```

**API App Config (`apps/api/jest.config.cts`):**
```javascript
module.exports = {
  displayName: 'api',
  preset: '../../jest.preset.js',
  testEnvironment: 'node',
  transform: {
    '^.+\\.[tj]s$': ['ts-jest', { tsconfig: '<rootDir>/tsconfig.spec.json' }],
  },
  moduleFileExtensions: ['ts', 'js', 'html'],
  coverageDirectory: '../../coverage/apps/api',
};
```

**Web App Config (`apps/web/jest.config.cts`):**
```javascript
module.exports = {
  displayName: 'web',
  preset: '../../jest.preset.js',
  setupFilesAfterEnv: ['<rootDir>/src/test-setup.ts'],
  coverageDirectory: '../../coverage/apps/web',
  transform: {
    '^.+\\.(ts|mjs|js|html)$': [
      'jest-preset-angular',
      {
        tsconfig: '<rootDir>/tsconfig.spec.json',
        stringifyContentPathRegex: '\\.(html|svg)$',
      },
    ],
  },
  transformIgnorePatterns: ['node_modules/(?!.*\\.mjs$)'],
  snapshotSerializers: [
    'jest-preset-angular/build/serializers/no-ng-attributes',
    'jest-preset-angular/build/serializers/ng-snapshot',
    'jest-preset-angular/build/serializers/html-comment',
  ],
};
```

## Best Practices from .agent Documentation

**Golden Rule:**
- Never use `componentInstance` directly
- Test through DOM and side effects

**For Inputs:**
- Use `componentRef.setInput()`

**For Outputs:**
- Use `triggerEventHandler()`

**For Properties:**
- Use `debugElement.properties` (Angular bindings)
- Use `debugElement.attributes` (HTML attributes)

**Reset Mocks:**
- Declare mocks with `let`
- Recreate in `beforeEach`

**Async Testing:**
- Use `fakeAsync()` + `flush()` instead of `setTimeout` + `done`
- Use `tick(ms)` for specific time advancement
- Use `TestScheduler` for RxJS marble testing

---

*Testing analysis: 2026-01-16*
