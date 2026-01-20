# Agent Workflow Orchestration

> Define como os agentes se conectam e passam informação entre si para implementar features completas.

---

## Feature Development Pipeline

```
┌─────────────┐
│  PRD/Ideia  │
└──────┬──────┘
       │
       ▼
┌──────────────────┐     Output: Personas, Journey Maps
│  @ux-researcher  │────────────────────────────────────┐
└────────┬─────────┘                                    │
         │                                              │
         ▼                                              ▼
┌──────────────────┐     Output: Component Specs   ┌────────────┐
│   @ui-designer   │────────────────────────────── │ UX Insights│
└────────┬─────────┘                               └────────────┘
         │
         ▼
┌────────────────────────┐     Output: API Requirements
│  @frontend-developer   │─────────────────────────────────┐
└────────┬───────────────┘                                 │
         │                                                 │
         ▼                                                 ▼
┌────────────────────────┐                         ┌──────────────┐
│  @backend-architect    │ ◄─────────────────────  │DTO Contracts │
└────────────────────────┘                         └──────────────┘
```

---

## Workflow Completo: PRD → Produção

### Fase 1: Research (Parallel-Safe)

```markdown
@ux-researcher
  task: Analyze user needs for [feature]
  input: PRD document
  context: Target users, business goals
  output:
    - User personas
    - Journey maps
    - Pain points
    - Success metrics
```

**Handoff Document: `UX-RESEARCH.md`**

```markdown
## Feature: [Name]

### Personas
[Persona definitions]

### User Journey
[Journey map with stages, emotions, pain points]

### Key Insights
1. [Insight 1] → Implication for UI
2. [Insight 2] → Implication for UI
3. [Insight 3] → Implication for UI

### Success Metrics
- [Metric 1]: [Target]
- [Metric 2]: [Target]
```

---

### Fase 2: UI Design

```markdown
@ui-designer
  task: Design UI for [feature]
  input: UX-RESEARCH.md
  context: Design system, PrimeNG components
  constraints: Mobile-first, dark mode
  output:
    - Component specifications
    - Layout templates
    - State definitions
```

**Handoff Document: `UI-SPECS.md`**

```markdown
## Feature: [Name]

### Components Required
| Component | Type | PrimeNG | States |
|-----------|------|---------|--------|
| [Name]Card | Dumb | p-card | default, loading, error |
| [Name]Form | Smart | p-inputtext, p-button | default, submitting, error |
| [Name]List | Dumb | p-table | default, empty, loading |

### Layout Specifications
[Responsive layout details]

### Component Templates
[Angular template code for each component]

### Data Requirements
| Field | Type | Required | Validation |
|-------|------|----------|------------|
| name | string | yes | max 255 chars |
| description | string | no | max 1000 chars |
```

---

### Fase 3: Frontend Implementation

```markdown
@frontend-developer
  task: Implement [feature] components
  input: UI-SPECS.md
  context: libs/[scope]/feature-[name]
  constraints: Angular patterns, Facade pattern
  output:
    - Components implemented
    - Facade created
    - API requirements documented
```

**Handoff Document: `API-REQUIREMENTS.md`**

```markdown
## Feature: [Name]

### Endpoints Required

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| GET | /api/[resource] | List all | Yes |
| GET | /api/[resource]/:id | Get by ID | Yes |
| POST | /api/[resource] | Create | Yes |
| PUT | /api/[resource]/:id | Update | Yes |
| DELETE | /api/[resource]/:id | Delete | Yes |

### DTO Contracts

```typescript
interface [Name]Dto {
  id: string;
  name: string;
  description?: string;
  createdAt: string;
  updatedAt: string;
}

interface Create[Name]Dto {
  name: string;
  description?: string;
}
```

### Validation Rules
- name: required, max 255
- description: optional, max 1000

### Pagination
- Default: 20 items
- Max: 100 items
- Query params: page, limit

### Error Responses Expected
- 400: Validation errors
- 401: Unauthorized
- 404: Not found
- 500: Server error
```

---

### Fase 4: Backend Implementation

```markdown
@backend-architect
  task: Implement API for [feature]
  input: API-REQUIREMENTS.md
  context: libs/[scope]/data-source
  constraints: NestJS patterns, TypeORM
  output:
    - Controllers
    - Services
    - Entities
    - DTOs with validation
```

---

## Invocação Encadeada

Para executar o workflow completo:

```markdown
## Step 1: UX Research
@ux-researcher
  task: Research user needs for [feature]
  input: [PRD content or link]
  output: Save to .agent/Tasks/[feature]/UX-RESEARCH.md

## Step 2: UI Design (after Step 1 completes)
@ui-designer
  task: Design UI based on UX research
  input: .agent/Tasks/[feature]/UX-RESEARCH.md
  output: Save to .agent/Tasks/[feature]/UI-SPECS.md

## Step 3: Frontend (after Step 2 completes)
@frontend-developer
  task: Implement frontend components
  input: .agent/Tasks/[feature]/UI-SPECS.md
  output:
    - Components in libs/[scope]/feature-[name]
    - Save API requirements to .agent/Tasks/[feature]/API-REQUIREMENTS.md

## Step 4: Backend (after Step 3 completes)
@backend-architect
  task: Implement backend API
  input: .agent/Tasks/[feature]/API-REQUIREMENTS.md
  output: API in libs/[scope]/data-source
```

---

## Parallel Execution Options

### Research Phase (Can Run in Parallel)

```markdown
## Parallel Research Sprint

Run these simultaneously:

@ux-researcher
  task: Analyze user needs
  output: UX-RESEARCH.md

@brand-guardian
  task: Audit current brand compliance
  output: BRAND-AUDIT.md

@explorer
  task: Find existing patterns in codebase
  output: PATTERNS.md
```

### Implementation Phase (Sequential)

Frontend MUST complete before Backend (to define API contracts).

```
@frontend-developer → API-REQUIREMENTS.md → @backend-architect
```

---

## Quick Start Templates

### New Feature from Scratch

```markdown
# Feature: [Name]

## PRD Summary
[Brief description of what we're building]

## Workflow Execution

### 1. Research
@ux-researcher
  task: Research [feature] user needs
  context: [target users]
  output: .agent/Tasks/[feature]/UX-RESEARCH.md

### 2. Design
@ui-designer
  task: Design [feature] UI
  input: UX research above
  output: .agent/Tasks/[feature]/UI-SPECS.md

### 3. Frontend
@frontend-developer
  task: Implement [feature]
  input: UI specs above
  libs: libs/[scope]/feature-[name]
  output: .agent/Tasks/[feature]/API-REQUIREMENTS.md

### 4. Backend
@backend-architect
  task: Implement [feature] API
  input: API requirements above
  libs: libs/[scope]/data-source

### 5. Quality (after implementation)
@qa-runner
  task: Run full validation
  scope: affected
```

### Bug Fix (Shorter Flow)

```markdown
# Bug: [Description]

@debugger
  task: Investigate root cause
  context: [error details]
  output: Root cause analysis

@coder
  task: Fix bug based on analysis
  input: Debugger findings
  output: Code fix

@test-writer
  task: Add regression test
  context: Bug scenario

@qa-runner
  task: Validate fix
  scope: affected
```

### UI Enhancement (Design → Frontend)

```markdown
# Enhancement: [Description]

@ui-designer
  task: Design improved UI
  context: Current component
  output: UI-SPECS.md

@frontend-developer
  task: Implement UI changes
  input: UI specs
  output: Updated components
```

---

## Handoff File Locations

```
.agent/Tasks/[feature-name]/
├── PRD.md                  # Initial requirements
├── UX-RESEARCH.md          # @ux-researcher output
├── UI-SPECS.md             # @ui-designer output
├── API-REQUIREMENTS.md     # @frontend-developer output
└── IMPLEMENTATION.md       # Final notes
```

---

## Workflow Validation

Before moving to next phase:

```markdown
## Phase Checklist

### After UX Research
- [ ] Personas defined
- [ ] Journey mapped
- [ ] Pain points identified
- [ ] UI implications documented

### After UI Design
- [ ] All components specified
- [ ] States defined (loading, error, empty)
- [ ] Responsive layouts documented
- [ ] Data requirements clear

### After Frontend
- [ ] Components implemented
- [ ] Facade pattern used
- [ ] API contract documented
- [ ] Types match UI needs

### After Backend
- [ ] All endpoints implemented
- [ ] Validation matches frontend needs
- [ ] DTOs implement interfaces
- [ ] Auth configured
```

---

## Error Recovery

If a phase fails or needs revision:

```markdown
## Revision Request

@[previous-agent]
  task: Revise [specific issue]
  context: Feedback from [current-agent]
  changes:
    - [Change 1]
    - [Change 2]
```

The downstream agents will need to re-run after revisions.
