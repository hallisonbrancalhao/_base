# /migrate - Legacy Pattern Migration

Migrate legacy Angular/TypeScript patterns to modern equivalents.

## Usage

```
/migrate [migration-type] [scope] [--mode=report|fix]
```

- `migration-type` (required): `standalone` | `control-flow` | `signals` | `inputs-outputs` | `inject` | `primeng` | `barrel-to-direct` | `all`
- `scope`: file path, project name, scope name, or `affected` (default)
- `--mode`: `report` (default, dry-run) | `fix` (apply changes)

## Examples

```
/migrate control-flow libs/admin/          # Report *ngIf/*ngFor in admin scope
/migrate signals --mode=fix                # Convert BehaviorSubject to signals in affected
/migrate primeng libs/shared/ui-components # Report PrimeNG directive usage
/migrate all --mode=report                 # Full migration report for all patterns
/migrate barrel-to-direct libs/            # Report barrel imports
```

## Steps

### 1. Parse Arguments

Extract migration type, scope, and mode from $ARGUMENTS.

### 2. Run Migration Scan

```
@migration-assistant
  migration: [parsed type]
  scope: [parsed scope]
  mode: [parsed mode]
```

### 3. Report Mode (default)

Generate migration report showing:
- Files affected
- Patterns found with line numbers
- Estimated changes
- Risks and breaking changes
- Recommended migration order

### 4. Fix Mode

When `--mode=fix`:
1. Create a working branch: `migration/[type]-[date]`
2. Apply migrations file by file
3. Run `nx affected:lint` after each batch
4. Run `nx affected:test` after all changes
5. Run `nx affected:build` for final validation
6. Report results

### 5. Post-Migration Validation

```bash
npx nx affected:lint --base=HEAD~1
npx nx affected:test --base=HEAD~1
npx nx affected:build --base=HEAD~1
```

## Migration Order (when using `all`)

1. `standalone` (foundation - other migrations depend on this)
2. `inject` (simplifies component structure)
3. `inputs-outputs` (signal-based I/O)
4. `signals` (state management modernization)
5. `control-flow` (template syntax)
6. `primeng` (UI component migration)
7. `barrel-to-direct` (import cleanup, last because paths change)
