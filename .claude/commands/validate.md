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

### 4. AI-Guard (Performance + Segurança + Arquitetura)

> Recomendado antes de release e após merges grandes gerados por IA.
> Executa 3 agents em paralelo via `/audit-report`.

```
/audit-report $ARGUMENTS
```

Ou manualmente via Task tool, em **paralelo** (1 mensagem com 3 Task calls):

```
@performance-auditor  detectors: all  scope: $ARGUMENTS
@security-auditor     checks: all     scope: $ARGUMENTS
@architecture-reviewer pillars: all   scope: $ARGUMENTS
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

### AI-Guard (Performance / Segurança / Arquitetura)
- Performance findings: critical=X, high=X
- Security findings: critical=X, high=X
- Architecture gaps: critical=X, high=X
- Relatório completo: `.agent/Tasks/audit-reports/YYYY-MM-DD-audit-report.md`

### Overall: PASS/FAIL
```
