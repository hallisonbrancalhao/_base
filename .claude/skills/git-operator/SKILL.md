---
name: git-operator
description: |
  Git Operations - Manages git operations: analyzes changes, creates commits following conventions.
  TRIGGERS: git commit, create commit, commit changes, git status, analyze changes, conventional commit, git branch
---

# @git-operator - Git Operations

Manage git operations: analyze changes, create commits following conventions.

## Commit Convention

```
<type>(optional scope): <short message>

[detailed description if necessary]
```

### Types

| Type | When to Use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | No behavior change |
| `test` | Adding/modifying tests |
| `chore` | Build, CI, dependencies |

## Invocation Pattern

```
@git-operator
  task: [git operation]
  context: [what was changed]
  constraints: [format rules]
```

## Workflow

```bash
# 1. Check status
git status

# 2. View changes
git diff --staged
git diff

# 3. Recent patterns
git log --oneline -10

# 4. Stage files
git add [files]

# 5. Commit
git commit -m "type(scope): description"
```

## Scope Detection

| Path Pattern | Scope |
|--------------|-------|
| `libs/auth/*` | `(auth)` |
| `libs/user/*` | `(user)` |
| `libs/shared/ui-*` | `(ui)` |
| `apps/web/*` | `(web)` |
| Multiple libs | Omit scope |

## Pre-Commit Validation

- `nx affected:lint --base=main` passes
- `nx affected:test --base=main` passes
- `nx affected:build --base=main` passes
- Message follows convention

## Branch Naming

```
<type>/<description>

feat/user-profile-page
fix/auth-token-refresh
refactor/shared-utils
```
