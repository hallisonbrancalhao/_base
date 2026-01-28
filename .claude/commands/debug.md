# Debug Workflow

Systematically investigate and fix issues.

## Arguments

`$ARGUMENTS` - Error message, stack trace, or issue description

## Workflow

### Phase 1: Gather Context

1. **Search for error** in codebase:
   ```bash
   # Search for error message
   grep -r "error message" --include="*.ts"

   # Find related files
   git log --oneline -10 -- "path/to/file"
   ```

2. **Check recent changes**:
   ```bash
   git diff HEAD~5 --stat
   git log --oneline -10
   ```

3. **Identify affected components**:
   - Which lib/app is affected?
   - What's the call chain?
   - Are there related tests?

### Phase 2: Analyze

Use the @debugger agent for deep analysis:

```
Task (subagent_type: general-purpose):
  prompt: |
    Read .agent/Agents/analysis/@debugger.md

    Investigate this issue:
    $ARGUMENTS

    Analyze:
    1. Root cause identification
    2. Affected files and components
    3. Potential fixes (ranked by risk)
    4. Similar past issues (if any)

    Return structured analysis.
```

### Phase 3: Investigate

1. **Read relevant files**:
   - Component/service with the bug
   - Related tests (if they exist)
   - Interfaces/types involved

2. **Check for patterns**:
   - Is this a known issue pattern?
   - Are there similar implementations that work?

3. **Trace the flow**:
   - Input → Processing → Output
   - Where does it break?

### Phase 4: Fix

1. **Implement minimal fix**:
   - Change only what's necessary
   - Don't refactor unrelated code
   - Keep the fix focused

2. **Add regression test**:
   ```typescript
   it('should handle [edge case that caused bug]', () => {
     // Arrange: Set up the failing condition
     // Act: Trigger the bug scenario
     // Assert: Verify correct behavior
   });
   ```

3. **Validate fix**:
   ```bash
   pnpm nx affected:test --base=HEAD~1
   pnpm nx affected:lint --base=HEAD~1
   ```

### Phase 5: Document

1. **Add comment if fix is non-obvious**:
   ```typescript
   // FIXME(TICKET-XXX): Workaround for [issue]
   // Remove when [condition] is fixed
   ```

2. **Update docs if behavior changed**

3. **Create commit with context**:
   ```
   fix(scope): brief description

   Root cause: [what was wrong]
   Fix: [what was changed]

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```

## Common Debug Patterns

### Null/Undefined Errors
```typescript
// Check for optional chaining issues
user?.address?.street  // If user is null, this returns undefined

// Check for missing null checks
if (!user) return;  // Early return pattern
```

### Async/Timing Issues
```typescript
// Race conditions - add proper sequencing
await firstOperation();
await secondOperation();  // Ensure order

// Missing error handling
observable.subscribe({
  next: (data) => { },
  error: (err) => { },  // Don't forget this
});
```

### Type Errors
```typescript
// Check interface changes
// Did the API response change?
// Are types out of sync with backend?
```

### Import/Module Errors
```bash
# Check for circular dependencies
npx madge --circular --extensions ts libs/

# Verify path aliases in tsconfig
```

## Output Format

After investigation, provide:

1. **Root Cause**: Clear explanation of why the bug occurs
2. **Affected Files**: List of files involved
3. **Fix Applied**: What was changed
4. **Test Added**: Description of regression test
5. **Validation**: Results of lint/test/build
