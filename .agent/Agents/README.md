# Sub-Agent Execution Protocol

> **Primary Agent = Orchestrator Only**
> All tasks MUST be delegated to specialized sub-agents via the **Task tool**.

---

## Quick Start

### Planning a New Feature
```
/plan
```
This invokes the planning workflow that uses sub-agents to:
1. Investigate codebase context
2. Research UX requirements
3. Validate architecture
4. Create PRD in `.agent/Tasks/`

### Implementing an Existing Task
```
/task
```
This helps implement PRDs from `.agent/Tasks/` following all project patterns.

---

## Agent Categories

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
│   └── @code-reviewer.md      ← Code review & standards
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

| subagent_type | Purpose | Tools Available |
|---------------|---------|-----------------|
| `Explore` | Fast codebase exploration | Glob, Grep, Read |
| `Plan` | Architecture planning | All read-only tools |
| `general-purpose` | Multi-step tasks, agent invocation | All tools |
| `code-reviewer` | Code review | Read, Grep, Glob |

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
| **Operations** |||
| Create commit | `@git-operator` | `general-purpose` |
| Debug issue | `@debugger` | `general-purpose` |

---

## Workflow Examples

### New Feature (Full Pipeline)

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

## PRD Location

- **Plans**: `.agent/Plans/` (Claude's native plan mode)
- **PRDs**: `.agent/Tasks/PRD-*.md` (structured requirements)
- **Archive**: `.agent/Plans/archive/` (completed plans)

---

**See individual agent files for detailed capabilities and examples.**
