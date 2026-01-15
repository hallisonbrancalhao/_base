# @git-operator - Git Operations Agent

> Manages git operations: analyzes changes, creates commits following conventions.

---

## Capabilities

- Analyze staged/unstaged changes
- Determine commit type from changes
- Generate conventional commit messages
- Validate commit message format
- Create branches following naming conventions
- Handle common git workflows

---

## Commit Message Convention

```txt
<type>(optional scope): <short message>

[blank line]

[detailed description if necessary]
```

### Types

| Type | When to Use |
|------|-------------|
| `feat` | New feature or functionality |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code restructure, no behavior change |
| `test` | Adding/modifying tests |
| `chore` | Build, CI, dependencies |
| `perf` | Performance improvement |
| `ci` | CI/CD changes |
| `build` | Build system changes |

---

## Invocation Pattern

```markdown
@git-operator
  task: [git operation]
  context: [what was changed]
  constraints: [branch rules, message format]
  output: [commit hash, branch name]
```

---

## Example: Analyze and Commit

```markdown
@git-operator
  task: Analyze changes and create commit
  context: Recent code changes
  constraints: Follow conventional commits
  output: Commit with proper message
```

**Workflow:**
```bash
# 1. Check current status
git status

# 2. View changes
git diff --staged
git diff

# 3. Analyze recent commit patterns
git log --oneline -10

# 4. Stage relevant files
git add [files]

# 5. Create commit
git commit -m "type(scope): description"
```

---

## Example: Feature Commit

```markdown
@git-operator
  task: Commit new login feature
  context: Added login page with form validation
  constraints: Use feat type, include scope
  output: Commit with proper message
```

**Result:**
```bash
git commit -m "feat(auth): add login page with form validation

- Implement email/password form
- Add validation feedback
- Connect to auth facade"
```

---

## Example: Bug Fix Commit

```markdown
@git-operator
  task: Commit bug fix
  context: Fixed null pointer in user service
  constraints: Reference issue if available
  output: Commit with fix type
```

**Result:**
```bash
git commit -m "fix(user): handle null response in user service

Prevent crash when API returns empty user object"
```

---

## Commit Analysis Process

```
┌─────────────────────────────────────────────────────────┐
│                 Commit Analysis                         │
├─────────────────────────────────────────────────────────┤
│  1. GATHER INFO                                         │
│     ├─ git status (changed files)                       │
│     ├─ git diff --staged (staged changes)               │
│     └─ git log -5 (recent patterns)                     │
│                                                         │
│  2. DETERMINE TYPE                                      │
│     ├─ New files in feature/ → feat                     │
│     ├─ Changes to existing → fix/refactor               │
│     ├─ Only *.spec.ts → test                            │
│     ├─ Only *.md → docs                                 │
│     └─ package.json, config → chore                     │
│                                                         │
│  3. DETERMINE SCOPE                                     │
│     ├─ libs/auth/* → (auth)                             │
│     ├─ libs/user/* → (user)                             │
│     ├─ apps/web/* → (web)                               │
│     └─ Multiple areas → omit scope                      │
│                                                         │
│  4. GENERATE MESSAGE                                    │
│     ├─ Max 120 chars first line                         │
│     ├─ Imperative mood ("add" not "added")              │
│     └─ Body for complex changes                         │
└─────────────────────────────────────────────────────────┘
```

---

## Scope Detection

| Path Pattern | Suggested Scope |
|--------------|-----------------|
| `libs/auth/*` | `(auth)` |
| `libs/user/*` | `(user)` |
| `libs/shared/ui-*` | `(ui)` |
| `libs/*/data-access/*` | `(data-access)` |
| `apps/web/*` | `(web)` |
| `apps/api/*` | `(api)` |
| Multiple libs | Omit scope |

---

## Message Templates

### Feature
```
feat(scope): add [feature description]

- Implement [main functionality]
- Add [supporting feature]
- Connect to [integration point]
```

### Bug Fix
```
fix(scope): resolve [issue description]

[Root cause explanation]
[How it was fixed]
```

### Refactor
```
refactor(scope): restructure [what was changed]

- Move [what] from [where] to [where]
- Extract [what] into [where]
- Simplify [what]
```

### Test
```
test(scope): add tests for [feature]

- Unit tests for [component/service]
- Mock [dependencies]
- Cover [scenarios]
```

---

## Pre-Commit Validation

Before creating commit, verify:

```markdown
- [ ] `nx affected:lint --base=main` passes
- [ ] `nx affected:test --base=main` passes
- [ ] `nx affected:build --base=main` passes
- [ ] No sensitive data in staged files
- [ ] Message follows convention
- [ ] Scope matches changed files
```

---

## Branch Naming

```
<type>/<ticket-or-description>

Examples:
feat/user-profile-page
fix/auth-token-refresh
refactor/shared-utils
```

---

## Common Patterns

### Multiple Related Changes
```bash
# If changes are related, single commit:
git add .
git commit -m "feat(user): add profile page with settings

- Add profile component
- Add settings form
- Connect to user facade"
```

### Unrelated Changes
```bash
# If changes are unrelated, separate commits:
git add libs/auth/
git commit -m "fix(auth): handle expired token"

git add libs/user/
git commit -m "feat(user): add avatar upload"
```

---

## Error Prevention

| Issue | Prevention |
|-------|------------|
| Vague message | Describe WHAT and WHY |
| Wrong type | Check file types changed |
| Missing scope | Check path patterns |
| Too long | Keep under 120 chars |
| Not imperative | Use "add" not "added" |
