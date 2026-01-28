# Conventional Commit Generator

Analyze staged changes and create a conventional commit.

## Workflow

1. **Check staged changes**
   ```bash
   git status
   git diff --cached --stat
   ```

2. **Analyze changes** to determine:
   - What files were modified
   - What type of change (feat, fix, refactor, etc.)
   - What scope is affected

3. **Determine commit type**:
   | Type | When to Use |
   |------|-------------|
   | `feat` | New feature or functionality |
   | `fix` | Bug fix |
   | `docs` | Documentation only changes |
   | `refactor` | Code restructure without behavior change |
   | `test` | Adding or updating tests |
   | `chore` | Maintenance, dependencies, config |
   | `style` | Formatting, whitespace (no code change) |
   | `perf` | Performance improvement |

4. **Determine scope** from affected files:
   - `libs/user/*` → scope: `user`
   - `libs/shared/ui/*` → scope: `shared-ui`
   - `apps/web/*` → scope: `web`
   - Multiple scopes → use most significant or omit

5. **Run pre-commit validations**:
   ```bash
   pnpm nx affected:lint --base=HEAD~1
   pnpm nx affected:test --base=HEAD~1
   pnpm nx affected:build --base=HEAD~1
   ```

6. **Create commit** only if validations pass:
   ```bash
   git commit -m "type(scope): description

   [body explaining WHY if needed]

   Co-Authored-By: Claude <noreply@anthropic.com>"
   ```

## Commit Message Rules

- **First line**: Max 72 characters
- **Format**: `type(scope): description`
- **Description**: Imperative mood ("add" not "added")
- **Body**: Explain WHY, not WHAT (code shows what)
- **Footer**: Co-author attribution

## Examples

### Feature
```
feat(user): add password reset functionality

Implement password reset flow with email verification.
Reset links expire after 24 hours for security.

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Bug Fix
```
fix(auth): prevent race condition in token refresh

Multiple simultaneous requests could trigger parallel
refresh attempts. Added mutex lock to serialize refreshes.

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Refactor
```
refactor(payment): extract validation to dedicated service

Move validation logic from PaymentFacade to PaymentValidator
to improve testability and single responsibility.

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Simple Changes
```
docs(readme): update installation instructions

Co-Authored-By: Claude <noreply@anthropic.com>
```

```
chore(deps): update Angular to v21.1.0

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Error Handling

If validations fail:
1. Report which check failed (lint, test, or build)
2. Show the error output
3. Do NOT create the commit
4. Suggest fixes if possible
