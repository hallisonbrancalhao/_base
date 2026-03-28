---
name: type-safety-auditor
description: |
  Type Safety Scanner - Scans codebase for weak typing patterns: any usage, missing generics, implicit any, unsafe casting.
  Recommends type-safe alternatives based on architecture knowledge base patterns.
  TRIGGERS: type audit, type safety, find any, type check, weak types, type scan, audit types, verificar tipos
---

# @type-safety-auditor - Type Safety Scanner

Scans for weak typing patterns and recommends type-safe alternatives from the architecture knowledge base.

## Required Reading

- `.agent/System/architecture-knowledge/09-TYPE-SAFETY-PATTERNS.md`
- `.agent/System/architecture-knowledge/06-REPOSITORY-PATTERN.md` (generic services)
- `.agent/System/architecture-knowledge/15-FORM-ARCHITECTURE.md` (TypedForm)
- `.agent/System/typescript_clean_code.md`

## Invocation Pattern

```
@type-safety-auditor
  scope: [files | project | scope | affected | all]
  severity: [all | critical | high]
  fix: [true | false]
```

## Violation Categories

### CRITICAL - Must Fix

#### 1. Explicit `any` Type

```bash
grep -rn ": any\b" --include="*.ts" | grep -v "node_modules\|.spec.ts\|.d.ts"
```

```typescript
// VIOLATION
function process(data: any): any { ... }
let config: any = {};

// FIX: Use proper types
function process(data: ProcessInput): ProcessOutput { ... }
let config: AppConfig = {};
```

#### 2. `as any` Casting

```bash
grep -rn "as any" --include="*.ts" | grep -v "node_modules\|.spec.ts"
```

```typescript
// VIOLATION
const result = someValue as any;
(window as any).customProp = value;

// FIX: Use proper type narrowing or declaration merging
const result = someValue as SpecificType;
declare global { interface Window { customProp: Type; } }
```

#### 3. `@ts-ignore` / `@ts-expect-error` Without Justification

```bash
grep -rn "@ts-ignore\|@ts-expect-error" --include="*.ts" | grep -v "node_modules"
```

### HIGH - Should Fix

#### 4. Untyped Function Parameters

```bash
# Functions with parameters that have no type annotation
grep -rn "function.*([a-zA-Z_][a-zA-Z0-9_]*[,)]" --include="*.ts" | grep -v ": "
```

```typescript
// VIOLATION
function process(data, options) { ... }

// FIX
function process(data: ProcessData, options: ProcessOptions): Result { ... }
```

#### 5. Missing Return Types on Public Methods

```typescript
// VIOLATION
class UserService {
  findAll() { return this.repo.find(); }
}

// FIX
class UserService {
  findAll(): Promise<User[]> { return this.repo.find(); }
}
```

#### 6. Untyped Collections

```typescript
// VIOLATION
const items = [];
const map = new Map();
const set = new Set();

// FIX
const items: User[] = [];
const map = new Map<string, User>();
const set = new Set<string>();
```

#### 7. Missing Generic Constraints

```typescript
// VIOLATION
class BaseService<T> { ... }

// FIX: Constrain T to Entity
class BaseService<T extends Entity> { ... }
```

#### 8. Object/unknown Used as Map

```typescript
// VIOLATION
const config: { [key: string]: any } = {};
const data: Record<string, any> = {};

// FIX
const config: AppConfig = {};
const data: Record<string, SpecificType> = {};
```

### MEDIUM - Fix When Possible

#### 9. Non-strict Equality in Type Guards

```typescript
// VIOLATION
if (value == null) { ... }
if (status == 'active') { ... }

// FIX
if (value === null || value === undefined) { ... }
if (status === 'active') { ... }
```

#### 10. Missing Discriminated Union

```typescript
// VIOLATION
interface ApiResponse {
  success: boolean;
  data?: Data;
  error?: string;
}

// FIX
type ApiResponse =
  | { success: true; data: Data }
  | { success: false; error: string };
```

#### 11. Forms Without TypedForm

```typescript
// VIOLATION
const form = new FormGroup({
  name: new FormControl(''),
  email: new FormControl(''),
});

// FIX
type UserForm = TypedForm<UserDto>;
const form = new FormGroup<UserForm>({
  name: new FormControl(''),
  email: new FormControl(''),
});
```

#### 12. Missing Utility Types

```typescript
// VIOLATION: Manual omit of fields
interface CreateUser {
  name: string;
  email: string;
  // manually copied from User without id, createdAt, updatedAt
}

// FIX: Use EditableEntity
type CreateUser = EditableEntity<User>;
```

## Scan Commands

```bash
# Full scan for any
grep -rn ": any\b\|as any\|<any>" libs/ --include="*.ts" -l | grep -v "node_modules\|.spec.ts\|.d.ts"

# Count by file
grep -rn ": any\b\|as any" libs/ --include="*.ts" -c | grep -v ":0$" | sort -t: -k2 -nr

# Find untyped functions
grep -rn "function [a-zA-Z_].*([^)]*[a-zA-Z_][a-zA-Z0-9_]*[,)]" libs/ --include="*.ts" | grep -v ": \|.spec.ts\|.d.ts"

# Find untyped arrays
grep -rn "= \[\];" libs/ --include="*.ts" | grep -v "node_modules\|.spec.ts"

# Find ts-ignore
grep -rn "@ts-ignore\|@ts-expect-error" libs/ --include="*.ts" | grep -v "node_modules"

# TypeScript strict mode check
find libs/ -name "tsconfig*.json" -exec grep -L '"strict": true' {} \;
```

## Scoring

| Category | Weight |
|----------|--------|
| Explicit `any` count | 30% |
| `as any` casting | 20% |
| Untyped parameters/returns | 20% |
| Missing generics | 15% |
| Missing utility types | 10% |
| ts-ignore usage | 5% |

**Score = 100 - (weighted violation count)**

## Output Format

```markdown
# Type Safety Audit Report

**Scope**: [scope]
**Score**: [score]/100
**Total Violations**: [count]

## Summary
| Category | Count | Severity |
|----------|-------|----------|
| Explicit `any` | X | CRITICAL |
| `as any` casting | X | CRITICAL |
| Untyped params | X | HIGH |
| Missing return types | X | HIGH |
| Untyped collections | X | HIGH |
| Missing generics | X | HIGH |
| Missing TypedForm | X | MEDIUM |
| Missing utility types | X | MEDIUM |

## Top Offenders (files with most violations)
| File | Violations | Types |
|------|-----------|-------|
| path/file.ts | X | any(3), untyped(2) |

## Remediation Guide
1. [CRITICAL] Replace `any` in [file:line] with [suggested type]
2. ...

## Quick Wins (easy fixes)
- [list of simple type additions]
```
