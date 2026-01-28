# Pull Request Workflow

Create and manage pull requests.

## Arguments

`$ARGUMENTS` - PR title, PR number for review, or "review" keyword

## Modes

### Mode 1: Create PR (default)

When `$ARGUMENTS` is a title or description.

### Mode 2: Review PR

When `$ARGUMENTS` contains a PR number or "review".

---

## Create PR Workflow

### Step 1: Verify Branch State

```bash
# Check current branch
git branch --show-current

# Ensure not on main
BRANCH=$(git branch --show-current)
if [ "$BRANCH" = "main" ]; then
  echo "Error: Cannot create PR from main branch"
  exit 1
fi

# Check commits ahead of main
git log main..HEAD --oneline
```

### Step 2: Run Validations

```bash
# All must pass
pnpm nx affected:lint --base=main
pnpm nx affected:test --base=main
pnpm nx affected:build --base=main
```

### Step 3: Push Branch

```bash
# Push with upstream tracking
git push -u origin $(git branch --show-current)
```

### Step 4: Generate PR Content

Analyze commits to generate:

1. **Title**: From `$ARGUMENTS` or first commit message
2. **Summary**: List of changes from commit messages
3. **Changed Files**: From `git diff --stat main`
4. **Test Plan**: Based on affected libs

### Step 5: Create PR

```bash
gh pr create \
  --title "$ARGUMENTS" \
  --body "$(cat <<'EOF'
## Summary

[Auto-generated bullet points from commits]

## Changes

[List of modified files grouped by lib]

## Test Plan

- [ ] Unit tests pass (`pnpm nx affected:test`)
- [ ] Lint passes (`pnpm nx affected:lint`)
- [ ] Build passes (`pnpm nx affected:build`)
- [ ] Manual testing completed

## Screenshots

[If UI changes, include before/after]

---

Generated with Claude Code
EOF
)"
```

### Step 6: Return Result

- PR URL
- PR number
- Next steps (request reviewers, add labels)

---

## Review PR Workflow

### Step 1: Fetch PR Details

```bash
# Get PR info
gh pr view $PR_NUMBER

# Get diff
gh pr diff $PR_NUMBER
```

### Step 2: Analyze Changes

Use @code-reviewer agent:

```
Task (subagent_type: code-reviewer):
  prompt: |
    Review this PR diff for:

    1. Code Standards Compliance
       - Follows .agent/System/ guidelines
       - Proper naming conventions
       - Max 5 statements per function

    2. Architecture Compliance
       - Correct lib boundaries
       - Proper imports (direct, not barrel)
       - Facade pattern usage

    3. Angular Patterns
       - Standalone components
       - Signals for state
       - @if/@for control flow

    4. Testing
       - Tests exist for new code
       - Mocks properly used
       - data-testid attributes

    5. Security
       - No hardcoded secrets
       - Proper input validation
       - No XSS vulnerabilities

    Diff:
    [PR diff content]
```

### Step 3: Check CI Status

```bash
gh pr checks $PR_NUMBER
```

### Step 4: Post Review

Based on analysis:

```bash
# Approve
gh pr review $PR_NUMBER --approve --body "LGTM! [summary]"

# Request changes
gh pr review $PR_NUMBER --request-changes --body "[issues found]"

# Comment only
gh pr review $PR_NUMBER --comment --body "[observations]"
```

---

## PR Templates

### Feature PR
```markdown
## Summary

Add [feature name] to [scope].

## Changes

### New Files
- `libs/[scope]/feature-[name]/...`

### Modified Files
- `apps/web/src/app/app.routes.ts` - Added route

## Test Plan

- [ ] Unit tests added (coverage > 80%)
- [ ] E2E test for happy path
- [ ] Manual testing on Chrome, Firefox, Safari
- [ ] Responsive testing (mobile, tablet, desktop)

## Screenshots

| Before | After |
|--------|-------|
| [img]  | [img] |
```

### Bug Fix PR
```markdown
## Summary

Fix [bug description].

## Root Cause

[Explanation of what was wrong]

## Solution

[Explanation of the fix]

## Test Plan

- [ ] Regression test added
- [ ] Existing tests still pass
- [ ] Manual verification of fix

## Related Issues

Fixes #[issue-number]
```

### Refactor PR
```markdown
## Summary

Refactor [component/service] to [improvement].

## Motivation

[Why this refactor is needed]

## Changes

[List of structural changes]

## Test Plan

- [ ] All existing tests pass
- [ ] No behavior changes (verified manually)
- [ ] Performance not degraded

## Breaking Changes

None / [list if any]
```

---

## Tips

- Keep PRs focused (one feature/fix per PR)
- Write descriptive titles (not "fix bug" or "update code")
- Include screenshots for UI changes
- Link related issues
- Request specific reviewers for domain expertise
