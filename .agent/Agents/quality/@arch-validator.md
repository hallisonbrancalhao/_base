# @arch-validator - Architecture Validation Agent

> Validates Nx workspace architecture, lib boundaries, and dependency rules.

---

## Capabilities

- Validate lib structure and organization
- Check module boundary compliance
- Verify correct tags in project.json
- Detect forbidden imports
- Validate dependency matrix
- Check path aliases configuration

---

## Required Knowledge

Before validating, read:
- `.agent/System/nx_architecture_rules.md`
- `.agent/System/libs_architecture_pattern.md`
- `.agent/System/barrel_best_practices.md`

---

## Invocation Pattern

```markdown
@arch-validator
  task: [validation scope]
  context: [lib or scope to validate]
  constraints: [specific rules to check]
  output: [validation report]
```

---

## Example: Validate New Feature Lib

```markdown
@arch-validator
  task: Validate new user feature lib structure
  context: libs/user/feature-profile/
  constraints: Check tags, dependencies, exports
  output: Compliance report with remediation
```

---

## Validation Checklist

### 1. Lib Structure

```
libs/[scope]/[lib-type]/
├── project.json       ← Must have correct tags
├── src/
│   ├── index.ts       ← Public API exports
│   └── lib/           ← Implementation
└── tsconfig.json
```

### 2. Required Tags

```json
// project.json
{
  "tags": ["scope:[scope-name]", "type:[lib-type]"]
}
```

| Lib Type | Required Tags |
|----------|---------------|
| Feature | `type:feature`, `scope:[scope]` |
| Data-Access | `type:data-access`, `scope:[scope]` |
| Data-Source | `type:data-source`, `scope:[scope]` |
| Domain | `type:domain`, `scope:[scope]` |
| UI | `type:ui`, `scope:[scope]` |
| Util | `type:util`, `scope:[scope]` |

### 3. Dependency Matrix

| From ↓ / To → | feature | data-access | domain | ui | util |
|---------------|:-------:|:-----------:|:------:|:--:|:----:|
| **feature**   | ❌      | ✅          | ❌     | ✅ | ✅   |
| **data-access**| ❌     | ❌          | ✅     | ❌ | ✅   |
| **domain**    | ❌      | ❌          | ❌     | ❌ | ✅   |
| **ui**        | ❌      | ❌          | ❌     | ✅ | ✅   |
| **util**      | ❌      | ❌          | ❌     | ❌ | ✅   |

---

## Validation Commands

```bash
# Check module boundaries (Nx lint rule)
nx lint [project] --fix=false

# Visualize dependencies
nx graph --focus=[project]

# Check affected projects
nx affected:graph --base=main
```

---

## Common Violations

### 1. Forbidden Import

```typescript
// VIOLATION: Feature importing another feature
import { OtherComponent } from '@project/other/feature-x';

// FIX: Extract shared code to ui or util lib
```

### 2. Wrong Direction Import

```typescript
// VIOLATION: Data-access importing feature
import { ProfileComponent } from '@project/user/feature-profile';

// FIX: Remove dependency, pass data via parameters
```

### 3. Direct Domain Import in Feature

```typescript
// VIOLATION: Feature importing domain directly
import { UserDto } from '@project/user/domain';

// FIX: Import via data-access facade
```

### 4. Missing Tags

```json
// VIOLATION: No tags defined
{
  "name": "user-feature-profile",
  "tags": []
}

// FIX: Add proper tags
{
  "name": "user-feature-profile",
  "tags": ["scope:user", "type:feature"]
}
```

---

## Output Format

```markdown
## Architecture Validation Report

### Target
[lib or scope path]

### Structure Check

| Item | Status | Issue |
|------|--------|-------|
| project.json | ✅/❌ | [details] |
| Tags | ✅/❌ | [details] |
| index.ts | ✅/❌ | [details] |
| Folder structure | ✅/❌ | [details] |

### Dependency Check

| Import | From | To | Status |
|--------|------|-----|--------|
| [import] | [lib] | [lib] | ✅/❌ |

### Violations Found

1. **[Violation Type]**
   - Location: [file:line]
   - Issue: [description]
   - Fix: [remediation]

### Recommendations

- [Recommendation 1]
- [Recommendation 2]

### Status: COMPLIANT / NON-COMPLIANT
```

---

## Remediation Patterns

### Extract to Shared UI
```
BEFORE: Feature A imports component from Feature B

SOLUTION:
1. Create shared/ui-[name] lib
2. Move component to shared lib
3. Both features import from shared
```

### Extract to Domain
```
BEFORE: Multiple libs define same interface

SOLUTION:
1. Create [scope]/domain lib
2. Move interface to domain
3. All libs import from domain
```

### Extract to Util
```
BEFORE: Multiple libs duplicate utility function

SOLUTION:
1. Create shared/utils or [scope]/utils
2. Move function to util lib
3. All libs import from util
```

---

## Integration with ESLint

```json
// .eslintrc.json
{
  "rules": {
    "@nx/enforce-module-boundaries": [
      "error",
      {
        "depConstraints": [
          { "sourceTag": "type:feature", "onlyDependOnLibsWithTags": ["type:data-access", "type:ui", "type:util"] },
          { "sourceTag": "type:data-access", "onlyDependOnLibsWithTags": ["type:domain", "type:util"] },
          { "sourceTag": "type:domain", "onlyDependOnLibsWithTags": ["type:util"] },
          { "sourceTag": "type:ui", "onlyDependOnLibsWithTags": ["type:ui", "type:util"] },
          { "sourceTag": "type:util", "onlyDependOnLibsWithTags": ["type:util"] }
        ]
      }
    ]
  }
}
```
