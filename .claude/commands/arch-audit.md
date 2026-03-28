# /arch-audit - Full Architecture Audit

Run a comprehensive architecture health check using the arch-doctor skill.

## Usage

```
/arch-audit [scope] [--depth=quick|standard|deep] [--focus=category]
```

- `scope`: `affected` (default) | `all` | `[project-name]` | `[scope-name]`
- `--depth`: `quick` | `standard` (default) | `deep`
- `--focus`: `all` (default) | `layers` | `ddd` | `types` | `reactive` | `frontend` | `backend` | `security` | `imports`

## Examples

```
/arch-audit                          # Affected projects, standard depth
/arch-audit all --depth=deep         # Full codebase, deep analysis
/arch-audit admin --focus=frontend   # Admin scope, frontend checks only
/arch-audit --focus=types            # Affected projects, type safety only
```

## Steps

### 1. Determine Scope

Parse $ARGUMENTS for scope, depth, and focus options. Default: `affected`, `standard`, `all`.

### 2. Load Architecture Knowledge

Read the architecture knowledge base documents relevant to the focus area:

```
@arch-doctor
  scope: [parsed scope]
  depth: [parsed depth]
  focus: [parsed focus]
```

### 3. Execute Audit

Run checks based on depth and focus. For each category:

1. Run automated grep/lint checks
2. Analyze results against knowledge base rules
3. Score each category (0-10)
4. Classify findings by severity (CRITICAL, HIGH, MEDIUM, LOW)

### 4. Generate Report

Output the Architecture Health Report with:
- Overall score and grade
- Category breakdown
- Issues by severity with file:line references
- Prioritized remediation recommendations

### 5. Save Report (if deep)

For deep audits, save report to `.agent/Reports/arch-audit-[date].md`.

## Quick Reference: What Each Depth Checks

| Check | Quick | Standard | Deep |
|-------|:-----:|:--------:|:----:|
| Nx lint boundaries | x | x | x |
| Critical pattern grep | x | x | x |
| Tag verification | x | x | x |
| Import analysis | | x | x |
| Component patterns | | x | x |
| Type safety scan | | x | x |
| Reactive patterns | | x | x |
| Circular deps (madge) | | | x |
| Security audit | | | x |
| DDD cross-scope | | | x |
| Design pattern usage | | | x |
