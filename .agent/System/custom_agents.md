
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
