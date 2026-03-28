---
name: import-fixer
description: |
  Import Organization Enforcer - Detects and auto-fixes import order violations and barrel imports.
  Enforces Angular > third-party > PrimeNG > shared > local grouping and direct imports over barrels.
  TRIGGERS: fix imports, import order, organize imports, barrel imports, import groups, corrigir imports
---

# @import-fixer - Import Organization Enforcer

Detects and auto-fixes import organization violations.

## Required Reading

- `.agent/System/base_rules.md` (import order rules)
- `.agent/System/barrel_best_practices.md`
- `.agent/System/architecture-knowledge/10-MODULE-BOUNDARIES.md`

## Invocation Pattern

```
@import-fixer
  scope: [files | project | affected | all]
  mode: report | fix
  checks: order | barrel | circular | all
```

## Import Order Rules

Imports MUST be grouped in this order, with blank lines between groups:

```typescript
// 1. Angular imports
import { Component, inject, signal } from '@angular/core';
import { RouterModule } from '@angular/router';
import { HttpClient } from '@angular/common/http';

// 2. Third-party libraries
import { Observable } from 'rxjs';
import { map, filter } from 'rxjs/operators';

// 3. PrimeNG imports
import { ButtonModule } from 'primeng/button';
import { TableModule } from 'primeng/table';

// 4. Shared/project imports (cross-scope)
import { SharedService } from '@project/shared/utils';
import { UserDto } from '@project/user/domain/dtos/user.dto';

// 5. Local imports (same scope/lib)
import { LocalComponent } from './local.component';
import { LocalService } from '../services/local.service';
```

## Checks

### 1. Import Order Violations

**Detect:** Imports not in correct group order.

```bash
# Find files with potentially misordered imports
# Check if Angular imports appear after third-party imports, etc.
```

**Indicators of violation:**
- `@angular/*` import appearing after `rxjs` or `primeng`
- `primeng/*` import appearing after `@project/*`
- `./` or `../` import appearing before any `@` import
- Mixed groups without blank line separators

### 2. Barrel Import Violations

**Detect:** Using barrel (index.ts) imports when direct imports are available.

```typescript
// VIOLATION
import { UserDto, CreateUserDto } from '@project/user/domain';

// CORRECT
import { UserDto } from '@project/user/domain/dtos/user.dto';
import { CreateUserDto } from '@project/user/domain/dtos/create-user.dto';
```

**Detection:**
```bash
# Find imports from barrel paths (no sub-path after lib name)
grep -rn "from '@[^']*'" libs/ --include="*.ts" | grep -v "from '@angular\|from 'rxjs\|from 'primeng\|/.*/" | grep -v ".spec.ts"
```

### 3. Circular Import Detection

```bash
# Use madge for circular dependency detection
npx madge --circular --extensions ts libs/[scope]/
```

### 4. Unused Import Detection

```bash
# TypeScript compiler will flag unused imports with strict mode
npx tsc --noEmit --pretty 2>&1 | grep "is declared but"
```

## Auto-Fix Algorithm (mode: fix)

### Import Reordering

1. Parse all import statements from file
2. Classify each import into group (1-5)
3. Sort imports within each group alphabetically by source
4. Reconstruct import block with blank line separators
5. Replace original import block

### Barrel to Direct

1. Find barrel imports (imports from path without sub-directory)
2. For each imported symbol, trace to source file via:
   - Read the barrel's `index.ts`
   - Find the `export { Symbol } from './path'` line
   - Construct direct import path
3. Replace barrel import with direct imports
4. Verify tsconfig.base.json has wildcard path alias

## Output Format

### Report Mode
```markdown
## Import Organization Report

**Scope**: [scope]
**Files Scanned**: [count]
**Violations Found**: [count]

### Order Violations
| File | Line | Issue |
|------|------|-------|
| path/file.ts | 5 | Angular import after PrimeNG |

### Barrel Violations
| File | Line | Current | Suggested |
|------|------|---------|-----------|
| path/file.ts | 3 | @project/user/domain | @project/user/domain/dtos/user.dto |

### Circular Dependencies
| Cycle |
|-------|
| A -> B -> C -> A |
```

### Fix Mode
```markdown
## Import Fixes Applied

**Files Modified**: [count]
**Order Fixes**: [count]
**Barrel-to-Direct Fixes**: [count]

### Changes
| File | Fix Type | Details |
|------|----------|---------|
| path/file.ts | order | Moved Angular imports to top |
| path/file.ts | barrel | Converted 3 barrel imports to direct |
```
