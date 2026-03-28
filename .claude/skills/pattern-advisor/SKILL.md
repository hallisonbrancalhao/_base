---
name: pattern-advisor
description: |
  Design Pattern Recommender - Suggests applicable design patterns from the 27 cataloged patterns based on context.
  Provides code skeletons using project conventions and anti-patterns to avoid.
  TRIGGERS: suggest pattern, which pattern, design pattern, pattern advice, recommend pattern, qual padrao, sugerir padrao
---

# @pattern-advisor - Design Pattern Recommender

Recommends applicable design patterns from the architecture knowledge base catalog.

## Required Reading

- `.agent/System/architecture-knowledge/19-DESIGN-PATTERNS-CATALOG.md`
- `.agent/System/architecture-knowledge/01-CLEAN-ARCHITECTURE.md`
- `.agent/System/architecture-knowledge/04-PORTS-AND-ADAPTERS.md`

## Invocation Pattern

```
@pattern-advisor
  problem: [description of what needs to be built/solved]
  context: [relevant files, current architecture]
  constraints: [performance, complexity, team experience]
```

## Pattern Catalog (27 Patterns)

### Creational
| # | Pattern | When to Use |
|---|---------|-------------|
| 1 | Factory Method | Creating providers for DI, abstracting object creation |
| 2 | Abstract Factory | Generic provider helpers (createServiceProvider) |
| 3 | Builder | Fluent configuration (Swagger, query builders) |

### Structural
| # | Pattern | When to Use |
|---|---------|-------------|
| 4 | Facade | Simplifying complex subsystems (state + use cases + API) |
| 5 | Adapter | Translating domain interface to infrastructure |
| 6 | Proxy | HTTP interceptors, lazy loading, caching |
| 7 | Composite | Module composition, nested forms |
| 8 | Decorator | NestJS/Angular decorators, extending behavior |

### Behavioral
| # | Pattern | When to Use |
|---|---------|-------------|
| 9 | Command | Use case pattern (execute()), action dispatch |
| 10 | Strategy | Swappable service implementations |
| 11 | Template Method | Base classes with hooks (MongoService) |
| 12 | Observer | RxJS streams, signals, event-driven UI |
| 13 | Chain of Responsibility | Guard chains (Auth -> Roles -> Permission) |
| 14 | Mediator | Controller coordinating facades/use cases |
| 15 | State | State machine for UI/workflow states |

### Architectural
| # | Pattern | When to Use |
|---|---------|-------------|
| 16 | Hexagonal | Domain isolation, port/adapter separation |
| 17 | Clean Architecture | Layer separation, dependency rule |
| 18 | CQRS Lite | Read/write separation in facades |
| 19 | Repository | Abstract data access, generic CRUD |
| 20 | Module | Nx library boundaries, feature encapsulation |

### UI
| # | Pattern | When to Use |
|---|---------|-------------|
| 21 | Container/Presentational | Smart + dumb component separation |
| 22 | Sheet/Dialog | Modal/overlay workflows |
| 23 | Typed Form | Complex form architecture |

### Infrastructure
| # | Pattern | When to Use |
|---|---------|-------------|
| 24 | Dependency Injection | Decoupling, testability, composition |
| 25 | Barrel Export | Public API control per library |
| 26 | Environment | Typed configuration management |
| 27 | Interceptor | Cross-cutting concerns (auth, logging, loading) |

## Decision Matrix

Given a problem, evaluate these criteria to recommend patterns:

```
1. Is it about creating objects? → Creational (1-3)
2. Is it about composing/adapting structures? → Structural (4-8)
3. Is it about coordinating behavior? → Behavioral (9-15)
4. Is it about system organization? → Architectural (16-20)
5. Is it about UI interaction? → UI (21-23)
6. Is it about cross-cutting concerns? → Infrastructure (24-27)
```

### Common Scenarios

| Scenario | Recommended Patterns |
|----------|---------------------|
| New feature page | 4 (Facade) + 21 (Container/Presentational) + 19 (Repository) |
| New API endpoint | 14 (Mediator) + 9 (Command) + 13 (Chain of Resp) |
| New data source | 5 (Adapter) + 11 (Template Method) + 16 (Hexagonal) |
| Complex form | 23 (Typed Form) + 7 (Composite) + 12 (Observer) |
| Swappable service | 10 (Strategy) + 1 (Factory) + 24 (DI) |
| State management | 4 (Facade) + 15 (State) + 12 (Observer) |
| Auth/permissions | 13 (Chain) + 8 (Decorator) + 27 (Interceptor) |
| Shared component | 21 (Container/Presentational) + 25 (Barrel) + 20 (Module) |

## Output Format

```markdown
## Pattern Recommendation

### Problem Analysis
[Brief analysis of what needs to be built]

### Recommended Patterns

#### Primary: [Pattern Name] (#N)
**Why**: [why this pattern fits]
**How**: [brief implementation guide]
```typescript
// Code skeleton using project conventions
```

#### Supporting: [Pattern Name] (#N)
**Why**: [complementary pattern]
**How**: [brief guide]

### Anti-Patterns to Avoid
- [pattern that seems right but isn't for this case, and why]

### Architecture Knowledge References
- [relevant docs from knowledge base]
```
