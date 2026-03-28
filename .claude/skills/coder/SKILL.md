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
- `.agent/System/architecture-knowledge/03-USE-CASE-PATTERN.md` (execute() pattern)
- `.agent/System/architecture-knowledge/07-STATE-MANAGEMENT.md` (Facade + signals)
- `.agent/System/architecture-knowledge/19-DESIGN-PATTERNS-CATALOG.md` (pattern selection)
- `.agent/System/architecture-knowledge/04-PORTS-AND-ADAPTERS.md` (port/adapter pairs)

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

## Architecture Patterns (Knowledge Base)

### Use Case Pattern (03)
- One file per use case with `execute()` method
- Typed input/output generics
- No framework coupling in use cases

### Facade Pattern (07)
- Components are dumb/presentational
- All state managed via Facade with signals
- Facade orchestrates repositories and use cases

### Ports & Adapters (04)
- Every service has abstract port + concrete adapter
- Domain never references concrete implementations
- Provider functions connect port → adapter

### Design Patterns (19)
- Use Factory Method for DI providers
- Use Adapter for infrastructure translation
- Use Chain of Responsibility for guard chains

## Checklist Before Completion

- Follows TypeScript clean code rules
- Uses Angular modern patterns
- Respects architecture boundaries
- Uses signals, not BehaviorSubject
- Uses @if/@for, not *ngIf/*ngFor
- Facade pattern for state management
- Direct imports, not barrel imports
- No `: any` types
- OnPush change detection on components
