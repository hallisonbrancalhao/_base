# Plans Directory

This directory manages the planning workflow for Claude Code sessions, integrated with the PRD system in `.agent/Tasks/`.

## Structure

```
.agent/Plans/
├── README.md           # This file
├── *.md                # Active plans (current session)
├── archive/            # Archived plans (dated folders)
│   └── YYYY-MM-DD/     # Plans archived by date
│       └── *_TIMESTAMP.md
└── reviews/            # Plan reviews by subagents
    └── *_review_TIMESTAMP.md
```

## Integrated Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PLAN → PRD AUTOMATED WORKFLOW                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  1. USER REQUEST                                                      │
│     └── "Implement feature X"                                         │
│                                                                       │
│  2. ENTER PLAN MODE                                                   │
│     └── Claude enters planning mode                                   │
│     └── Plan written to .agent/Plans/*.md                            │
│                                                                       │
│  3. EXIT PLAN MODE (User approves) ─────────────────────────────┐    │
│                                                                  │    │
│     ┌────────────────────────────────────────────────────────────┤    │
│     │                                                             │    │
│     │  HOOK 1: plan-review.sh                                     │    │
│     │  └── Architecture compliance check                          │    │
│     │  └── Code quality analysis                                  │    │
│     │  └── Reviews saved to .agent/Plans/reviews/                │    │
│     │                                                             │    │
│     │  HOOK 2: plan-to-prd.sh  ← NEW                             │    │
│     │  └── Extracts feature name, scope, complexity               │    │
│     │  └── Generates PRD from template                            │    │
│     │  └── PRD saved to .agent/Tasks/PRD-YYYY-MM-###_name.md     │    │
│     │                                                             │    │
│     │  HOOK 3: archive-plan.sh                                    │    │
│     │  └── Moves plan to .agent/Plans/archive/YYYY-MM-DD/        │    │
│     │  └── Preserves context for reference                        │    │
│     │                                                             │    │
│     └────────────────────────────────────────────────────────────┘    │
│                                                                       │
│  4. IMPLEMENTATION                                                    │
│     └── Follow generated PRD in .agent/Tasks/                        │
│     └── PRD tracks progress, acceptance criteria                      │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

## Hooks Configuration

Located in `.claude/settings.json`:

| Hook | Trigger | Purpose |
|------|---------|---------|
| `plan-review.sh` | ExitPlanMode | Reviews plan for architecture compliance |
| `plan-to-prd.sh` | ExitPlanMode | Converts plan to PRD format |
| `archive-plan.sh` | ExitPlanMode | Archives plan to dated folder |
| `pre-implementation-check.sh` | UserPromptSubmit | Detects implementation intent |

## PRD Generation

When a plan is converted to PRD:

1. **Feature Name**: Extracted from plan title or first heading
2. **Scope**: Detected from lib paths or `scope:` mentions
3. **Complexity**: Estimated from word count and file mentions
4. **PRD ID**: Auto-generated as `PRD-YYYY-MM-###`

The generated PRD includes:
- AI Context Block (YAML metadata)
- Original plan content (collapsed)
- Definition of Done checklist
- Test plan template

## Manual Commands

### Force Review
```bash
.claude/hooks/plan-review.sh
```

### List Archived Plans
```bash
ls -la .agent/Plans/archive/
```

### Search Plans
```bash
grep -r "feature-name" .agent/Plans/archive/
```

### View Generated PRDs
```bash
ls -la .agent/Tasks/PRD-*.md
```

## Best Practices

### Writing Plans for Good PRD Generation

Include in your plans:
- Clear title with feature name (e.g., `# Feature: User Authentication`)
- Scope reference (e.g., `scope: auth` or `libs/auth/`)
- File paths you'll create/modify
- Acceptance criteria

Example plan structure:
```markdown
# Feature: User Profile Settings

## Scope
- Scope: user
- Type: feature

## Implementation Plan
1. Create libs/user/feature-settings/
2. Add UserSettingsComponent
3. Integrate with UserFacade

## Files to Create
- libs/user/feature-settings/src/lib/pages/settings-page.component.ts
- libs/user/data-access/src/lib/facades/user-settings.facade.ts

## Acceptance Criteria
- [ ] User can view profile settings
- [ ] User can update email/password
- [ ] Changes persist after refresh
```

## Integration with Templates

The PRD generation follows the template defined in:
- `.agent/Tasks/README.md` - Full PRD template
- `.agent/SOPs/templates_de_prompt.md` - Prompt templates reference

Generated PRDs are ready for:
- AI agent implementation (structured YAML context)
- Progress tracking (Definition of Done)
- Code review verification
