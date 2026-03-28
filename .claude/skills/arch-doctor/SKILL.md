---
name: arch-doctor
description: |
  Deep Architecture Health Check - Comprehensive audit using all 19 architecture knowledge base documents.
  Validates clean architecture layers, DDD compliance, type safety, reactive patterns, error handling, and more.
  TRIGGERS: arch doctor, architecture health, deep audit, architecture check, full audit, health check, architecture score
---

# @arch-doctor - Deep Architecture Health Check

Comprehensive architecture audit that validates code against ALL patterns defined in `.agent/System/architecture-knowledge/`.

## Required Reading

Before auditing, load these knowledge base documents based on check scope:

| Check | Document |
|-------|----------|
| Layer dependencies | `architecture-knowledge/01-CLEAN-ARCHITECTURE.md` |
| DDD compliance | `architecture-knowledge/02-DOMAIN-DRIVEN-DESIGN.md` |
| Use case structure | `architecture-knowledge/03-USE-CASE-PATTERN.md` |
| Port/adapter pairs | `architecture-knowledge/04-PORTS-AND-ADAPTERS.md` |
| DI correctness | `architecture-knowledge/05-DEPENDENCY-INJECTION.md` |
| Repository pattern | `architecture-knowledge/06-REPOSITORY-PATTERN.md` |
| State management | `architecture-knowledge/07-STATE-MANAGEMENT.md` |
| Reactive patterns | `architecture-knowledge/08-REACTIVE-PROGRAMMING.md` |
| Type safety | `architecture-knowledge/09-TYPE-SAFETY-PATTERNS.md` |
| Module boundaries | `architecture-knowledge/10-MODULE-BOUNDARIES.md` |
| Monorepo structure | `architecture-knowledge/11-MONOREPO-ARCHITECTURE.md` |
| Frontend patterns | `architecture-knowledge/12-FRONTEND-PATTERNS.md` |
| Backend patterns | `architecture-knowledge/13-BACKEND-PATTERNS.md` |
| Error handling | `architecture-knowledge/14-ERROR-HANDLING.md` |
| Form architecture | `architecture-knowledge/15-FORM-ARCHITECTURE.md` |
| Auth patterns | `architecture-knowledge/16-AUTHENTICATION-AUTHORIZATION.md` |
| Code generation | `architecture-knowledge/17-CODE-GENERATION.md` |
| Testing/CI | `architecture-knowledge/18-TESTING-CI-CD.md` |
| Design patterns | `architecture-knowledge/19-DESIGN-PATTERNS-CATALOG.md` |

Also read project-specific rules:
- `.agent/System/libs_architecture_pattern.md`
- `.agent/System/nx_architecture_rules.md`
- `.agent/System/base_rules.md`

## Invocation Pattern

```
@arch-doctor
  scope: [project-name | scope-name | all | affected]
  depth: [quick | standard | deep]
  focus: [all | layers | ddd | types | reactive | frontend | backend | security]
```

## Audit Categories

### 1. Clean Architecture Layers (01, 10, 11)

```bash
# Check: Domain libs must NOT import Angular, NestJS, or infrastructure
grep -r "from '@angular" libs/*/domain/
grep -r "from '@nestjs" libs/*/domain/
grep -r "HttpClient" libs/*/domain/

# Check: Feature libs must NOT import data-source
grep -r "data-source" libs/*/feature-*/

# Check: UI libs must NOT import data-access or data-source
grep -r "data-access\|data-source" libs/shared/ui-*/
```

**Violations:**
- Domain importing Angular/NestJS/HTTP = CRITICAL
- Feature importing data-source = CRITICAL
- UI importing data-access = HIGH
- Circular dependency between libs = CRITICAL

### 2. DDD Compliance (02)

```bash
# Check: Entities must have id field (interface with id: string)
# Check: DTOs in domain/ only, not in feature/ or data-access/
# Check: Bounded contexts don't cross-import (scope A domain != scope B domain)
# Check: Reference pattern used for cross-context (UserRef, not full User)
```

**Violations:**
- Entity without `id` field = HIGH
- DTO outside domain lib = MEDIUM
- Cross-scope domain import = HIGH
- Full entity reference instead of Ref = MEDIUM

### 3. Use Case Pattern (03)

```bash
# Check: Use cases implement execute() method
# Check: Input/Output types are defined
# Check: One use case per file
# Check: No framework imports in use cases
```

**Violations:**
- Missing `execute()` method = HIGH
- Untyped input/output = MEDIUM
- Multiple use cases per file = LOW
- Framework coupling in use case = HIGH

### 4. Ports & Adapters (04)

```bash
# Check: Every concrete service has an abstract port
# Check: Domain references ports, never adapters
# Check: Provider functions connect port to adapter
```

**Violations:**
- Concrete service without abstract port = HIGH
- Domain referencing concrete adapter = CRITICAL
- Missing provider function = MEDIUM

### 5. Type Safety (09)

```bash
# Check: No explicit 'any' type
grep -rn ": any" libs/ --include="*.ts" | grep -v "node_modules\|.spec.ts\|.test.ts"

# Check: No implicit any (tsconfig strict)
# Check: Generic constraints on base classes
# Check: Proper utility types (EditableEntity, TypedForm)
```

**Violations:**
- Explicit `: any` = HIGH
- `as any` casting = HIGH
- Missing generic constraints = MEDIUM
- Implicit any from missing types = MEDIUM

### 6. Reactive Patterns (08)

```bash
# Check: No .subscribe() without takeUntilDestroyed()
grep -rn "\.subscribe(" libs/ --include="*.ts" | grep -v "take\|pipe\|.spec.ts"

# Check: No BehaviorSubject in components (use signals)
grep -rn "BehaviorSubject" libs/*/feature-* --include="*.ts"

# Check: Signals used for local state
# Check: async pipe or toSignal() for template subscriptions
```

**Violations:**
- Unmanaged `.subscribe()` = HIGH (memory leak)
- BehaviorSubject in component = MEDIUM
- Missing `takeUntilDestroyed()` = HIGH
- Direct subscribe in template = MEDIUM

### 7. Frontend Patterns (12)

```bash
# Check: All components are standalone
grep -rn "standalone: false\|NgModule" libs/ --include="*.component.ts"

# Check: OnPush change detection
grep -rL "ChangeDetectionStrategy.OnPush" libs/ --include="*.component.ts"

# Check: Modern control flow (@if, @for)
grep -rn "\*ngIf\|\*ngFor\|\*ngSwitch" libs/ --include="*.html"

# Check: Signal-based inputs/outputs
grep -rn "@Input()\|@Output()" libs/ --include="*.component.ts"

# Check: inject() function (not constructor injection)
grep -rn "constructor(" libs/ --include="*.component.ts" | grep -v "super\|private readonly"

# Check: Facade pattern (no business logic in components)
# Check: PrimeNG components not directives
grep -rn "pButton\|pInputText\|pDropdown\|pCalendar" libs/ --include="*.html"
```

**Violations:**
- Non-standalone component = CRITICAL
- Missing OnPush = HIGH
- Legacy *ngIf/*ngFor = HIGH
- @Input/@Output decorators = MEDIUM
- Constructor injection = MEDIUM
- Business logic in component = HIGH
- PrimeNG directive instead of component = MEDIUM

### 8. Backend Patterns (13)

```bash
# Check: Controllers delegate to facades (no business logic)
# Check: Guards chain (AuthGuard + RolesGuard)
# Check: exceptionByError() in catch blocks
# Check: ValidationPipe with transform
# Check: Swagger decorators on all endpoints
```

**Violations:**
- Business logic in controller = HIGH
- Missing guard decorator = HIGH
- Raw throw instead of exceptionByError() = MEDIUM
- Missing Swagger documentation = LOW

### 9. Error Handling (14)

```bash
# Check: Typed error hierarchy used
# Check: Error map for HTTP translation
# Check: No generic Error throws in domain
# Check: Frontend error handler for 401/403
```

**Violations:**
- Generic `throw new Error()` in domain = HIGH
- Missing error-to-HTTP mapping = MEDIUM
- Unhandled error types = MEDIUM

### 10. Security (16)

```bash
# Check: No JWT secrets in source code
grep -rn "jwt.*secret\|JWT_SECRET" libs/ --include="*.ts" | grep -v ".env\|process.env"

# Check: @Allowed() on all endpoints (default protected)
# Check: Role guards on protected routes
# Check: Token expiration validation
```

**Violations:**
- Hardcoded secrets = CRITICAL
- Missing @Allowed() = HIGH
- Missing role guard = HIGH

### 11. Module Boundaries (10)

```bash
# Run Nx lint for boundary enforcement
npx nx affected:lint --base=main 2>&1 | grep "boundary"

# Check tags on all project.json
find libs/ -name "project.json" -exec grep -L '"tags"' {} \;
```

**Violations:**
- Missing tags in project.json = HIGH
- Lint boundary violation = CRITICAL

### 12. Import Organization

```bash
# Check: Direct imports preferred over barrels
grep -rn "from '@.*'" libs/ --include="*.ts" | grep -v "/.*/" | grep -v "node_modules"

# Check: Import groups in correct order
# Check: No circular imports
npx madge --circular --extensions ts libs/
```

**Violations:**
- Barrel import when direct available = MEDIUM
- Import order violation = LOW
- Circular import = CRITICAL

## Scoring

Each category scores 0-10. Weights:

| Category | Weight | Max Points |
|----------|--------|------------|
| Clean Architecture Layers | 15% | 15 |
| Module Boundaries | 15% | 15 |
| Type Safety | 12% | 12 |
| Frontend Patterns | 12% | 12 |
| Reactive Patterns | 10% | 10 |
| DDD Compliance | 8% | 8 |
| Ports & Adapters | 8% | 8 |
| Error Handling | 6% | 6 |
| Backend Patterns | 6% | 6 |
| Security | 5% | 5 |
| Import Organization | 3% | 3 |

**Total: 100 points**

| Score | Grade | Action |
|-------|-------|--------|
| 90-100 | A | Exemplary - minor improvements only |
| 75-89 | B | Good - address HIGH issues |
| 60-74 | C | Needs work - address HIGH + MEDIUM |
| 40-59 | D | Significant issues - remediation plan needed |
| 0-39 | F | Critical - stop and fix before new features |

## Output Format

```markdown
# Architecture Health Report

**Project**: [name]
**Date**: [date]
**Score**: [score]/100 (Grade: [A-F])
**Scope**: [what was audited]

## Summary
| Category | Score | Issues |
|----------|-------|--------|
| Clean Architecture | X/10 | N critical, N high |
| Module Boundaries | X/10 | ... |
| ... | ... | ... |

## Critical Issues (must fix)
1. [file:line] - [description] - [remediation]

## High Issues (should fix)
1. [file:line] - [description] - [remediation]

## Medium Issues (fix when possible)
1. [file:line] - [description] - [remediation]

## Recommendations
- [prioritized list of improvements]

## Trend
[comparison with previous audit if available]
```

## Depth Modes

### Quick (< 2 min)
- Lint boundaries only
- Grep for critical violations (any, NgModule, *ngIf)
- Tag verification

### Standard (< 5 min)
- All grep-based checks
- Lint boundaries
- Import analysis
- Component pattern verification

### Deep (< 15 min)
- All standard checks
- Circular dependency analysis (madge)
- Full type safety scan
- Security audit
- Cross-scope dependency analysis
- Design pattern usage assessment
