---
name: arch-validator
description: |
  Architecture Validation - Validates Nx workspace architecture, lib boundaries, and dependency rules.
  TRIGGERS: validate architecture, check dependencies, module boundaries, lib structure, verify tags, architecture compliance, dependency matrix
---

# @arch-validator - Architecture Validation

Validate Nx workspace architecture, lib boundaries, and dependency rules.

## Required Reading

Before validating, consult:
- `.agent/System/nx_architecture_rules.md`
- `.agent/System/libs_architecture_pattern.md`
- `.agent/System/architecture-knowledge/01-CLEAN-ARCHITECTURE.md` (layer dependency rule)
- `.agent/System/architecture-knowledge/10-MODULE-BOUNDARIES.md` (tagging system, ESLint enforcement)
- `.agent/System/architecture-knowledge/11-MONOREPO-ARCHITECTURE.md` (vertical slices, affected commands)
- `.agent/System/architecture-knowledge/04-PORTS-AND-ADAPTERS.md` (port/adapter verification)

## Invocation Pattern

```
@arch-validator
  task: [validation scope]
  context: [lib or scope to validate]
  constraints: [specific rules]
```

## Validation Checklist

### Required Tags

| Lib Type | Tags |
|----------|------|
| Feature | `type:feature`, `scope:[scope]` |
| Data-Access | `type:data-access`, `scope:[scope]` |
| Domain | `type:domain`, `scope:[scope]` |
| UI | `type:ui`, `scope:[scope]` |
| Util | `type:util`, `scope:[scope]` |

### Dependency Matrix

| From ↓ / To → | feature | data-access | domain | ui | util |
|---------------|:-------:|:-----------:|:------:|:--:|:----:|
| **feature**   | ❌      | ✅          | ❌     | ✅ | ✅   |
| **data-access**| ❌     | ❌          | ✅     | ❌ | ✅   |
| **domain**    | ❌      | ❌          | ❌     | ❌ | ✅   |
| **ui**        | ❌      | ❌          | ❌     | ✅ | ✅   |
| **util**      | ❌      | ❌          | ❌     | ❌ | ✅   |

## Commands

```bash
nx lint [project] --fix=false   # Check boundaries
nx graph --focus=[project]       # Visualize dependencies
nx affected:graph --base=main    # Affected graph
```

## Deep Checks (from Architecture Knowledge Base)

### Clean Architecture (01)
- Domain libs must NOT import Angular, NestJS, or HTTP
- Each layer only imports from inner layers
- Dependency inversion: outer depends on abstractions from inner

### Ports & Adapters (04)
- Every concrete service must have an abstract port
- Domain references ports, never concrete adapters
- Provider functions must exist connecting port → adapter

### Module Boundaries (10)
- All libs must have `scope:` and `type:` tags in project.json
- ESLint @nx/enforce-module-boundaries must pass
- Cross-scope domain imports are prohibited (use Reference Pattern)

## Common Violations

1. **Feature importing Feature** → Extract to shared UI
2. **Data-access importing Feature** → Remove, pass via params
3. **Missing tags** → Add `type:` and `scope:` tags
4. **Domain importing infrastructure** → Invert dependency via port
5. **Cross-scope domain import** → Use Reference Pattern (UserRef)
6. **Concrete service without abstract port** → Create abstract class

## Output: COMPLIANT / NON-COMPLIANT with remediation
