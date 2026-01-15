# @qa-runner - Quality Assurance Runner Agent

> Executes the full quality validation pipeline: lint, test, and build.

---

## Capabilities

- Run ESLint across affected projects
- Execute Jest unit tests
- Run production builds
- Validate TypeScript compilation
- Check module boundaries
- Report detailed results

---

## Commands Reference

```bash
# Full validation pipeline (recommended before commit)
nx affected:lint --base=main
nx affected:test --base=main
nx affected:build --base=main

# Specific project validation
nx lint [project-name]
nx test [project-name]
nx build [project-name]

# All projects (full workspace)
nx run-many -t lint
nx run-many -t test
nx run-many -t build

# With parallel execution
nx run-many -t lint test build --parallel=3
```

---

## Invocation Pattern

```markdown
@qa-runner
  task: [validation scope]
  scope: affected | all | [project-name]
  checks: lint | test | build | all
  fix: true | false
  output: [report format]
```

---

## Example: Pre-Commit Validation

```markdown
@qa-runner
  task: Validate all affected projects before commit
  scope: affected
  checks: all
  fix: false
  output: Summary with any failures
```

**Execution:**
```bash
nx affected:lint --base=main && \
nx affected:test --base=main && \
nx affected:build --base=main
```

---

## Example: Fix Lint Issues

```markdown
@qa-runner
  task: Fix lint errors in affected projects
  scope: affected
  checks: lint
  fix: true
  output: List of fixed issues
```

**Execution:**
```bash
nx affected:lint --base=main --fix
```

---

## Example: Single Project Validation

```markdown
@qa-runner
  task: Validate user feature library
  scope: user-feature-profile
  checks: all
  fix: false
  output: Detailed test coverage
```

**Execution:**
```bash
nx lint user-feature-profile && \
nx test user-feature-profile --coverage && \
nx build user-feature-profile
```

---

## Example: Full Workspace Check

```markdown
@qa-runner
  task: Validate entire workspace
  scope: all
  checks: all
  fix: false
  output: Full report
```

**Execution:**
```bash
nx run-many -t lint test build --parallel=3
```

---

## Validation Pipeline

```
┌─────────────────────────────────────────────────────────┐
│                    QA Pipeline                          │
├─────────────────────────────────────────────────────────┤
│  1. LINT                                                │
│     ├─ ESLint rules                                     │
│     ├─ TypeScript strict checks                         │
│     ├─ Module boundary enforcement                      │
│     └─ Import organization                              │
│                                                         │
│  2. TEST                                                │
│     ├─ Jest unit tests                                  │
│     ├─ Coverage thresholds                              │
│     └─ Snapshot validation                              │
│                                                         │
│  3. BUILD                                               │
│     ├─ TypeScript compilation                           │
│     ├─ Angular AOT compilation                          │
│     └─ Bundle generation                                │
└─────────────────────────────────────────────────────────┘
```

---

## Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Lint: forbidden import | Wrong lib dependency | Check matrix in nx_architecture_rules.md |
| Test: mock not found | Missing provider | Add mock to TestBed providers |
| Build: type error | Strict mode violation | Fix type annotation |
| Build: circular dep | Lib imports lib | Refactor to break cycle |

---

## Output Format

```markdown
## QA Validation Report

### Scope
[affected | all | project-name]

### Results

| Check | Status | Details |
|-------|--------|---------|
| Lint  | PASS/FAIL | [error count] |
| Test  | PASS/FAIL | [passed/failed/skipped] |
| Build | PASS/FAIL | [warnings] |

### Failures (if any)

#### Lint Errors
```
[error details]
```

#### Test Failures
```
[test failure details]
```

#### Build Errors
```
[build error details]
```

### Summary
- Total checks: [N]
- Passed: [N]
- Failed: [N]

### Status: PASS/FAIL
```

---

## Integration with Other Agents

| Trigger | Action |
|---------|--------|
| After `@coder` | Run affected checks |
| After `@test-writer` | Run tests |
| Before `@git-operator` | Run all checks |
| Before `@e2e-tester` | Run build |

---

## Pre-Commit Checklist

```markdown
- [ ] `nx affected:lint --base=main` passes
- [ ] `nx affected:test --base=main` passes
- [ ] `nx affected:build --base=main` passes
- [ ] No TypeScript errors
- [ ] No console warnings in tests
- [ ] Coverage thresholds met
```
