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

## Common Violations

1. **Feature importing Feature** → Extract to shared UI
2. **Data-access importing Feature** → Remove, pass via params
3. **Missing tags** → Add `type:` and `scope:` tags

## Output: COMPLIANT / NON-COMPLIANT with remediation
