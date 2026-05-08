# Nx Architecture Rules

**Last update**: 2026-05-08
**Version**: 1.1.0
**Owner**: Architecture Team

---

## 📌 Summary

This document defines the strict architectural rules for the Nx monorepo workspace, including library dependency constraints and the Facade Pattern for state management.

---

## 🚫 REGRA CRÍTICA — Imports DTO no FE

`type:data-access`, `type:feature`, `type:ui` e `type:app` **NÃO PODEM** importar arquivos `*.dto.ts` que contenham decorators de `class-validator` ou `class-transformer`. Use as interfaces irmãs (`*.interface.ts`).

**Por quê:** decorators de `class-validator`/`class-transformer` chamam `Reflect.getMetadata` em runtime. O Vite/esbuild pré-bundla `reflect-metadata` num IIFE que escopa a global Reflect incorretamente, quebrando o boot do app no browser com `Uncaught TypeError: Reflect.getMetadata is not a function`. Além disso, essas libs adicionam ~80 KB ao bundle FE sem benefício.

**Configurar `bannedExternalImports`** em `eslint.config.mjs` (regra `@nx/enforce-module-boundaries`):

```js
{
  sourceTag: 'type:data-access',
  bannedExternalImports: ['class-validator', 'class-transformer'],
},
{
  sourceTag: 'type:feature',
  bannedExternalImports: ['class-validator', 'class-transformer'],
},
{
  sourceTag: 'type:ui',
  bannedExternalImports: ['class-validator', 'class-transformer'],
},
{
  sourceTag: 'type:app',
  bannedExternalImports: ['class-validator', 'class-transformer'],
},
```

Detalhes em `.agent/System/interface-dto-architecture.md`.

---

## 🏗️ Library Types and Dependencies

The Nx workspace uses a strict dependency graph to enforce architectural boundaries. Each library type has specific rules about what it can depend on.

### Library Type Hierarchy

```
Shell
  ↓
Feature
  ↓
Data-Access
  ↓
Domain
  ↓
API

UI ← (can be used at any level)
Util ← (can be used at any level)
```

---

## 📋 Dependency Rules

### ✅ Shell Libraries
**Purpose**: Application shells, routing configuration, top-level orchestration

**Can depend on**:
- ✅ Feature libraries
- ✅ Data-access libraries
- ✅ UI libraries
- ✅ Util libraries

**Cannot depend on**:
- ❌ Other shell libraries
- ❌ Domain libraries (must go through data-access)
- ❌ API libraries (must go through data-access)

**Example**:
```typescript
// ✅ CORRECT
import { MyTodosFeatureModule } from '@workflow/my-todos/feature-my-todos';
import { ButtonComponent } from '@workflow/ui-components';
import { DateUtil } from '@workflow/utils';

// ❌ WRONG
import { MyTodosApi } from '@workflow/my-todos/api'; // Skip data-access layer
```

---

### ✅ Feature Libraries
**Purpose**: Smart components, feature-specific logic, facades

**Can depend on**:
- ✅ Data-access libraries
- ✅ UI libraries
- ✅ Util libraries

**Cannot depend on**:
- ❌ Shell libraries
- ❌ Other feature libraries
- ❌ Domain libraries (must go through data-access)
- ❌ API libraries (must go through data-access)

**Example**:
```typescript
// ✅ CORRECT
import { MyTodosDataAccess } from '@workflow/my-todos/data-access';
import { TodoListComponent } from '@workflow/ui-todo-list';
import { formatDate } from '@workflow/utils';

// ❌ WRONG
import { UserFeature } from '@workflow/users/feature-users'; // Cross-feature dependency
import { TodosDomain } from '@workflow/my-todos/domain'; // Skip data-access layer
```

---

### ✅ Data-Access Libraries
**Purpose**: State management, API orchestration, data transformation

**Can depend on**:
- ✅ Domain libraries
- ✅ Util libraries

**Cannot depend on**:
- ❌ Shell libraries
- ❌ Feature libraries
- ❌ UI libraries
- ❌ API libraries (must go through domain)

**Example**:
```typescript
// ✅ CORRECT
import { TodosRepository } from '@workflow/my-todos/domain';
import { HttpUtil } from '@workflow/utils';

// ❌ WRONG
import { TodoListComponent } from '@workflow/ui-todo-list'; // UI in data-access
import { MyTodosApi } from '@workflow/my-todos/api'; // Skip domain layer
```

---

### ✅ Domain Libraries
**Purpose**: Repository interfaces, domain models, business rules

**Can depend on**:
- ✅ API libraries
- ✅ Util libraries

**Cannot depend on**:
- ❌ Shell libraries
- ❌ Feature libraries
- ❌ Data-access libraries
- ❌ UI libraries

**Example**:
```typescript
// ✅ CORRECT
import { MyTodosApi } from '@workflow/my-todos/api';
import { ValidationUtil } from '@workflow/utils';

// ❌ WRONG
import { MyTodosDataAccess } from '@workflow/my-todos/data-access'; // Wrong direction
```

---

### ✅ UI Libraries
**Purpose**: Presentational/dumb components, reusable UI elements

**Can depend on**:
- ✅ Other UI libraries
- ✅ Util libraries

**Cannot depend on**:
- ❌ Shell libraries
- ❌ Feature libraries
- ❌ Data-access libraries
- ❌ Domain libraries
- ❌ API libraries

**Example**:
```typescript
// ✅ CORRECT
import { IconComponent } from '@workflow/ui-icons';
import { formatCurrency } from '@workflow/utils';

// ❌ WRONG
import { MyTodosDataAccess } from '@workflow/my-todos/data-access'; // UI should be dumb
```

---

### ✅ Util Libraries
**Purpose**: Pure utility functions, helpers, shared types

**Can depend on**:
- ✅ Other util libraries only

**Cannot depend on**:
- ❌ Any other library type

**Example**:
```typescript
// ✅ CORRECT
import { DateUtil } from '@workflow/utils/date';

// ❌ WRONG
import { MyTodosApi } from '@workflow/my-todos/api'; // Utils should be pure
```

---

### ✅ API Libraries
**Purpose**: API clients, GraphQL queries/mutations, HTTP services

**Can depend on**:
- ✅ Libraries within their own scope only

**Cannot depend on**:
- ❌ Libraries from other scopes

**Example**:
```typescript
// ✅ CORRECT
import { TodoDto } from '@workflow/my-todos/api'; // Same scope

// ❌ WRONG
import { UserApi } from '@workflow/users/api'; // Cross-scope dependency
```

---

## 🎭 State Management: Facade Pattern

All component logic and state management **MUST** be handled through the **Facade Pattern**. Components should be "dumb" (presentational) and only consume and display data from facades.

### Facade Responsibilities

Facades are responsible for:
- ✅ Managing component state (using signals or state management)
- ✅ Handling business logic
- ✅ Orchestrating API calls via data-access services
- ✅ Exposing observables/signals for components to consume
- ✅ Coordinating multiple data sources if needed

### Component Responsibilities

Components **must**:
- ✅ Be presentational only (dumb/stateless)
- ✅ Subscribe to facade observables/signals
- ✅ Emit user actions back to the facade
- ✅ Contain minimal to no business logic
- ✅ Focus solely on template rendering and user interaction

---

## 📝 Facade Pattern Examples

### ✅ CORRECT Implementation

**Facade** (in feature library):
```typescript
// libs/my-todos/feature-my-todos-list/src/lib/my-todos-list.facade.ts
import { Injectable, inject, signal, computed } from '@angular/core';
import { MyTodosDataAccess } from '@workflow/my-todos/data-access';

@Injectable()
export class MyTodosListFacade {
  private dataAccess = inject(MyTodosDataAccess);

  // State
  private todosState = signal<Todo[]>([]);
  private loadingState = signal<boolean>(false);
  private errorState = signal<string | null>(null);

  // Public read-only signals
  readonly todos = computed(() => this.todosState());
  readonly loading = computed(() => this.loadingState());
  readonly error = computed(() => this.errorState());
  readonly hasTodos = computed(() => this.todosState().length > 0);

  // Actions
  async loadTodos(): Promise<void> {
    this.loadingState.set(true);
    this.errorState.set(null);

    try {
      const todos = await this.dataAccess.getTodos();
      this.todosState.set(todos);
    } catch (error) {
      this.errorState.set('Failed to load todos');
    } finally {
      this.loadingState.set(false);
    }
  }

  async addTodo(title: string): Promise<void> {
    try {
      const newTodo = await this.dataAccess.createTodo({ title });
      this.todosState.update(todos => [...todos, newTodo]);
    } catch (error) {
      this.errorState.set('Failed to add todo');
    }
  }

  async deleteTodo(id: string): Promise<void> {
    try {
      await this.dataAccess.deleteTodo(id);
      this.todosState.update(todos => todos.filter(t => t.id !== id));
    } catch (error) {
      this.errorState.set('Failed to delete todo');
    }
  }
}
```

**Component** (presentational/dumb):
```typescript
// libs/my-todos/feature-my-todos-list/src/lib/my-todos-list.component.ts
import { Component, inject, OnInit, ChangeDetectionStrategy } from '@angular/core';
import { MyTodosListFacade } from './my-todos-list.facade';

@Component({
  selector: 'app-my-todos-list',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [MyTodosListFacade],
  template: `
    <div data-testid="todos-container">
      @if (facade.loading()) {
        <div data-testid="loading">Loading...</div>
      }

      @if (facade.error()) {
        <div data-testid="error">{{ facade.error() }}</div>
      }

      @if (facade.hasTodos()) {
        <ul data-testid="todos-list">
          @for (todo of facade.todos(); track todo.id) {
            <li [data-testid]="'todo-' + todo.id">
              {{ todo.title }}
              <button
                [data-testid]="'delete-' + todo.id"
                (click)="onDeleteTodo(todo.id)">
                Delete
              </button>
            </li>
          }
        </ul>
      } @else {
        <div data-testid="empty-state">No todos yet</div>
      }

      <button
        data-testid="add-todo-btn"
        (click)="onAddTodo()">
        Add Todo
      </button>
    </div>
  `
})
export class MyTodosListComponent implements OnInit {
  protected readonly facade = inject(MyTodosListFacade);

  ngOnInit(): void {
    this.facade.loadTodos();
  }

  protected onDeleteTodo(id: string): void {
    this.facade.deleteTodo(id);
  }

  protected onAddTodo(): void {
    this.facade.addTodo('New Todo');
  }
}
```

---

### ❌ WRONG Implementation

**Component with business logic** (anti-pattern):
```typescript
// ❌ WRONG - Component has too much logic
@Component({
  selector: 'app-my-todos-list',
  template: `...`
})
export class MyTodosListComponent {
  private dataAccess = inject(MyTodosDataAccess);

  todos = signal<Todo[]>([]);
  loading = signal<boolean>(false);

  // ❌ Business logic in component
  async loadTodos(): Promise<void> {
    this.loading.set(true);
    try {
      const todos = await this.dataAccess.getTodos();
      this.todos.set(todos);
    } catch (error) {
      console.error('Failed to load todos', error);
    } finally {
      this.loading.set(false);
    }
  }

  // ❌ More business logic in component
  async deleteTodo(id: string): Promise<void> {
    try {
      await this.dataAccess.deleteTodo(id);
      this.todos.update(todos => todos.filter(t => t.id !== id));
    } catch (error) {
      console.error('Failed to delete todo', error);
    }
  }
}
```

**Why this is wrong**:
- ❌ Component directly injects data-access (should use facade)
- ❌ Business logic (error handling, state updates) in component
- ❌ Component is not easily testable (must mock data-access)
- ❌ Cannot reuse logic in other components
- ❌ Violates single responsibility principle

---

## 🧪 Testing Facades vs Components

### Testing Facades
**Focus**: Business logic, state management, data orchestration

```typescript
describe('MyTodosListFacade', () => {
  let facade: MyTodosListFacade;
  let mockDataAccess: jest.Mocked<MyTodosDataAccess>;

  beforeEach(() => {
    mockDataAccess = {
      getTodos: jest.fn(),
      createTodo: jest.fn(),
      deleteTodo: jest.fn()
    } as any;

    TestBed.configureTestingModule({
      providers: [
        MyTodosListFacade,
        { provide: MyTodosDataAccess, useValue: mockDataAccess }
      ]
    });

    facade = TestBed.inject(MyTodosListFacade);
  });

  it('should load todos and update state', async () => {
    const mockTodos = [{ id: '1', title: 'Test' }];
    mockDataAccess.getTodos.mockResolvedValue(mockTodos);

    await facade.loadTodos();

    expect(facade.todos()).toEqual(mockTodos);
    expect(facade.loading()).toBe(false);
  });

  it('should handle errors', async () => {
    mockDataAccess.getTodos.mockRejectedValue(new Error('API Error'));

    await facade.loadTodos();

    expect(facade.error()).toBe('Failed to load todos');
  });
});
```

### Testing Components
**Focus**: Template rendering, user interaction, facade integration

```typescript
describe('MyTodosListComponent', () => {
  let fixture: ComponentFixture<MyTodosListComponent>;
  let mockFacade: jest.Mocked<MyTodosListFacade>;

  beforeEach(async () => {
    mockFacade = {
      todos: signal([]),
      loading: signal(false),
      error: signal(null),
      hasTodos: computed(() => false),
      loadTodos: jest.fn(),
      addTodo: jest.fn(),
      deleteTodo: jest.fn()
    } as any;

    await TestBed.configureTestingModule({
      imports: [MyTodosListComponent],
      providers: [
        { provide: MyTodosListFacade, useValue: mockFacade }
      ],
      schemas: [NO_ERRORS_SCHEMA, CUSTOM_ELEMENTS_SCHEMA]
    }).compileComponents();

    fixture = TestBed.createComponent(MyTodosListComponent);
  });

  it('should display todos from facade', () => {
    mockFacade.todos.set([{ id: '1', title: 'Test Todo' }]);
    mockFacade.hasTodos = computed(() => true);
    fixture.detectChanges();

    const todo = fixture.debugElement.query(By.css('[data-testid="todo-1"]'));
    expect(todo.nativeElement.textContent).toContain('Test Todo');
  });

  it('should call facade when delete button clicked', () => {
    mockFacade.todos.set([{ id: '1', title: 'Test' }]);
    fixture.detectChanges();

    const deleteBtn = fixture.debugElement.query(By.css('[data-testid="delete-1"]'));
    deleteBtn.triggerEventHandler('click', null);

    expect(mockFacade.deleteTodo).toHaveBeenCalledWith('1');
  });
});
```

---

## 📊 Architecture Enforcement

### Nx Enforce Module Boundaries

The dependency rules are enforced by Nx's `enforce-module-boundaries` ESLint rule configured in `.eslintrc.json`:

```json
{
  "@nx/enforce-module-boundaries": [
    "error",
    {
      "allow": [],
      "depConstraints": [
        {
          "sourceTag": "type:shell",
          "onlyDependOnLibsWithTags": [
            "type:feature",
            "type:data-access",
            "type:ui",
            "type:util"
          ]
        },
        {
          "sourceTag": "type:feature",
          "onlyDependOnLibsWithTags": [
            "type:data-access",
            "type:ui",
            "type:util"
          ]
        },
        {
          "sourceTag": "type:data-access",
          "onlyDependOnLibsWithTags": [
            "type:domain",
            "type:util"
          ]
        },
        {
          "sourceTag": "type:domain",
          "onlyDependOnLibsWithTags": [
            "type:api",
            "type:util"
          ]
        },
        {
          "sourceTag": "type:ui",
          "onlyDependOnLibsWithTags": [
            "type:ui",
            "type:util"
          ]
        },
        {
          "sourceTag": "type:util",
          "onlyDependOnLibsWithTags": [
            "type:util"
          ]
        },
        {
          "sourceTag": "type:api",
          "onlyDependOnLibsWithTags": [
            "type:api"
          ],
          "bannedExternalImports": ["*"],
          "allowCircularSelfDependency": false
        }
      ]
    }
  ]
}
```

### Verifying Architecture

```bash
# Check for architecture violations
nx lint

# Visualize project graph
nx graph

# Check specific project dependencies
nx graph --focus=my-todos-feature-my-todos-list
```

---

## ✅ Best Practices Checklist

### When Creating New Feature
- [ ] Create facade in data-access library
- [ ] Facade handles all business logic
- [ ] Component only renders and emits events
- [ ] Facade uses data-access services (not API directly)
- [ ] Component tests mock facade
- [ ] Facade tests mock data-access

### When Creating New Library
- [ ] Tag library with correct type (`type:feature`, `type:ui`, etc.)
- [ ] Verify dependencies follow rules
- [ ] Run `nx lint` to check for violations
- [ ] Document library purpose in README

### Code Review Checklist
- [ ] No business logic in components
- [ ] Components use facade pattern
- [ ] Dependency graph follows rules
- [ ] No circular dependencies
- [ ] Tests follow separation (facade vs component)

---

## 🚫 Common Violations

### ❌ Violation 1: Feature depending on another Feature
```typescript
// ❌ WRONG
import { UserFeature } from '@workflow/users/feature-users';
```

**Solution**: Extract shared logic to data-access or domain library

---

### ❌ Violation 2: UI component with state management
```typescript
// ❌ WRONG - UI component with data-access
@Component({...})
export class TodoListComponent {
  private dataAccess = inject(MyTodosDataAccess);
}
```

**Solution**: Move to feature component with facade, or keep UI truly dumb

---

### ❌ Violation 3: Component with business logic
```typescript
// ❌ WRONG - Business logic in component
async deleteTodo(id: string) {
  try {
    await this.api.delete(id);
    this.todos.update(todos => todos.filter(t => t.id !== id));
  } catch (error) {
    this.showError('Failed to delete');
  }
}
```

**Solution**: Move all logic to facade

---

## 📚 References

- [Nx Documentation](https://nx.dev)
- [Nx Module Boundaries](https://nx.dev/core-features/enforce-module-boundaries)
- [Facade Pattern](https://refactoring.guru/design-patterns/facade)
- [Smart vs Dumb Components](https://medium.com/@dan_abramov/smart-and-dumb-components-7ca2f9a7c7d0)

---

**Remember**: Architecture rules exist to maintain scalability and maintainability. Follow them strictly!
