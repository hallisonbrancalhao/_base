# System Documentation Index

Technical documentation for AI agents and developers.

---

## Quick Navigation

### Architecture (Read First)

| Doc | Purpose | Priority |
|-----|---------|----------|
| [base_rules.md](./base_rules.md) | Fundamental coding rules | P0 |
| [libs_architecture_pattern.md](./libs_architecture_pattern.md) | Nx lib structure (Scope/Lib) | P0 |
| [nx_architecture_rules.md](./nx_architecture_rules.md) | Module boundaries & tags | P0 |
| [typescript_clean_code.md](./typescript_clean_code.md) | Naming, functions, comments | P0 |
| [interface-dto-architecture.md](./interface-dto-architecture.md) | DTO conventions | P0 |
| [barrel_best_practices.md](./barrel_best_practices.md) | Import/export rules | P0 |

### Frontend (Angular)

| Doc | Purpose | When to Read |
|-----|---------|--------------|
| [angular_full.md](./angular_full.md) | Angular 21+ complete guide | Before any Angular work |
| [angular_references.md](./angular_references.md) | Quick Angular reference | During development |
| [angular_unit_testing_guide.md](./angular_unit_testing_guide.md) | Jest + Angular testing | Before writing tests |

### UI Components (PrimeNG)

| Doc | Purpose | When to Read |
|-----|---------|--------------|
| [primeng_best_practices.md](./primeng_best_practices.md) | PrimeNG 21+ patterns | Before UI work |
| [dark_mode_reference.md](./dark_mode_reference.md) | Theme system (surface colors) | For styling |
| [responsive_design_guide.md](./responsive_design_guide.md) | Mobile-first, breakpoints | For layouts |

### Backend (NestJS)

| Doc | Purpose | When to Read |
|-----|---------|--------------|
| [nestjs_reference.md](./nestjs_reference.md) | NestJS 11+ patterns | Before backend work |

### Testing

| Doc | Purpose | When to Read |
|-----|---------|--------------|
| [angular_unit_testing_guide.md](./angular_unit_testing_guide.md) | Component & service tests | Before testing |
| [jest_reference.md](./jest_reference.md) | Jest configuration | For test setup |

### Other

| Doc | Purpose |
|-----|---------|
| [react_native_best_practices.md](./react_native_best_practices.md) | Mobile development (if applicable) |
| [custom_agents.md](./custom_agents.md) | Creating new agents |

---

## Reading Order for New Developers

1. **First**: `base_rules.md` - Understand fundamental rules
2. **Second**: `libs_architecture_pattern.md` - Understand project structure
3. **Third**: `typescript_clean_code.md` - Code style expectations
4. **Then**: Framework-specific docs based on your task

---

## Quick Rules Summary

### TypeScript
- Strict mode always
- Max 5 statements per function
- Max 3 parameters per function
- Self-documenting names

### Angular
- Standalone components only
- Signals for state
- `@if`/`@for` control flow
- `input()`/`output()` functions
- `inject()` for DI

### PrimeNG
- Use components: `p-button`, `p-select`, `p-inputtext`
- Use `#templateName` for templates
- Avoid directives: `pButton`, `pDropdown`, `pTemplate`

### Styling
- Surface colors: `surface-0` to `surface-950`
- Dark mode: `dark:` prefix
- Mobile-first: default → `sm:` → `md:` → `lg:`

### Testing
- Mock all dependencies
- Use `data-testid` for selectors
- Coverage target: 80%

---

## File Sizes Reference

| File | Size | Notes |
|------|------|-------|
| angular_full.md | ~16K lines | Comprehensive - read sections as needed |
| angular_unit_testing_guide.md | ~1.7K lines | Complete testing guide |
| libs_architecture_pattern.md | ~20KB | Core architecture |
| responsive_design_guide.md | ~23KB | Detailed breakpoint guide |

---

**Last Updated**: 2026-01-28
