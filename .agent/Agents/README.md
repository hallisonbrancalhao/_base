# Sub-Agent Execution Protocol

> **Primary Agent = Orchestrator Only**
> All tasks MUST be delegated to specialized sub-agents via the **Task tool**.

---

## Quick Start

### Planning a Single Task
```
/plan WORK-xxxx
```
Investigates and creates a DEV_PRD for a single task using specialized agents.

### Orchestrating Multiple Tasks
```
/orchestrate WORK-1234 WORK-1235 WORK-1236
```
Classifies, analyzes in parallel, and creates DEV_PRDs for multiple tasks.

### Generating Executable Specs
```
/spec
```
Converts approved DEV_PRDs into machine-executable specs.

### Running Full AI-Guard Audit
```
/audit-report [scope]
```
Executa os 3 auditores (performance + segurança + arquitetura) em paralelo e gera relatório consolidado. Escopo: `affected` (default) | `all` | `lib:[name]` | `feature:[name]`.

### Implementing a Spec
```
/task
```
Implements a single spec following all project patterns.

### Implementing in Parallel
```
/task-team
```
Launches Agent Teams to implement multiple specs in parallel (isolated worktrees).

---

## Agent Categories

### Orchestration Pipeline (`.claude/agents/`)

Specialized agents for the multi-task orchestration workflow:

```
.claude/agents/
├── orchestrator.md            ← Classifies tasks, coordinates agents
├── bug-investigator.md        ← Investigates bugs (root cause, data flow)
├── enhancement-analyst.md     ← Analyzes enhancements (business rules, reuse)
├── prd-writer.md              ← Creates human-readable DEV_PRDs
├── spec-writer.md             ← Converts PRDs into executable specs
└── implementer.md             ← Teammate that implements 1 spec end-to-end
```

### Development Agents (`.agent/Agents/`)

Sub-agents for code generation and project tasks:

```
.agent/Agents/
├── README.md                  ← YOU ARE HERE
├── planning/                  ← Planning & orchestration
│   └── @task-planner.md       ← Feature planning workflow
├── design/                    ← UX/UI & brand
│   ├── @ux-researcher.md      ← User research, personas, journeys
│   ├── @ui-designer.md        ← UI specs, components, layouts
│   └── @brand-guardian.md     ← Brand consistency
├── quality/                   ← Code quality & validation
│   ├── @qa-runner.md          ← Tests, build, lint execution
│   ├── @arch-validator.md     ← Architecture compliance
│   ├── @code-reviewer.md      ← Code review & standards
│   ├── @performance-auditor.md ← N+1, race condition, memory leak
│   ├── @security-auditor.md   ← SAST, secret scan, SCA, version pinning
│   └── @architecture-reviewer.md ← Tradeoffs, reliability, contingency (DR)
├── development/               ← Code generation & refactoring
│   ├── @coder.md              ← Write and refactor code
│   ├── @frontend-developer.md ← Angular implementation
│   ├── @backend-architect.md  ← NestJS API implementation
│   ├── @test-writer.md        ← Unit/integration tests
│   └── @docs-writer.md        ← Documentation
├── automation/                ← DevOps & tooling
│   ├── @e2e-tester.md         ← Browser E2E testing
│   ├── @git-operator.md       ← Git operations & commits
│   └── @nx-operator.md        ← Nx workspace operations
└── analysis/                  ← Research & exploration
    ├── @explorer.md           ← Codebase exploration
    └── @debugger.md           ← Issue investigation
```

---

## How to Invoke Sub-Agents

Use the **Task tool** to spawn sub-agents. Each agent runs with its own context.

### Parallel Execution
When tasks are independent, launch multiple agents simultaneously:

```markdown
# Launch 3 agents in parallel (single message with multiple Task calls)

Task 1:
  subagent_type: Explore
  prompt: "Explore libs/user/ for existing patterns..."

Task 2:
  subagent_type: Plan
  prompt: "Analyze architecture for new user-preferences feature..."

Task 3:
  subagent_type: general-purpose
  prompt: "Read @ux-researcher.md and create user persona for..."
```

### Sequential Execution
When tasks depend on previous results:

```markdown
# Step 1: Explore codebase
Task:
  subagent_type: Explore
  prompt: "Find all facade implementations in the codebase..."

# Wait for result, then Step 2: Plan based on findings
Task:
  subagent_type: Plan
  prompt: "Based on facade patterns found: {results}, design..."
```

---

## Available Sub-Agent Types

### Task Tool Agents

| subagent_type | Purpose | Tools Available |
|---------------|---------|-----------------|
| `Explore` | Fast codebase exploration | Glob, Grep, Read |
| `Plan` | Architecture planning | All read-only tools |
| `general-purpose` | Multi-step tasks, agent invocation | All tools |
| `code-reviewer` | Code review | Read, Grep, Glob |

### Orchestration Agents (`.claude/agents/`)

| Agent | Trigger | Purpose |
|-------|---------|---------|
| `orchestrator` | `/orchestrate` | Classifies tasks, spawns specialists in parallel |
| `bug-investigator` | Bug tasks | Gathers error context, traces root cause |
| `enhancement-analyst` | Enhancement tasks | Consults business rules, identifies reuse |
| `prd-writer` | After analysis | Creates human-readable DEV_PRDs |
| `spec-writer` | After PRD approval | Converts PRDs into executable specs |
| `implementer` | `/task-team` | Implements 1 spec end-to-end in isolated worktree |

### Using Agent Definitions
For `general-purpose` agents, reference agent files:

```markdown
Task:
  subagent_type: general-purpose
  prompt: |
    Read .agent/Agents/design/@ui-designer.md

    Then create UI specs for:
    - Dashboard card component
    - Mobile-first responsive
    - Dark mode support

    Output: Component template with PrimeNG
```

---

## Feature Development Workflow

### Phase 1: Planning (Parallel Investigation)

```
┌─────────────────────────────────────────────────────────────────┐
│                    PARALLEL CONTEXT GATHERING                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────────┐    │
│  │   Explore   │  │     Plan     │  │  general-purpose    │    │
│  │  (codebase) │  │ (architecture)│  │  (@ux-researcher)  │    │
│  └──────┬──────┘  └──────┬───────┘  └─────────┬───────────┘    │
│         │                │                     │                 │
│         └────────────────┼─────────────────────┘                │
│                          ▼                                       │
│                   ┌─────────────┐                               │
│                   │  PRD Created │                               │
│                   └─────────────┘                               │
└─────────────────────────────────────────────────────────────────┘
```

### Phase 2: Implementation (Sequential)

```
@nx-operator      → Generate libs
       ↓
@coder (domain)   → Interfaces, DTOs
       ↓
@coder (data)     → Facades, repositories
       ↓
@coder (feature)  → Components
       ↓
@test-writer      → Unit tests
       ↓
@qa-runner        → lint, test, build
       ↓
@git-operator     → Commit
```

---

## Quick Reference

| Need | Agent | subagent_type |
|------|-------|---------------|
| **Planning** |||
| Full feature plan | `@task-planner` | Use `/plan` command |
| Architecture check | `@arch-validator` | `Plan` |
| **Research** |||
| Find code patterns | `@explorer` | `Explore` |
| User research | `@ux-researcher` | `general-purpose` |
| **Design** |||
| UI specifications | `@ui-designer` | `general-purpose` |
| **Development** |||
| Write code | `@coder` | `general-purpose` |
| Write tests | `@test-writer` | `general-purpose` |
| Generate libs | `@nx-operator` | `general-purpose` |
| **Quality** |||
| Run validations | `@qa-runner` | `general-purpose` |
| Review code | `@code-reviewer` | `code-reviewer` |
| Audit performance (N+1, race, leak) | `@performance-auditor` | `general-purpose` |
| Audit security (SAST, secrets, SCA) | `@security-auditor` | `general-purpose` |
| Review architecture (tradeoffs, DR) | `@architecture-reviewer` | `general-purpose` |
| Complete AI-Guard report | `/audit-report` | Slash command |
| **Operations** |||
| Create commit | `@git-operator` | `general-purpose` |
| Debug issue | `@debugger` | `general-purpose` |

---

## Workflow Examples

### Multi-Task Orchestration (Recommended)

```markdown
# 1. Orchestrate multiple tasks at once
/orchestrate WORK-1234 WORK-1235 WORK-1236
# → Classifies each as bug/enhancement/feature
# → Spawns specialized analysts in parallel
# → Creates DEV_PRD for each task

# 2. Review each DEV_PRD in .agent/Tasks/
# → Set status to "aprovado" in frontmatter

# 3. Generate executable specs
/spec

# 4. Implement all specs in parallel
/task-team
```

### Single Task (Plan → Implement)

```markdown
# 1. Plan a single task
/plan WORK-1234

# 2. Review DEV_PRD, set status to "aprovado"

# 3. Generate spec
/spec

# 4. Implement
/task
```

### New Feature (Manual Pipeline)

```markdown
# 1. Plan the feature
/plan
# Describe: "User preferences feature for saving dashboard settings"

# 2. After PRD is created, implement in order:
@nx-operator → Generate libs
@coder → Implement domain layer
@coder → Implement data-access layer
@coder → Implement feature components
@test-writer → Write tests
@qa-runner → Validate
@git-operator → Commit
```

### Bug Fix

```markdown
# 1. Investigate
Task (subagent_type: general-purpose):
  prompt: "@debugger - Investigate root cause of {error}"

# 2. Fix
Task (subagent_type: general-purpose):
  prompt: "@coder - Fix the issue based on: {findings}"

# 3. Test
Task (subagent_type: general-purpose):
  prompt: "@test-writer - Add regression test for {bug}"

# 4. Validate & Commit
@qa-runner → lint, test, build
@git-operator → commit
```

### Code Review

```markdown
# Run parallel reviews
Task 1 (subagent_type: code-reviewer):
  prompt: "Review code changes for standards compliance"

Task 2 (subagent_type: Plan):
  prompt: "@arch-validator - Check architecture rules"

# Then validate
@qa-runner → lint, test, build
```

---

## Rules

1. **Use Task tool for agents** - Never try to invoke agents directly in conversation
2. **Parallel when possible** - Launch independent agents simultaneously
3. **Sequential when dependent** - Wait for results when next step needs them
4. **Always validate** - Run `@qa-runner` before any commit
5. **Reference agent files** - Use `Read .agent/Agents/...` for context

---

## Hooks (Simplified)

The project uses minimal hooks:

| Hook | Trigger | Action |
|------|---------|--------|
| Pre-commit | `git commit` | Run `nx affected:lint/test/build` |

All other orchestration is done through the Task tool and sub-agents.

---

## Artifact Locations

- **Plans**: `.agent/Plans/` (Claude's native plan mode)
- **PRDs**: `.agent/Tasks/PRD-*.md` (structured requirements)
- **DEV_PRDs**: `.agent/Tasks/DEV_PRD_WORK_*.md` (orchestration pipeline output)
- **Specs**: `.agent/Tasks/SPEC_WORK_*.md` (executable specifications)
- **Templates**: `.agent/Tasks/TEMPLATE_*.md` (DEV_PRD and Spec templates)
- **Archive**: `.agent/Plans/archive/` (completed plans)
- **Orchestration SOP**: `.agent/SOPs/orchestration_workflow.md`

---

**See individual agent files for detailed capabilities:**
- `.claude/agents/` - Orchestration pipeline agents
- `.agent/Agents/` - Development sub-agents
