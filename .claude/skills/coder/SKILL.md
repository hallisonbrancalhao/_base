---
name: coder
description: |
  Code Generation - Writes and refactors code following established patterns and architecture rules.
  TRIGGERS: implement feature, write code, create component, create service, create facade, refactor code, fix code, implement
---

# @coder - Code Generation

Write and refactor code following patterns and architecture rules.

## Required Reading

- `.agent/System/typescript_clean_code.md`
- `.agent/System/angular_full.md`
- `.agent/System/libs_architecture_pattern.md`
- `.agent/System/primeng_best_practices.md`

## Invocation Pattern

```
@coder
  task: [what to implement]
  context: [relevant files, patterns]
  constraints: [architecture rules]
  output: [files to create/modify]
```

## Code Standards

### TypeScript
- Max **5 statements** per function
- Max **3 parameters** per function
- Self-documenting names
- Strict mode enabled

### Angular
- **Standalone** components only
- **Signals** for state
- **@if/@for** control flow
- **input()/output()** functions
- **inject()** function

### Import Order
```typescript
// Angular imports
import { Component, inject } from '@angular/core';

// Third-party imports
import { Observable } from 'rxjs';

// PrimeNG imports
import { ButtonModule } from 'primeng/button';

// Shared imports
import { SharedService } from '@project/shared/utils';

// Local imports
import { LocalComponent } from './local.component';
```

## Dependency Matrix

| From | Can Import |
|------|------------|
| Feature | data-access, ui, util |
| Data-Access | domain, util |
| Domain | util only |
| UI | ui, util |
| Util | util only |

## Path Pattern

```typescript
// Direct imports (PREFERRED)
import { UserDto } from '@project/user/domain/dtos/user.dto';

// NOT via barrel
import { UserDto } from '@project/user/domain';
```

## Checklist Before Completion

- Follows TypeScript clean code rules
- Uses Angular modern patterns
- Respects architecture boundaries
- Uses signals, not BehaviorSubject
- Uses @if/@for, not *ngIf/*ngFor
