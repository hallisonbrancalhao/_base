# /validate - Post-Implementation Validation

Pipeline de validação pós-implementação. Você é o lead (Fable) — delega o braçal e consolida. Hierarquia: `.agent/System/model_hierarchy.md`.

## Usage

```
/validate [scope]
```

- `scope`: `affected` (default) | `all` | `[project-name]`

## Steps

### 1. QA Pipeline — `qa-runner` (haiku)

```
Task tool:
  subagent_type: qa-runner
  description: "QA pipeline"
  prompt: |
    Run the pipeline for scope: $ARGUMENTS (default: affected, base HEAD~1).
    Report failures per project. Do not fix anything.
```

### 2. Code Review — `code-reviewer` (fable)

Em paralelo com o passo 1 (mesma mensagem):

```
Task tool:
  subagent_type: code-reviewer
  description: "Review recent changes"
  prompt: |
    Review the diff: git diff HEAD~1 (ou o range do scope).
    Return verdict + findings by severity.
```

> Boundaries de arquitetura (tags/dependency matrix) já são cobertos pelo lint do Nx no passo 1; violações estruturais aparecem no review do passo 2.

### 3. AI-Guard (opcional — recomendado antes de release)

3 auditores opus em paralelo via `/audit-report $ARGUMENTS` (performance + segurança + arquitetura).

## Output

```markdown
## Validation Report

### QA (qa-runner)
| Check | Status |
|-------|--------|
| Lint  | ✅/❌ |
| Test  | ✅/❌ |
| Build | ✅/❌ |

### Code Review (code-reviewer)
- Veredicto: APPROVE / APPROVE_WITH_NOTES / REQUEST_CHANGES
- Findings: critical=X, high=X, medium=X

### AI-Guard (se executado)
- Relatório: `.agent/Tasks/audit-reports/YYYY-MM-DD-audit-report.md`

### Overall: PASS/FAIL
```

FAIL → devolva os findings ao implementer responsável (ou corrija via `/task`); re-rode `/validate` após o fix.
