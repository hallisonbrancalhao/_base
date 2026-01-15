# @test-writer - Unit Test Writer Agent

> Creates unit tests following Jest patterns with proper mocking.

---

## Capabilities

- Write unit tests for components, services, facades
- Create proper mocks and stubs
- Follow AAA pattern (Arrange, Act, Assert)
- Test signals and reactive patterns
- Achieve meaningful coverage

---

## Required Knowledge

Before writing tests, read:
- `.agent/System/angular_unit_testing_guide.md`

---

## Invocation Pattern

```markdown
@test-writer
  task: [what to test]
  context: [source file to test]
  constraints: [coverage targets, patterns]
  output: [test file]
```

---

## Example: Test Facade

```markdown
@test-writer
  task: Write tests for UserFacade
  context: libs/user/data-access/src/lib/application/user.facade.ts
  constraints:
    - Mock repository
    - Test all public methods
    - Test signal states
  output: user.facade.spec.ts
```

**Result:**
```typescript
import { TestBed } from '@angular/core/testing';

import { UserFacade } from './user.facade';
import { UserRepository } from '../infrastructure/user.repository';

describe('UserFacade', () => {
  let facade: UserFacade;
  let repositoryMock: jest.Mocked<UserRepository>;

  const mockUser = { id: '1', name: 'Test User', email: 'test@example.com' };

  beforeEach(() => {
    repositoryMock = {
      getById: jest.fn(),
      save: jest.fn(),
    } as unknown as jest.Mocked<UserRepository>;

    TestBed.configureTestingModule({
      providers: [
        UserFacade,
        { provide: UserRepository, useValue: repositoryMock },
      ],
    });

    facade = TestBed.inject(UserFacade);
  });

  describe('initial state', () => {
    it('should have null user', () => {
      expect(facade.user()).toBeNull();
    });

    it('should not be loading', () => {
      expect(facade.loading()).toBe(false);
    });

    it('should have no error', () => {
      expect(facade.error()).toBeNull();
    });
  });

  describe('loadUser', () => {
    it('should set loading to true during load', async () => {
      repositoryMock.getById.mockResolvedValue(mockUser);

      const loadPromise = facade.loadUser('1');
      expect(facade.loading()).toBe(true);

      await loadPromise;
      expect(facade.loading()).toBe(false);
    });

    it('should set user on success', async () => {
      repositoryMock.getById.mockResolvedValue(mockUser);

      await facade.loadUser('1');

      expect(facade.user()).toEqual(mockUser);
      expect(facade.error()).toBeNull();
    });

    it('should set error on failure', async () => {
      repositoryMock.getById.mockRejectedValue(new Error('Not found'));

      await facade.loadUser('1');

      expect(facade.user()).toBeNull();
      expect(facade.error()).toBe('Failed to load user');
    });
  });
});
```

---

## Example: Test Component

```markdown
@test-writer
  task: Write tests for UserProfileComponent
  context: libs/user/feature-profile/src/lib/user-profile.component.ts
  constraints:
    - Mock facade
    - Test template rendering
    - Use componentRef.setInput()
  output: user-profile.component.spec.ts
```

**Result:**
```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { signal } from '@angular/core';

import { UserProfileComponent } from './user-profile.component';
import { UserFacade } from '@project/user/data-access';

describe('UserProfileComponent', () => {
  let component: UserProfileComponent;
  let fixture: ComponentFixture<UserProfileComponent>;

  const mockUser = signal({ id: '1', name: 'Test', email: 'test@test.com' });
  const mockLoading = signal(false);
  const mockError = signal<string | null>(null);

  const facadeMock = {
    user: mockUser,
    loading: mockLoading,
    error: mockError,
    loadUser: jest.fn(),
  };

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [UserProfileComponent],
      providers: [
        { provide: UserFacade, useValue: facadeMock },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(UserProfileComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should show skeleton when loading', () => {
    mockLoading.set(true);
    fixture.detectChanges();

    const skeleton = fixture.nativeElement.querySelector('p-skeleton');
    expect(skeleton).toBeTruthy();
  });

  it('should show user card when loaded', () => {
    mockLoading.set(false);
    mockUser.set({ id: '1', name: 'John', email: 'john@test.com' });
    fixture.detectChanges();

    const card = fixture.nativeElement.querySelector('p-card');
    expect(card).toBeTruthy();
  });

  it('should show message when no user', () => {
    mockLoading.set(false);
    mockUser.set(null);
    fixture.detectChanges();

    expect(fixture.nativeElement.textContent).toContain('No user found');
  });
});
```

---

## Test Structure Pattern

```typescript
describe('[UnitName]', () => {
  // Setup
  let unit: UnitType;
  let mockDependency: jest.Mocked<DependencyType>;

  beforeEach(() => {
    // Arrange - Setup mocks and TestBed
  });

  describe('[methodName]', () => {
    it('should [expected behavior] when [condition]', () => {
      // Arrange - Setup specific state
      // Act - Call method
      // Assert - Verify result
    });
  });
});
```

---

## Mocking Patterns

### Service Mock
```typescript
const serviceMock = {
  getData: jest.fn().mockResolvedValue(mockData),
  saveData: jest.fn().mockResolvedValue(undefined),
} as unknown as jest.Mocked<DataService>;
```

### Signal Mock
```typescript
const mockSignal = signal(initialValue);

const facadeMock = {
  data: mockSignal.asReadonly(),
  loading: signal(false).asReadonly(),
};
```

### HttpClient Mock
```typescript
const httpMock = {
  get: jest.fn().mockReturnValue(of(mockResponse)),
  post: jest.fn().mockReturnValue(of(mockResponse)),
} as unknown as jest.Mocked<HttpClient>;
```

---

## Coverage Guidelines

### What to Test
- Public methods and properties
- Signal state changes
- Error handling
- Edge cases
- Input validation

### What NOT to Test
- Private methods directly
- Framework code (Angular internals)
- Third-party libraries
- Simple getters/setters

---

## Test File Naming

```
[component-name].component.spec.ts
[service-name].service.spec.ts
[facade-name].facade.spec.ts
[pipe-name].pipe.spec.ts
```

---

## Checklist

```markdown
- [ ] All public methods tested
- [ ] Mocks properly configured
- [ ] AAA pattern followed
- [ ] Signal states verified
- [ ] Error cases covered
- [ ] No implementation details tested
- [ ] Tests are independent
- [ ] Descriptive test names
```
