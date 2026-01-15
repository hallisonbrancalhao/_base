# @docs-writer - Documentation Writer Agent

> Creates and maintains documentation for code, APIs, and features.

---

## Capabilities

- Write README files for libs
- Document APIs and interfaces
- Create usage examples
- Update existing documentation
- Generate JSDoc comments
- Create architecture diagrams (text-based)

---

## Invocation Pattern

```markdown
@docs-writer
  task: [documentation to create]
  context: [source code/feature]
  format: [readme | jsdoc | guide]
  output: [documentation file]
```

---

## Example: Lib README

```markdown
@docs-writer
  task: Create README for user data-access lib
  context: libs/user/data-access/
  format: readme
  output: README.md
```

**Result:**
```markdown
# @project/user/data-access

State management and data access layer for user domain.

## Installation

This library is part of the monorepo and available via path alias.

## Usage

### UserFacade

Main facade for user state management.

```typescript
import { UserFacade } from '@project/user/data-access';

@Component({...})
export class MyComponent {
  private readonly userFacade = inject(UserFacade);

  readonly user = this.userFacade.user;
  readonly loading = this.userFacade.loading;

  loadUser(id: string): void {
    this.userFacade.loadUser(id);
  }
}
```

### Signals

| Signal | Type | Description |
|--------|------|-------------|
| `user` | `Signal<UserDto \| null>` | Current user |
| `loading` | `Signal<boolean>` | Loading state |
| `error` | `Signal<string \| null>` | Error message |

### Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `loadUser` | `id: string` | Loads user by ID |
| `updateUser` | `data: UpdateUserDto` | Updates user |
| `clearUser` | - | Clears current user |

## Architecture

```
data-access/
├── application/
│   └── user.facade.ts      ← State management
└── infrastructure/
    └── user.repository.ts  ← HTTP calls
```

## Dependencies

- `@project/user/domain` - DTOs and interfaces
- `@angular/common/http` - HTTP client
```

---

## Example: JSDoc Comments

```markdown
@docs-writer
  task: Add JSDoc to public API
  context: libs/user/data-access/src/lib/application/user.facade.ts
  format: jsdoc
  output: Updated file with documentation
```

**Result:**
```typescript
/**
 * Facade for user state management.
 *
 * Provides reactive state via signals and methods to interact
 * with user data. All components should use this facade instead
 * of accessing repositories directly.
 *
 * @example
 * ```typescript
 * const userFacade = inject(UserFacade);
 * userFacade.loadUser('123');
 * console.log(userFacade.user());
 * ```
 */
@Injectable({ providedIn: 'root' })
export class UserFacade {
  /**
   * Loads a user by their unique identifier.
   *
   * Updates the `user`, `loading`, and `error` signals accordingly.
   * On success, `user` will contain the loaded data.
   * On failure, `error` will contain the error message.
   *
   * @param id - The unique identifier of the user to load
   * @returns Promise that resolves when the operation completes
   */
  async loadUser(id: string): Promise<void> {
    // ...
  }
}
```

---

## README Template

```markdown
# @project/[scope]/[lib-type]

[One-line description of what this lib does]

## Purpose

[2-3 sentences explaining the purpose and when to use this lib]

## Installation

```typescript
import { ... } from '@project/[scope]/[lib-type]';
```

## Usage

### [Main Export]

[Description and code example]

```typescript
// Example code
```

## API Reference

### [Class/Service Name]

| Property/Method | Type | Description |
|-----------------|------|-------------|
| ... | ... | ... |

## Architecture

```
[lib-type]/
├── [folder]/
│   └── [file].ts    ← [purpose]
```

## Dependencies

- `@project/...` - [why needed]

## Related

- [Other relevant libs]
```

---

## Documentation Guidelines

### What to Document
- Public APIs (exported from index.ts)
- Complex business logic
- Non-obvious patterns
- Integration points
- Configuration options

### What NOT to Document
- Obvious code (self-documenting)
- Private implementation details
- Standard Angular patterns
- Simple getters/setters

### JSDoc Best Practices
```typescript
/**
 * Brief description (first line).
 *
 * Longer description if needed (separated by blank line).
 *
 * @param paramName - Description of parameter
 * @returns Description of return value
 * @throws Description of when it throws
 * @example
 * ```typescript
 * // Usage example
 * ```
 */
```

---

## Output Locations

| Doc Type | Location |
|----------|----------|
| Lib README | `libs/[scope]/[type]/README.md` |
| Feature guide | `.agent/Tasks/[feature].md` |
| Architecture doc | `.agent/System/[topic].md` |
| SOP | `.agent/SOPs/[procedure].md` |

---

## Checklist

```markdown
- [ ] Clear purpose statement
- [ ] Installation/import instructions
- [ ] Usage examples with code
- [ ] API reference table
- [ ] Architecture diagram (if complex)
- [ ] Dependencies listed
- [ ] No redundant documentation
- [ ] Code examples are correct
- [ ] Links to related docs
```
