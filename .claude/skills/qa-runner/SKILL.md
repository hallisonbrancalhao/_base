---
name: qa-runner
description: |
  Quality Assurance Runner - Executes lint, test, and build validation pipeline.
  TRIGGERS: run tests, run lint, run build, validate code, qa check, pre-commit validation, affected projects, nx affected, check quality
---

# @qa-runner - Quality Assurance Runner

Execute full quality validation pipeline: lint, test, and build.

## Commands

```bash
# Affected projects (recommended before commit)
nx affected:lint --base=main
nx affected:test --base=main
nx affected:build --base=main

# Specific project
nx lint [project-name]
nx test [project-name]
nx build [project-name]

# All projects
nx run-many -t lint test build --parallel=3

# Fix lint issues
nx affected:lint --base=main --fix
```

## Invocation Pattern

```
@qa-runner
  task: [validation scope]
  scope: affected | all | [project-name]
  checks: lint | test | build | all
  fix: true | false
```

## Pipeline

1. **LINT** - ESLint rules, TypeScript strict checks, module boundaries
2. **TEST** - Jest unit tests, coverage thresholds, snapshots
3. **BUILD** - TypeScript compilation, Angular AOT, bundle generation

## Output Format

```markdown
## QA Validation Report

### Results
| Check | Status | Details |
|-------|--------|---------|
| Lint  | PASS/FAIL | [errors] |
| Test  | PASS/FAIL | [passed/failed] |
| Build | PASS/FAIL | [warnings] |

### Status: PASS/FAIL
```

## Pre-Commit Checklist

- `nx affected:lint --base=main` passes
- `nx affected:test --base=main` passes
- `nx affected:build --base=main` passes
