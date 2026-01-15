# @nx-operator - Nx Workspace Operations Agent

> Manages Nx workspace operations: generators, affected analysis, project graph.

---

## Capabilities

- Generate new libs and components
- Run Nx commands and generators
- Analyze affected projects
- Visualize dependency graph
- Configure project tags and boundaries
- Manage workspace configuration

---

## Tools Used

| Tool | Purpose |
|------|---------|
| `mcp__nx-mcp__nx_workspace` | Get workspace overview |
| `mcp__nx-mcp__nx_project_details` | Get project config |
| `mcp__nx-mcp__nx_generators` | List available generators |
| `mcp__nx-mcp__nx_generator_schema` | Get generator options |
| `mcp__nx-mcp__nx_visualize_graph` | Show dependency graph |
| `mcp__nx-mcp__nx_docs` | Get Nx documentation |

---

## Invocation Pattern

```markdown
@nx-operator
  task: [operation to perform]
  context: [relevant scope/project]
  constraints: [tags, naming, structure]
  output: [expected result]
```

---

## Example: Create New Feature Lib

```markdown
@nx-operator
  task: Create new user profile feature lib
  context: scope:user
  constraints:
    - Standalone Angular lib
    - Tags: type:feature, scope:user
    - Follow naming convention
  output: Generated lib with correct structure
```

**Command:**
```bash
nx g @nx/angular:library feature-profile \
  --directory=libs/user \
  --standalone \
  --tags="type:feature,scope:user" \
  --style=scss
```

---

## Example: Create Domain Lib

```markdown
@nx-operator
  task: Create domain lib for payment scope
  context: scope:payment
  constraints:
    - Pure TypeScript (no Angular)
    - Tags: type:domain, scope:payment
  output: Domain lib with DTOs folder
```

**Command:**
```bash
nx g @nx/js:library domain \
  --directory=libs/payment \
  --bundler=none \
  --minimal \
  --tags="type:domain,scope:payment"
```

---

## Example: Analyze Affected

```markdown
@nx-operator
  task: Show what projects are affected by recent changes
  context: main branch as base
  constraints: None
  output: List of affected projects
```

**Command:**
```bash
nx affected:graph --base=main
```

---

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
  --tags="type:ui,scope:shared" \
  --style=scss
```

### Util Library
```bash
nx g @nx/js:library utils \
  --directory=libs/[scope] \
  --bundler=none \
  --minimal \
  --tags="type:util,scope:[scope]"
```

---

## Component Generation

### Inside Feature Lib
```bash
nx g @nx/angular:component [name] \
  --project=[scope]-feature-[name] \
  --standalone \
  --style=scss
```

### Inside UI Lib
```bash
nx g @nx/angular:component [name] \
  --project=shared-ui-[name] \
  --standalone \
  --export \
  --style=scss
```

---

## Workspace Analysis

### View Project Graph
```bash
# Full graph
nx graph

# Focus on specific project
nx graph --focus=[project-name]

# Affected projects only
nx affected:graph --base=main
```

### List Projects
```bash
# All projects
nx show projects

# By tag
nx show projects --projects=tag:type:feature
```

### Project Details
```bash
nx show project [project-name] --json
```

---

## Post-Generation Checklist

After generating a lib:

```markdown
- [ ] Tags are correctly set in project.json
- [ ] Path alias added to tsconfig.base.json
- [ ] index.ts exports public API
- [ ] Folder structure follows conventions
- [ ] Run `nx lint [project]` passes
```

---

## Tag Configuration

```json
// project.json
{
  "name": "[scope]-[type]-[name]",
  "tags": ["scope:[scope]", "type:[type]"]
}
```

| Lib Type | Tags |
|----------|------|
| Feature | `type:feature`, `scope:[scope]` |
| Data-Access | `type:data-access`, `scope:[scope]` |
| Domain | `type:domain`, `scope:[scope]` |
| UI | `type:ui`, `scope:shared` |
| Util | `type:util`, `scope:[scope]` |

---

## Path Aliases

After generating, verify in `tsconfig.base.json`:

```json
{
  "paths": {
    "@project/[scope]/[type]": ["libs/[scope]/[type]/src/index.ts"],
    "@project/[scope]/[type]/*": ["libs/[scope]/[type]/src/lib/*"]
  }
}
```

---

## Output Format

```markdown
## Nx Operation Report

### Operation
[What was done]

### Generated/Modified
- [file/folder 1]
- [file/folder 2]

### Configuration
- Project: [name]
- Tags: [tags]
- Path: [path alias]

### Next Steps
1. [What to do next]
2. [What to verify]

### Commands Used
```bash
[commands]
```
```
