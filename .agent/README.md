# .agent - AI Assistant Documentation Hub

> **Read this file completely before starting any task.**

---

## Quick Context

```yaml
project: "@base/source"
type: Nx Monorepo
package_manager: pnpm

stack:
  frontend: Angular 21+ (Standalone, Signals)
  backend: NestJS 11+
  ui: PrimeNG 21+
  css: Tailwind 4+
  test: Jest 30+
```

---

## Folder Structure

```
.agent/
├── README.md          ← YOU ARE HERE
├── Agents/            ← Agent configs & code standards
├── System/            ← Technical documentation
├── Tasks/             ← PRDs & implementation plans
└── SOPs/              ← Standard procedures
```

---

## Required Reading

### P0 - Architecture (Always Read First)

| Document | Purpose |
|----------|---------|
| [TypeScript Clean Code](./System/typescript_clean_code.md) | Naming, functions, comments policy |
| [Nx Architecture Rules](./System/nx_architecture_rules.md) | Lib dependencies & boundaries |
| [Libs Architecture](./System/libs_architecture_pattern.md) | Scope/Lib structure |
| [Interface-DTO Patterns](./System/interface-dto-architecture.md) | DTO conventions |
| [Barrel Best Practices](./System/barrel_best_practices.md) | Export rules |

### P1 - Framework Patterns (Before Writing Code)

| Document | Purpose |
|----------|---------|
| [Angular Full Guide](./System/angular_full.md) | Angular 21+ patterns |
| [PrimeNG Best Practices](./System/primeng_best_practices.md) | UI components |
| [Barrel Best Practices](./System/barrel_best_practices.md) | Export rules |

### P2 - Styling & Testing (For UI Work)

| Document | Purpose |
|----------|---------|
| [Dark Mode Reference](./System/dark_mode_reference.md) | Theme colors |
| [Responsive Design](./System/responsive_design_guide.md) | Breakpoints |
| [Unit Testing Guide](./System/angular_unit_testing_guide.md) | Test patterns |

### P3 - Procedures (Before Commits)

| Document | Purpose |
|----------|---------|
| [Git Commit Instructions](./SOPs/git_commit_instructions.md) | Commit format |
| [PRD Template](./Tasks/README.md) | Feature documentation |

---

## Critical Rules (Quick Reference)

### TypeScript
- Max **5 statements** per function
- Max **3 parameters** per function
- **Self-documenting names** (no obvious comments)
- **Strict mode** always enabled

### Angular
- **Standalone components** (NO NgModules)
- **Signals** for state (NO BehaviorSubject)
- **@if/@for** (NO *ngIf/*ngFor)
- **input()/output()** (NO decorators)
- **inject()** (NO constructor injection)

### PrimeNG
- **p-button, p-select, p-inputtext** (components)
- **#templateName** for templates
- NO pButton, pDropdown, pTemplate directives

### Styling
- **surface-0 to surface-950** for colors
- **dark:** prefix for dark mode
- NO Tailwind gray-* colors

---

## Task Workflow

```
1. Read relevant System/ docs
2. Check/Create PRD in Tasks/
3. Implement following patterns
4. Verify: nx affected:lint && nx affected:test
5. Commit following SOPs/git_commit_instructions.md
```

---

## Quick Commands

```bash
# Development
pnpm start                          # Serve web + api

# Verification (run before commit)
pnpm nx affected:lint --base=main
pnpm nx affected:test --base=main
pnpm nx affected:build --base=main

# Generate libs
pnpm nx g @nx/angular:lib [name] --directory=[scope] --standalone
```

---

## Pre-Commit Checklist

- [ ] Lint passes
- [ ] Tests pass
- [ ] Build passes
- [ ] Public API exported in `index.ts`
- [ ] No forbidden imports
- [ ] Commit message follows convention

---

**Last Updated**: 2026-01-28
