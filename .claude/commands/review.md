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

### 2. Invoke Code Reviewer (fable)

```
Task tool:
  subagent_type: code-reviewer
  description: "Review changes"
  prompt: |
    Review the diff: $ARGUMENTS (default: git diff HEAD~1).
    Focus: all standards (TypeScript, Angular, Architecture).
    Return verdict + findings by severity.
```

O agente carrega o context pack e as docs de referência por conta própria (just-in-time via doc_references.md).

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
