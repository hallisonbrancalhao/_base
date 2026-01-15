# Sub-Agent Execution Protocol

> **Primary Agent = Orchestrator Only**
> All tasks MUST be delegated to specialized sub-agents.

---

## Agent Categories

```
.agent/Agents/
├── README.md              ← YOU ARE HERE
├── quality/               ← Code quality & validation
│   ├── @qa-runner.md      ← Tests, build, lint execution
│   ├── @arch-validator.md ← Architecture compliance
│   └── @code-reviewer.md  ← Code review & standards
├── development/           ← Code generation & refactoring
│   ├── @coder.md          ← Write and refactor code
│   ├── @test-writer.md    ← Unit/integration tests
│   └── @docs-writer.md    ← Documentation
├── automation/            ← DevOps & tooling
│   ├── @e2e-tester.md     ← Browser E2E testing
│   ├── @git-operator.md   ← Git operations & commits
│   └── @nx-operator.md    ← Nx workspace operations
└── analysis/              ← Research & exploration
    ├── @explorer.md       ← Codebase exploration
    └── @debugger.md       ← Issue investigation
```

---

## Invocation Pattern

```markdown
@[agent-name]
  task: [clear description of what to do]
  context: [relevant files, paths, or background]
  constraints: [rules, patterns, or limitations]
  output: [expected deliverable]
```

---

## Quick Reference

| Need | Agent | Example |
|------|-------|---------|
| Run all checks | `@qa-runner` | Lint + test + build |
| Test in browser | `@e2e-tester` | Click flows, visual checks |
| Create commit | `@git-operator` | Analyze changes, format message |
| Write code | `@coder` | Implement feature/fix |
| Write tests | `@test-writer` | Unit tests with mocks |
| Review code | `@code-reviewer` | Standards compliance |
| Explore code | `@explorer` | Find patterns, understand flow |
| Debug issue | `@debugger` | Investigate errors |
| Validate arch | `@arch-validator` | Lib boundaries, dependencies |
| Generate lib | `@nx-operator` | Create libs, run generators |

---

## Workflow Examples

### Feature Implementation

```
1. @explorer       → Understand existing patterns
2. @arch-validator → Verify lib structure is correct
3. @coder          → Implement the feature
4. @test-writer    → Write unit tests
5. @qa-runner      → Run lint/test/build
6. @e2e-tester     → Test in browser (if UI)
7. @git-operator   → Create commit
```

### Bug Fix

```
1. @debugger       → Investigate root cause
2. @coder          → Implement fix
3. @test-writer    → Add regression test
4. @qa-runner      → Verify all passes
5. @git-operator   → Create commit
```

### Code Review

```
1. @code-reviewer  → Check standards compliance
2. @arch-validator → Verify architecture rules
3. @qa-runner      → Run full validation
```

---

## Rules

1. **Never skip quality checks** - Always run `@qa-runner` before commit
2. **Test UI changes in browser** - Always use `@e2e-tester` for visual changes
3. **One agent per responsibility** - Don't mix concerns
4. **Document complex changes** - Use `@docs-writer` when needed
5. **Validate architecture** - Check boundaries before adding dependencies

---

**See individual agent files for detailed instructions and capabilities.**


### Invocation Pattern

```markdown
@[agent-name]
  task: [clear description]
  context: [relevant files/paths]
  constraints: [rules to follow]
  output: [expected deliverable]
```

---

### Workflow Examples

#### Feature Implementation
```
1. @explorer       → Understand existing patterns
2. @arch-validator → Verify lib structure
3. @coder          → Implement feature
4. @test-writer    → Write unit tests
5. @qa-runner      → Run lint/test/build
6. @e2e-tester     → Test in browser (if UI)
7. @git-operator   → Create commit
```

#### Bug Fix
```
1. @debugger       → Investigate root cause
2. @coder          → Implement fix
3. @test-writer    → Add regression test
4. @qa-runner      → Verify all passes
5. @git-operator   → Create commit
```

#### Pre-Commit Validation
```
@qa-runner
  task: Validate before commit
  scope: affected
  checks: lint, test, build
  output: Pass/fail report
```

#### E2E Browser Test
```
@e2e-tester
  task: Test login flow
  url: http://localhost:4200/login
  flow: Fill form → Submit → Verify dashboard
  assertions: No errors, correct redirect
  output: Test report with screenshots
```

#### Create Commit
```
@git-operator
  task: Commit implementation
  context: Recent changes
  constraints: Conventional commits format
  output: Commit with proper message
```
