## Extras 

`.claude/settings.local.json`

```json
{
  "enabledPlugins": {
    "frontend-design@claude-plugins-official": true,
    "feature-dev@claude-plugins-official": true,
  }
}
```

## Setup CLAUDE.md and AGENTS.mc

```bash
bunx @intellectronica/ruler apply
```

## Install extras libs

```bash
# MCPL - MCP Launchpad (https://github.com/kenneth-liao/mcp-launchpad/)

# Using curl (most common)
	curl -LsSf https://astral.sh/uv/install.sh | sh

# Using MACOS
  brew install uv

# Install MCPL
  uv tool install https://github.com/kenneth-liao/mcp-launchpad.git
```
--- 

Uses .env.example as base for .env file

```bash
cp .env.example .env
``` 

Then edit the .env file to add your environment variables.

### Config your mcpl settings

```bash 
mcpl config
```
### Refresh your mcpl list

```bash
mcpl list --refresh
```

(Credit: @kenneth-liao)

--- 

# NEW PROJECT WORKFLOW (GDS OPTIONAL)

## GSD - (https://github.com/glittercowboy/get-shit-done) 

### Initialize project — use codebase context for planning

```bash
  /gsd:new-project
  /clear first → fresh context window
```

### 1. Start with an idea
/gsd:new-project

#### 1.5. Research the domain (optional)
```bash
/gsd:research-project
```

### 2. Define requirements
```bash
/gsd:define-requirements
```

### 3. Create roadmap
```bash
/gsd:create-roadmap
```

### 4. Plan and execute phases

```
/gsd:plan-phase 1      # System creates atomic task plans
/gsd:execute-phase 1   # Parallel agents execute all plans
```

Each phase breaks into 2-3 task plans. Each plan runs in a fresh subagent context — 200k tokens purely for implementation, zero degradation. Plans without dependencies run in parallel.

**For single-plan or interactive execution:**
```
/gsd:execute-plan      # Run one plan at a time with checkpoints
```

Use `/gsd:execute-phase` for parallel "walk away" automation (recommended). Use `/gsd:execute-plan` when you need interactive single-plan execution with manual checkpoints.

### 5. Ship and iterate

```
/gsd:complete-milestone   # Archive v1, prep for v2
/gsd:add-phase            # Append new work
/gsd:insert-phase 2       # Slip urgent work between phases
```
---

## Commands

### Setup

| Command | What it does |
|---------|--------------|
| `/gsd:new-project` | Extract your idea through questions, create PROJECT.md |
| `/gsd:research-project` | Research domain ecosystem (stacks, features, pitfalls) |
| `/gsd:define-requirements` | Scope v1/v2/out-of-scope requirements |
| `/gsd:create-roadmap` | Create roadmap with phases mapped to requirements |
| `/gsd:map-codebase` | Map existing codebase for brownfield projects |

### Execution

| Command | What it does |
|---------|--------------|
| `/gsd:plan-phase [N]` | Generate task plans for phase |
| `/gsd:execute-phase <N>` | Execute all plans in phase with parallel agents |
| `/gsd:execute-plan` | Run single plan via subagent |
| `/gsd:progress` | Where am I? What's next? |

### Verification

| Command | What it does |
|---------|--------------|
| `/gsd:verify-work [N]` | User acceptance test of phase or plan ¹ |

### Milestones

| Command | What it does |
|---------|--------------|
| `/gsd:complete-milestone` | Ship it, prep next version |
| `/gsd:discuss-milestone` | Gather context for next milestone |
| `/gsd:new-milestone [name]` | Create new milestone with phases |

### Phase Management

| Command | What it does |
|---------|--------------|
| `/gsd:add-phase` | Append phase to roadmap |
| `/gsd:insert-phase [N]` | Insert urgent work between phases |
| `/gsd:remove-phase [N]` | Remove future phase, renumber subsequent |
| `/gsd:discuss-phase [N]` | Gather context before planning |
| `/gsd:research-phase [N]` | Deep research for unfamiliar domains |
| `/gsd:list-phase-assumptions [N]` | See what Claude assumes before correcting |

### Session

| Command | What it does |
|---------|--------------|
| `/gsd:pause-work` | Create handoff file when stopping mid-phase |
| `/gsd:resume-work` | Restore from last session |

### Utilities

| Command | What it does |
|---------|--------------|
| `/gsd:add-todo [desc]` | Capture idea or task for later |
| `/gsd:check-todos [area]` | List pending todos, select one to work on |
| `/gsd:debug [desc]` | Systematic debugging with persistent state |
| `/gsd:help` | Show all commands and usage guide |

