---
name: explorer
description: |
  Codebase Exploration - Explores and understands codebase structure, patterns, and implementations.
  TRIGGERS: explore code, find pattern, understand flow, how does it work, where is implemented, find implementation, codebase structure
---

# @explorer - Codebase Exploration

Explore and understand codebase structure, patterns, and implementations.

## Invocation Pattern

```
@explorer
  task: [what to find/understand]
  scope: [where to look]
  depth: quick | medium | thorough
```

## Exploration Strategies

### Quick Search
1. Glob for file patterns
2. Grep for keywords
3. Read matching files
4. Report findings

### Medium Exploration
1. Map folder structure
2. Identify key files
3. Read and understand flow
4. Document dependencies

### Thorough Analysis
1. Full structure mapping
2. Read all relevant files
3. Trace execution paths
4. Create comprehensive report

## Common Questions

### "How does X work?"
1. Find entry point
2. Trace data flow
3. Identify transformations
4. Document the path

### "Where is X implemented?"
1. Search by name
2. Check likely locations
3. Verify implementation

### "What pattern is used for X?"
1. Find examples
2. Extract commonalities
3. Provide template

## Search Patterns

```bash
# Components
**/*user*.component.ts
libs/*/feature-*/**/*.component.ts

# Facades
libs/*/data-access/**/facades/*.facade.ts

# Signal usage
grep "signal<"

# Inject usage
grep "= inject("
```

## Output Formats

### Structure Map
```
libs/user/
├── data-access/
│   └── user.facade.ts    ← State management
├── domain/
│   └── user.dto.ts       ← Data structure
└── feature-profile/
    └── profile.component.ts ← UI
```

### Flow Diagram
```
[Component] ──inject──▶ [Facade]
                           │
                           ▼
                      [Repository]
                           │
                           ▼
                      [HTTP Call]
```
