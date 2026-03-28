# /type-audit - Type Safety Audit

Scan codebase for weak typing patterns and recommend type-safe alternatives.

## Usage

```
/type-audit [scope] [--severity=all|critical|high] [--fix]
```

- `scope`: `affected` (default) | `all` | `[project-name]` | `[file-path]`
- `--severity`: `all` (default) | `critical` (any + as any only) | `high`
- `--fix`: attempt auto-fix for simple cases (add return types, type arrays)

## Examples

```
/type-audit                              # Affected projects, all severities
/type-audit all --severity=critical      # Full codebase, any/as any only
/type-audit libs/admin/ --fix            # Admin scope with auto-fix
/type-audit user-data-access             # Specific project
```

## Steps

### 1. Parse Arguments

Extract scope, severity filter, and fix flag from $ARGUMENTS.

### 2. Run Type Safety Scan

```
@type-safety-auditor
  scope: [parsed scope]
  severity: [parsed severity]
  fix: [parsed fix flag]
```

### 3. Generate Report

Output Type Safety Audit Report with:
- Overall score
- Violations by category and severity
- Top offender files
- Remediation guide with suggested types
- Quick wins list

### 4. Auto-Fix (when --fix)

For simple cases only:
- Add explicit types to untyped arrays: `[] → Type[]`
- Add return types to methods that return known types
- Replace `any` with `unknown` where type is truly unknown

After fixes:
```bash
npx nx affected:lint --base=HEAD~1
npx nx affected:test --base=HEAD~1
```
