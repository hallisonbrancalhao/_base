---
name: nx-operator
description: |
  Nx Workspace Operations - Manages Nx workspace: generators, affected analysis, project graph.
  TRIGGERS: nx generate, create lib, create library, nx graph, affected projects, nx workspace, generate component
---

# @nx-operator - Nx Workspace Operations

Manage Nx workspace: generators, affected analysis, project graph.

## Tools

| Tool | Purpose |
|------|---------|
| `mcp__nx-mcp__nx_workspace` | Workspace overview |
| `mcp__nx-mcp__nx_project_details` | Project config |
| `mcp__nx-mcp__nx_generators` | List generators |
| `mcp__nx-mcp__nx_generator_schema` | Generator options |
| `mcp__nx-mcp__nx_visualize_graph` | Dependency graph |

## Invocation Pattern

```
@nx-operator
  task: [operation]
  context: [scope/project]
  constraints: [tags, naming]
```

## Generator Commands

### Feature Library
```bash
nx g @nx/angular:library feature-[name] \
  --directory=libs/[scope] \
  --standalone \
  --tags="type:feature,scope:[scope]" \
  --style=scss
```

### Data-Access Library
```bash
nx g @nx/angular:library data-access \
  --directory=libs/[scope] \
  --standalone \
  --tags="type:data-access,scope:[scope]"
```

### Domain Library
```bash
nx g @nx/js:library domain \
  --directory=libs/[scope] \
  --bundler=none \
  --minimal \
  --tags="type:domain,scope:[scope]"
```

### UI Library
```bash
nx g @nx/angular:library ui-[name] \
  --directory=libs/shared \
  --standalone \
  --tags="type:ui,scope:shared"
```

### Component
```bash
nx g @nx/angular:component [name] \
  --project=[project-name] \
  --standalone
```

## Workspace Analysis

```bash
nx graph                          # Full graph
nx graph --focus=[project]        # Focus project
nx affected:graph --base=main     # Affected only
nx show projects                  # List projects
```

## Tag Configuration

| Lib Type | Tags |
|----------|------|
| Feature | `type:feature`, `scope:[scope]` |
| Data-Access | `type:data-access`, `scope:[scope]` |
| Domain | `type:domain`, `scope:[scope]` |
| UI | `type:ui`, `scope:shared` |
| Util | `type:util`, `scope:[scope]` |

## Post-Generation Checklist

- Tags set in project.json
- Path alias in tsconfig.base.json
- index.ts exports public API
- `nx lint [project]` passes
