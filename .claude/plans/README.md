# Plans Directory

This directory manages the planning workflow for Claude Code sessions.

## Structure

```
plans/
├── README.md           # This file
├── *.md                # Active plans (current session)
├── archive/            # Archived plans (dated folders)
│   └── YYYY-MM-DD/     # Plans archived by date
│       └── *_TIMESTAMP.md
└── reviews/            # Plan reviews by subagents
    └── *_review_TIMESTAMP.md
```

## Workflow

### 1. Planning Phase
- Claude enters plan mode (`EnterPlanMode`)
- Plan is written to `plans/*.md`
- Plan remains active during planning

### 2. Pre-Implementation Review
- When implementation is requested, `pre-implementation-check.sh` detects active plans
- Suggests using subagents for review:
  - `@arch-validator` - Architecture compliance
  - `@code-reviewer` - Code quality analysis
- Reviews are saved to `reviews/`

### 3. Plan Archival
- When Claude exits plan mode (`ExitPlanMode`)
- `archive-plan.sh` automatically archives plans
- Plans moved to `archive/YYYY-MM-DD/` with timestamp
- Context preserved for future reference

## Hooks

| Hook | Trigger | Action |
|------|---------|--------|
| `pre-implementation-check.sh` | Implementation detected | Suggests plan review |
| `plan-review.sh` | Manual/headless | Runs subagent analysis |
| `archive-plan.sh` | ExitPlanMode | Archives plans to dated folder |

## Manual Review

Run headless plan review:
```bash
.claude/hooks/plan-review.sh
```

## Finding Archived Plans

```bash
# List recent archives
ls -la .claude/plans/archive/

# Find plans by date
ls .claude/plans/archive/2025-01-*/

# Search archived plans
grep -r "feature-name" .claude/plans/archive/
```
