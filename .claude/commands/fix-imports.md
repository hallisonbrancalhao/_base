# /fix-imports - Import Organization Fixer

Detect and auto-fix import organization violations.

## Usage

```
/fix-imports [scope] [--mode=report|fix] [--checks=order|barrel|circular|all]
```

- `scope`: `affected` (default) | `all` | `[project-name]` | `[file-path]`
- `--mode`: `report` (default) | `fix` (apply changes)
- `--checks`: `all` (default) | `order` | `barrel` | `circular`

## Examples

```
/fix-imports                                  # Report all issues in affected files
/fix-imports --mode=fix                       # Auto-fix all issues in affected files
/fix-imports libs/admin/ --checks=barrel      # Report barrel imports in admin
/fix-imports all --checks=order --mode=fix    # Fix import order in all files
```

## Steps

### 1. Parse Arguments

Extract scope, mode, and checks from $ARGUMENTS.

### 2. Run Import Analysis

```
@import-fixer
  scope: [parsed scope]
  mode: [parsed mode]
  checks: [parsed checks]
```

### 3. Report/Fix

- Report mode: Show violations with file:line references and suggested fixes
- Fix mode: Apply fixes, then run `nx affected:lint` to validate

## Import Order Reference

```
1. Angular (@angular/*)
2. Third-party (rxjs, class-validator, etc.)
3. PrimeNG (primeng/*)
4. Shared/project (@project/*)
5. Local (./ or ../)
```
