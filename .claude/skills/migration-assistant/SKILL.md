---
name: migration-assistant
description: |
  Legacy Pattern Migrator - Migrates Angular/TypeScript code from legacy patterns to modern ones.
  Handles NgModules to standalone, *ngIf to @if, decorators to functions, BehaviorSubject to signals, PrimeNG directives to components.
  TRIGGERS: migrate, migration, modernize, upgrade pattern, legacy to modern, convert ngIf, convert to signals, migrate standalone, modernizar
---

# @migration-assistant - Legacy Pattern Migrator

Migrates code from legacy Angular/TypeScript patterns to modern equivalents defined in the architecture knowledge base.

## Required Reading

- `.agent/System/architecture-knowledge/12-FRONTEND-PATTERNS.md`
- `.agent/System/architecture-knowledge/08-REACTIVE-PROGRAMMING.md`
- `.agent/System/architecture-knowledge/07-STATE-MANAGEMENT.md`
- `.agent/System/angular_best_practices.md`
- `.agent/System/primeng_best_practices.md`

## Invocation Pattern

```
@migration-assistant
  migration: [migration-type]
  scope: [files | project | scope | affected]
  mode: report | fix
```

## Available Migrations

### 1. `standalone` - NgModules to Standalone Components

**Detect:**
```typescript
// LEGACY
@NgModule({ declarations: [MyComponent], imports: [...], exports: [...] })
export class MyModule {}
```

**Migrate to:**
```typescript
// MODERN
@Component({
  standalone: true,
  imports: [CommonModule, ...requiredModules],
  // ... rest of component
})
export class MyComponent {}
```

**Steps:**
1. Find all `@NgModule` declarations
2. Identify components declared in each module
3. Add `standalone: true` to each component
4. Move module imports to component imports
5. Remove the module file
6. Update all references (routes, other imports)

### 2. `control-flow` - *ngIf/*ngFor to @if/@for

**Detect:**
```html
<!-- LEGACY -->
<div *ngIf="condition">...</div>
<div *ngIf="condition; else elseBlock">...</div>
<div *ngFor="let item of items; trackBy: trackByFn">...</div>
<div [ngSwitch]="value">
  <span *ngSwitchCase="'a'">A</span>
</div>
```

**Migrate to:**
```html
<!-- MODERN -->
@if (condition) { <div>...</div> }
@if (condition) { <div>...</div> } @else { ... }
@for (item of items; track item.id) { <div>...</div> }
@switch (value) {
  @case ('a') { <span>A</span> }
}
```

**Steps:**
1. Parse template for *ngIf, *ngFor, [ngSwitch] usage
2. Convert each to @if/@for/@switch syntax
3. Remove ng-template#elseBlock references
4. Convert trackBy functions to track expressions
5. Remove CommonModule import if no other directives used

### 3. `signals` - BehaviorSubject to Signals

**Detect:**
```typescript
// LEGACY
private subject$ = new BehaviorSubject<string>('');
value$ = this.subject$.asObservable();
// In template: {{ value$ | async }}
```

**Migrate to:**
```typescript
// MODERN
value = signal<string>('');
// In template: {{ value() }}
```

**Steps:**
1. Find BehaviorSubject declarations in components/facades
2. Convert to signal() with same initial value
3. Replace .next() with .set() or .update()
4. Replace .pipe(map(...)) with computed()
5. Replace async pipe in templates with signal calls
6. Remove RxJS imports if no longer needed

### 4. `inputs-outputs` - Decorators to Functions

**Detect:**
```typescript
// LEGACY
@Input() name: string = '';
@Input() set data(value: Data) { this._data = value; }
@Output() clicked = new EventEmitter<void>();
```

**Migrate to:**
```typescript
// MODERN
name = input<string>('');
data = input<Data>();
clicked = output<void>();
```

**Steps:**
1. Find @Input() and @Output() decorators
2. Convert to input() and output() functions
3. Handle required inputs: `input.required<Type>()`
4. Handle setter inputs: use `effect()` for side effects
5. Replace EventEmitter with output()
6. Update template references if needed

### 5. `inject` - Constructor Injection to inject()

**Detect:**
```typescript
// LEGACY
constructor(
  private readonly userService: UserService,
  private readonly router: Router,
  @Inject(TOKEN) private readonly config: Config
) {}
```

**Migrate to:**
```typescript
// MODERN
private readonly userService = inject(UserService);
private readonly router = inject(Router);
private readonly config = inject(TOKEN);
```

**Steps:**
1. Find constructor parameters with injection
2. Convert each to class field with inject()
3. Handle @Inject() tokens
4. Handle @Optional() with second arg
5. Remove constructor if empty after migration

### 6. `primeng` - Directives to Components

**Detect:**
```html
<!-- LEGACY -->
<button pButton label="Save"></button>
<input pInputText />
<p-dropdown [options]="opts"></p-dropdown>
<p-calendar [(ngModel)]="date"></p-calendar>
<ng-template pTemplate="body">...</ng-template>
```

**Migrate to:**
```html
<!-- MODERN -->
<p-button label="Save"></p-button>
<p-inputtext />
<p-select [options]="opts"></p-select>
<p-date-picker [(ngModel)]="date"></p-date-picker>
<ng-template #body>...</ng-template>
```

**Steps:**
1. Find PrimeNG directive usage in templates
2. Convert to component equivalents
3. Update imports (ButtonModule stays, but usage changes)
4. Handle pTemplate to #template conversion
5. Verify PrimeNG version compatibility

### 7. `barrel-to-direct` - Barrel Imports to Direct

**Detect:**
```typescript
// LEGACY
import { UserDto, CreateUserDto } from '@project/user/domain';
```

**Migrate to:**
```typescript
// MODERN
import { UserDto } from '@project/user/domain/dtos/user.dto';
import { CreateUserDto } from '@project/user/domain/dtos/create-user.dto';
```

**Steps:**
1. Find barrel imports (imports from index.ts paths)
2. Trace each symbol to its source file
3. Replace with direct import path
4. Verify tsconfig.base.json has wildcard paths configured

## Output Format

### Report Mode
```markdown
## Migration Report: [migration-type]

**Scope**: [scope]
**Files Affected**: [count]
**Estimated Changes**: [count]

### Files Requiring Migration
| File | Pattern Found | Occurrences |
|------|--------------|-------------|
| path/file.ts | *ngIf | 3 |
| path/file.ts | *ngFor | 2 |

### Migration Plan
1. [file] - [changes needed]
2. ...

### Risks
- [potential breaking changes]
```

### Fix Mode
```markdown
## Migration Complete: [migration-type]

**Files Modified**: [count]
**Changes Made**: [count]

### Changes
| File | Before | After |
|------|--------|-------|
| path/file.ts | *ngIf="x" | @if (x) |

### Verification
- [ ] `nx affected:lint` passes
- [ ] `nx affected:test` passes
- [ ] `nx affected:build` passes
```
