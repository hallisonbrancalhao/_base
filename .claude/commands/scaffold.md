# /scaffold - Domain Structure Generator

Scaffold a complete domain vertical slice with all libraries.

## Usage

```
/scaffold [entity-name] [--scope=scope-name] [--layers=all|frontend|backend] [--features=name1,name2]
```

- `entity-name` (required): kebab-case entity name (e.g., `payment`, `order`, `notification`)
- `--scope`: scope name (defaults to entity name)
- `--layers`: `all` (default) | `frontend` (domain + data-access) | `backend` (domain + data-source)
- `--features`: comma-separated feature names to generate

## Examples

```
/scaffold payment                               # Full domain: domain + data-access + data-source
/scaffold order --features=list,detail          # Full domain + 2 features
/scaffold notification --layers=frontend        # Frontend only: domain + data-access
/scaffold invoice --scope=billing               # Under billing/ scope
```

## Steps

### 1. Parse Arguments

Extract entity name, scope, layers, and features from $ARGUMENTS.

### 2. Validate

- Check entity name is valid kebab-case
- Check scope doesn't already exist in libs/
- Verify tsconfig.base.json exists

### 3. Generate

```
@domain-scaffolder
  entity: [parsed entity]
  scope: [parsed scope]
  layers: [parsed layers]
  features: [parsed features]
```

### 4. Post-Generation

1. Run `nx lint` on each generated library
2. Verify dependency graph with `nx graph`
3. Display generated structure and next steps
