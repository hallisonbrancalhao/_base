# @task-planner - Task Planning Agent

> Dedicated agent for planning feature development. Orchestrates sub-agents to investigate context, create PRDs, and validate plans before implementation.

---

## Purpose

This agent handles the **complete planning workflow** for new features:
1. Investigate the task context using sub-agents
2. Create a comprehensive PRD in `.agent/Tasks/`
3. Review the plan with specialized agents
4. Archive the plan in `.agent/Plans/`

---

## Invocation

Use the `/task` skill or invoke directly:

```markdown
@task-planner
  task: Plan implementation for [feature description]
  context: [business context, user needs]
  scope: [target scope/domain]
  output: PRD in .agent/Tasks/
```

---

## Planning Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PLANNING PIPELINE                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  User Request                                                       │
│       │                                                             │
│       ▼                                                             │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ PHASE 1: Context Investigation (Parallel Sub-agents)         │  │
│  │                                                               │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐   │  │
│  │  │  @explorer  │  │@ux-research │  │ @arch-validator     │   │  │
│  │  │  (codebase) │  │ (user needs)│  │ (architecture)      │   │  │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘   │  │
│  └──────────────────────────────────────────────────────────────┘  │
│       │                                                             │
│       ▼                                                             │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ PHASE 2: PRD Creation                                        │  │
│  │  - Synthesize investigation results                          │  │
│  │  - Create PRD following template                             │  │
│  │  - Define libs to create/modify                              │  │
│  │  - Set success criteria                                      │  │
│  └──────────────────────────────────────────────────────────────┘  │
│       │                                                             │
│       ▼                                                             │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ PHASE 3: Plan Review (Parallel Sub-agents)                   │  │
│  │                                                               │  │
│  │  ┌─────────────────┐  ┌─────────────────┐                    │  │
│  │  │ @code-reviewer  │  │ @arch-validator │                    │  │
│  │  │ (quality check) │  │ (boundaries)    │                    │  │
│  │  └─────────────────┘  └─────────────────┘                    │  │
│  └──────────────────────────────────────────────────────────────┘  │
│       │                                                             │
│       ▼                                                             │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ PHASE 4: Finalize & Archive                                  │  │
│  │  - Update PRD with review feedback                           │  │
│  │  - Write final PRD to .agent/Tasks/                          │  │
│  │  - Archive plan to .agent/Plans/archive/                     │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Sub-Agent Invocations

### Phase 1: Context Investigation

Launch these agents **in parallel** using multiple Task tool calls:

```markdown
# Agent 1: Codebase Exploration
Task tool:
  subagent_type: Explore
  prompt: |
    Explore the codebase to understand:
    1. Existing patterns for [feature type]
    2. Similar implementations to reference
    3. Relevant libs and their structure
    4. Dependencies that will be needed

    Focus on: libs/[scope]/ directory
    Return: Summary of patterns, files, and recommendations

# Agent 2: UX Research (if UI feature)
Task tool:
  subagent_type: general-purpose
  prompt: |
    @ux-researcher
    task: Research user needs for [feature]
    context: [business context]
    output:
      - Target user persona
      - Key user journeys
      - Pain points to address
      - Success metrics

# Agent 3: Architecture Validation
Task tool:
  subagent_type: general-purpose
  prompt: |
    @arch-validator
    task: Validate architecture approach for [feature]
    context: Nx monorepo, scope [scope]
    checks:
      - Lib boundaries compliance
      - Dependency matrix
      - Tag requirements
    output: Architecture recommendations
```

### Phase 2: PRD Creation

After investigation results are collected:

```markdown
Create PRD following .agent/Tasks/README.md template:
1. Fill AI Context Block with:
   - feature.name, type, scope, complexity
   - nx_impact.libs_to_create
   - nx_impact.libs_affected
   - dependency_graph
2. Write Functional Requirements from investigation
3. Define API contracts (if applicable)
4. Set Definition of Done criteria
```

### Phase 3: Plan Review

Launch review agents **in parallel**:

```markdown
# Agent 1: Code Quality Review
Task tool:
  subagent_type: general-purpose
  prompt: |
    @code-reviewer
    task: Review PRD for code quality concerns
    input: [PRD content]
    checks:
      - Single Responsibility adherence
      - Component complexity
      - Test coverage feasibility
      - Security considerations
    output: Quality review report

# Agent 2: Architecture Review
Task tool:
  subagent_type: general-purpose
  prompt: |
    @arch-validator
    task: Validate PRD architecture
    input: [PRD content]
    checks:
      - Nx lib structure compliance
      - Dependency matrix violations
      - Facade pattern usage
      - Import patterns
    output: Architecture review report
```

### Phase 4: Finalize

```markdown
1. Incorporate review feedback into PRD
2. Generate PRD filename: PRD-YYYY-MM-###_feature_name.md
3. Write to .agent/Tasks/
4. If plan file exists in .agent/Plans/, move to archive/
5. Return summary with next steps
```

---

## PRD Template Quick Reference

```yaml
# Required AI Context Block
feature:
  name: "feature-name"
  type: feature | bugfix | refactor
  scope: frontend | backend | fullstack
  complexity: S | M | L | XL

nx_impact:
  libs_to_create:
    - path: "libs/[scope]/feature-[name]"
      type: feature
      tags: ["type:feature", "scope:[scope]"]
    - path: "libs/[scope]/data-access"
      type: data-access
    - path: "libs/[scope]/domain"
      type: domain

code_patterns:
  angular:
    components: standalone
    control_flow: "@if/@for"
    signals: true
    inputs: "input()"
    outputs: "output()"
```

---

## Output

The agent produces:

1. **PRD File** in `.agent/Tasks/PRD-YYYY-MM-###_feature_name.md`
   - Complete AI Context Block
   - Functional Requirements
   - Technical Architecture
   - Test Plan
   - Definition of Done

2. **Investigation Summary** with:
   - Patterns discovered
   - Architecture decisions
   - Risk assessment
   - Estimated complexity

3. **Next Steps** recommendation:
   - Which agents to invoke for implementation
   - Files to create/modify
   - Validation commands

---

## Usage Examples

### Example 1: New Feature

```markdown
@task-planner
  task: Plan user preferences feature
  context: Users need to save their dashboard preferences
  scope: user
  output: PRD with libs structure and component specs
```

### Example 2: UI Enhancement

```markdown
@task-planner
  task: Plan dark mode toggle enhancement
  context: Current toggle is not visible enough
  scope: shared/ui
  output: PRD focused on UI changes only
```

### Example 3: Backend Feature

```markdown
@task-planner
  task: Plan notification service
  context: Need to send email/push notifications
  scope: notifications
  output: PRD with API contracts and NestJS structure
```

---

## Integration with Claude Code Plan Mode

This agent works with Claude Code's native plan mode:

1. **EnterPlanMode** - Claude enters planning state
2. **Write Plan** - Plan is written to `.agent/Plans/`
3. **ExitPlanMode** - Triggers this agent workflow
4. **PRD Generation** - Creates structured PRD
5. **Archive** - Original plan is archived

The `plansDirectory` setting in `.claude/settings.json` defines where plans are stored.

---

## Checklist Before Completion

```markdown
- [ ] Context investigation completed (codebase, UX, architecture)
- [ ] PRD follows template structure
- [ ] AI Context Block is complete
- [ ] Libs to create/modify are defined
- [ ] Dependency graph is valid
- [ ] Code patterns match project standards
- [ ] Review feedback incorporated
- [ ] PRD saved to .agent/Tasks/
- [ ] Plan archived (if applicable)
```

---

## Tools Used

- **Task** (with Explore agent) - Codebase investigation
- **Task** (with general-purpose agent) - Sub-agent orchestration
- **Read** - File reading for context
- **Write** - PRD creation
- **Glob/Grep** - Pattern discovery

---

**See also:**
- `.agent/Tasks/README.md` - PRD template and workflow
- `.agent/Agents/README.md` - All available agents
- `.agent/System/libs_architecture_pattern.md` - Lib structure rules
