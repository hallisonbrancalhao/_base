# /validate - Post-Implementation Validation

Run full validation pipeline after implementation.

## Usage

```
/validate [scope]
```

- `scope`: `affected` (default) | `all` | `[project-name]`

## Steps

Execute in order:

### 1. Run QA Pipeline

```
@qa-runner
  task: Validate implementation
  scope: $ARGUMENTS or affected
  checks: all
  fix: false
```

### 2. Code Review

```
@code-reviewer
  task: Review recent changes
  context: Changed files from git diff
  focus: All standards
```

### 3. Architecture Validation (if libs changed)

```
@arch-validator
  task: Validate architecture compliance
  context: Changed libs
```

## Commands to Execute

```bash
# Get changed files
git diff --name-only HEAD~1

# Run lint
npx nx affected:lint --base=HEAD~1

# Run tests
npx nx affected:test --base=HEAD~1

# Run build
npx nx affected:build --base=HEAD~1
```

## Output

Provide a summary report:

```markdown
## Validation Report

### QA Results
| Check | Status |
|-------|--------|
| Lint  | ✅/❌ |
| Test  | ✅/❌ |
| Build | ✅/❌ |

### Code Review
- Issues found: [count]
- Severity: [summary]

### Architecture
- Compliance: ✅/❌

### Overall: PASS/FAIL
```
