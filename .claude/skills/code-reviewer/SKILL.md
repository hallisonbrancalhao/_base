---
name: code-reviewer
description: |
  Code Review - Reviews code for standards compliance, patterns, and best practices.
  TRIGGERS: review code, code review, check standards, review PR, review changes, check patterns, standards compliance
---

# @code-reviewer - Code Review

Review code for standards compliance, patterns, and best practices.

## Required Reading

- `.agent/System/typescript_clean_code.md`
- `.agent/System/angular_full.md`
- `.agent/System/primeng_best_practices.md`
- `.agent/System/libs_architecture_pattern.md`
- `.agent/System/architecture-knowledge/09-TYPE-SAFETY-PATTERNS.md` (type safety audit)
- `.agent/System/architecture-knowledge/08-REACTIVE-PROGRAMMING.md` (memory leak detection)
- `.agent/System/architecture-knowledge/14-ERROR-HANDLING.md` (error hierarchy)
- `.agent/System/architecture-knowledge/12-FRONTEND-PATTERNS.md` (modern Angular)

## Invocation Pattern

```
@code-reviewer
  task: [review scope]
  context: [files to review]
  focus: [specific concerns]
```

## Review Checklist

### TypeScript Standards
- Functions max 5 statements, max 3 parameters
- Self-documenting names, no obvious comments
- Strict mode satisfied

### Angular Standards
- Standalone components (no NgModules)
- Signals for state (no BehaviorSubject)
- `@if/@for` control flow (no `*ngIf/*ngFor`)
- `input()/output()` functions (no decorators)
- `inject()` function (no constructor injection)
- Components are presentational

### Import Order
1. Angular imports
2. Third-party libs
3. PrimeNG
4. Shared/project imports
5. Local imports

## Severity Levels

| Level | Action |
|-------|--------|
| CRITICAL | Must fix before merge |
| HIGH | Should fix before merge |
| MEDIUM | Fix when possible |
| LOW | Optional |

## Must Have
- Standalone components, Signals, @if/@for, inject(), Facade pattern

## Must NOT Have
- NgModules, BehaviorSubject, *ngIf/*ngFor, @Input/@Output decorators, constructor injection

## Deep Review Checks (Architecture Knowledge Base)

### Type Safety (09)
- No `: any` or `as any` in production code
- Generic constraints on base classes
- Typed forms (TypedForm<T>)

### Reactive Patterns (08)
- No `.subscribe()` without `takeUntilDestroyed()`
- Signals for local state, RxJS for async flows
- `async` pipe or `toSignal()` for template subscriptions

### Error Handling (14)
- Typed error hierarchy (not generic `throw new Error()`)
- Error-to-HTTP mapping via `exceptionByError()`
- Frontend 401/403 handler

### Performance
- OnPush change detection on all components
- `track` expression in `@for` loops
- Lazy loading boundaries on feature routes

## Verdict: APPROVE / REQUEST CHANGES
