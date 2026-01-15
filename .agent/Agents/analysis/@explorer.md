# @explorer - Codebase Exploration Agent

> Explores and understands codebase structure, patterns, and implementations.

---

## Capabilities

- Navigate and map codebase structure
- Find patterns and conventions
- Understand data flow and dependencies
- Locate specific implementations
- Answer architecture questions
- Document existing code behavior

---

## Invocation Pattern

```markdown
@explorer
  task: [what to find/understand]
  scope: [where to look]
  depth: quick | medium | thorough
  output: [findings format]
```

---

## Example: Understand Feature Flow

```markdown
@explorer
  task: Understand how login flow works
  scope: libs/auth/
  depth: thorough
  output: Flow diagram and key files
```

---

## Example: Find Patterns

```markdown
@explorer
  task: Find how facades are implemented
  scope: libs/*/data-access/
  depth: medium
  output: Pattern summary with examples
```

---

## Example: Locate Implementation

```markdown
@explorer
  task: Find where user validation happens
  scope: libs/user/
  depth: quick
  output: File paths and line numbers
```

---

## Exploration Strategies

### Quick Search
```
1. Glob for file patterns
2. Grep for keywords
3. Read matching files
4. Report findings
```

### Medium Exploration
```
1. Map folder structure
2. Identify key files
3. Read and understand flow
4. Document dependencies
5. Report findings
```

### Thorough Analysis
```
1. Full structure mapping
2. Read all relevant files
3. Trace execution paths
4. Document all connections
5. Create comprehensive report
```

---

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
4. Report location

### "What pattern is used for X?"
1. Find examples
2. Extract commonalities
3. Document pattern
4. Provide template

### "What depends on X?"
1. Search for imports
2. Check reverse dependencies
3. Map dependency graph
4. Report dependents

---

## Search Patterns

### Find Components
```bash
# By name
**/*user*.component.ts

# By type
libs/*/feature-*/**/*.component.ts
```

### Find Services/Facades
```bash
# Facades
libs/*/data-access/**/facades/*.facade.ts

# Services
libs/**/*.service.ts
```

### Find Patterns
```bash
# Signal usage
grep "signal<"

# Inject usage
grep "= inject("

# Input/Output
grep "= input(" or "= output("
```

---

## Output Formats

### Structure Map
```markdown
## Structure: [scope]

```
libs/user/
├── data-access/
│   └── src/lib/
│       ├── application/
│       │   └── user.facade.ts    ← State management
│       └── infrastructure/
│           └── user.repository.ts ← HTTP calls
├── domain/
│   └── src/lib/
│       ├── dtos/
│       │   └── user.dto.ts       ← Data structure
│       └── interfaces/
│           └── user.interface.ts ← Contracts
└── feature-profile/
    └── src/lib/
        └── user-profile.component.ts ← UI
```
```

### Flow Diagram
```markdown
## Flow: [feature]

```
[Entry Point]
     │
     ▼
[Component] ──inject──▶ [Facade]
     │                      │
     │                      ▼
     │              [Repository]
     │                      │
     │                      ▼
     ▼                 [HTTP Call]
[Template]                  │
     │                      ▼
     ▼              [API Response]
[User Sees]                 │
                           ▼
                    [Signal Update]
                           │
                           ▼
                    [UI Re-render]
```
```

### Pattern Summary
```markdown
## Pattern: [name]

### Description
[What the pattern does]

### When to Use
- [Scenario 1]
- [Scenario 2]

### Structure
```typescript
// Template code
```

### Examples in Codebase
- [file1.ts:line]
- [file2.ts:line]
```

---

## Integration Points

| From | Triggers | Purpose |
|------|----------|---------|
| User query | @explorer | Understand code |
| @coder | @explorer | Find patterns first |
| @debugger | @explorer | Trace execution |
| @arch-validator | @explorer | Map dependencies |
