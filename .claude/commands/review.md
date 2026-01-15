# /review - Code Review Command

Invoke the code reviewer agent on recent changes.

## Usage

```
/review [path]
```

- `path`: Specific file/folder to review (default: all changed files)

## Execution

### 1. Get Changed Files

```bash
git diff --name-only HEAD~1
```

### 2. Invoke Code Reviewer

```
@code-reviewer
  task: Review code changes
  context: $ARGUMENTS or git diff files
  focus: All standards (TypeScript, Angular, Architecture)
```

### 3. Required Reading

Before reviewing, reference these files:
- `.agent/System/typescript_clean_code.md`
- `.agent/System/angular_full.md`
- `.agent/System/primeng_best_practices.md`
- `.agent/System/libs_architecture_pattern.md`

## Review Checklist

### TypeScript
- [ ] Functions max 5 statements
- [ ] Functions max 3 parameters
- [ ] Self-documenting names

### Angular
- [ ] Standalone components
- [ ] Signals for state
- [ ] @if/@for control flow
- [ ] inject() function

### Architecture
- [ ] Correct lib dependencies
- [ ] Proper imports

## Output

```markdown
## Code Review: [files]

### Summary
- Critical: [N]
- High: [N]
- Medium: [N]
- Low: [N]

### Issues
[List issues with severity and fix suggestions]

### Verdict: APPROVE / REQUEST CHANGES
```
