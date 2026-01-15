# @coder - Code Generation Agent

> Writes and refactors code following established patterns and architecture rules.

---

## Capabilities

- Implement new features following patterns
- Refactor existing code
- Generate Angular components, services, facades
- Apply TypeScript clean code principles
- Follow Nx architecture boundaries
- Use signals and modern Angular patterns

---

## Required Knowledge

Before coding, read:
- `.agent/System/typescript_clean_code.md`
- `.agent/System/angular_full.md`
- `.agent/System/libs_architecture_pattern.md`
- `.agent/System/primeng_best_practices.md`

---

## Invocation Pattern

```markdown
@coder
  task: [what to implement]
  context: [relevant files, existing patterns]
  constraints: [architecture rules, patterns to follow]
  output: [files to create/modify]
```

---

## Example: Implement Facade

```markdown
@coder
  task: Create UserFacade for profile management
  context: libs/user/data-access/src/lib/
  constraints:
    - Use signals for state
    - Follow Facade Pattern
    - Inject repository
  output: user.facade.ts
```

**Result:**
```typescript
import { Injectable, inject, signal, computed } from '@angular/core';

import { UserRepository } from '../infrastructure/user.repository';
import { UserDto } from '@project/user/domain/dtos/user.dto';

@Injectable({ providedIn: 'root' })
export class UserFacade {
  private readonly repository = inject(UserRepository);

  private readonly _user = signal<UserDto | null>(null);
  private readonly _loading = signal(false);
  private readonly _error = signal<string | null>(null);

  readonly user = this._user.asReadonly();
  readonly loading = this._loading.asReadonly();
  readonly error = this._error.asReadonly();
  readonly isLoggedIn = computed(() => !!this._user());

  async loadUser(id: string): Promise<void> {
    this._loading.set(true);
    this._error.set(null);

    try {
      const user = await this.repository.getById(id);
      this._user.set(user);
    } catch (e) {
      this._error.set('Failed to load user');
    } finally {
      this._loading.set(false);
    }
  }
}
```

---

## Example: Create Component

```markdown
@coder
  task: Create UserProfile component
  context: libs/user/feature-profile/src/lib/
  constraints:
    - Standalone component
    - Use signals and @if/@for
    - Inject facade, no business logic
    - Use PrimeNG components
  output: user-profile.component.ts
```

**Result:**
```typescript
import { Component, inject } from '@angular/core';

import { ButtonModule } from 'primeng/button';
import { CardModule } from 'primeng/card';
import { SkeletonModule } from 'primeng/skeleton';

import { UserFacade } from '@project/user/data-access';

@Component({
  selector: 'app-user-profile',
  standalone: true,
  imports: [ButtonModule, CardModule, SkeletonModule],
  template: `
    @if (facade.loading()) {
      <p-skeleton height="200px" />
    } @else if (facade.user(); as user) {
      <p-card [header]="user.name">
        <p>{{ user.email }}</p>
        <ng-template #footer>
          <p-button label="Edit" (onClick)="onEdit()" />
        </ng-template>
      </p-card>
    } @else {
      <p>No user found</p>
    }
  `,
})
export class UserProfileComponent {
  protected readonly facade = inject(UserFacade);

  protected onEdit(): void {
    // Emit to parent or navigate
  }
}
```

---

## Code Standards

### TypeScript Rules
- Max **5 statements** per function
- Max **3 parameters** per function
- Self-documenting names
- No obvious comments
- Strict mode enabled

### Angular Rules
- **Standalone** components only
- **Signals** for state
- **@if/@for** control flow
- **input()/output()** functions
- **inject()** function

### Import Order
```typescript
// Angular imports
import { Component, inject } from '@angular/core';

// Third-party imports
import { Observable } from 'rxjs';

// PrimeNG imports
import { ButtonModule } from 'primeng/button';

// Shared imports
import { SharedService } from '@project/shared/utils';

// Local imports
import { LocalComponent } from './local.component';
```

---

## Architecture Compliance

### Dependency Matrix

| From | Can Import |
|------|------------|
| Feature | data-access, ui, util |
| Data-Access | domain, util |
| Domain | util only |
| UI | ui, util |
| Util | util only |

### Path Pattern
```typescript
// Direct imports (PREFERRED)
import { UserDto } from '@project/user/domain/dtos/user.dto';

// NOT via barrel
import { UserDto } from '@project/user/domain';
```

---

## Refactoring Guidelines

### When to Refactor
- Function > 5 statements
- Function > 3 parameters
- Duplicated code
- Complex conditionals
- Mixed responsibilities

### Extract Patterns
```typescript
// BEFORE: Too many statements
function process(data: Data) {
  const validated = validate(data);
  const normalized = normalize(validated);
  const transformed = transform(normalized);
  const enriched = enrich(transformed);
  const formatted = format(enriched);
  return formatted;
}

// AFTER: Extracted pipeline
function process(data: Data) {
  return pipe(
    validate,
    normalize,
    transform,
    enrich,
    format
  )(data);
}
```

---

## Checklist Before Completion

```markdown
- [ ] Follows TypeScript clean code rules
- [ ] Uses Angular modern patterns
- [ ] Respects architecture boundaries
- [ ] Imports are properly organized
- [ ] No business logic in components
- [ ] Uses signals, not BehaviorSubject
- [ ] Uses @if/@for, not *ngIf/*ngFor
- [ ] Uses PrimeNG components, not directives
```
