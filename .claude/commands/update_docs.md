# When asked to update documentation

You are an expert code documentation expert. Your goal is to do deep scan & analysis to provide super accurate & up to date documentation of the codebase to make sure new engineers and AI assistants have full context.

## **Project Documentation Structure**

This project maintains documentation in two places:

### 1. `.agent/` - Complete Documentation (for devs + AI context)
- **QUICK_START.md**: Quick start guide for developers (Portuguese, user-friendly)
- **README.md**: Main index of all documentation
- **Tasks/**: PRD & implementation plans for features (optional, local/personal)
- **System/**: Current state documentation (architecture, tech stack, guides, references)
- **SOPs/**: Standard Operating Procedures (templates, git conventions, how-tos)

### 2. `.ruler/` - AI Rules (generates CLAUDE.md)
- **RULES.md**: Core rules pointing to `.agent/` documentation
- **AGENT_DOCUMENTATION_STRUCTURE.md**: How to use `.agent/` folder
- **DOCUMENTATION_WORKFLOW.md**: When/how to update docs
- **DARK_MODE_GUIDE.md**: Complete dark mode technical guide

**Note**: `.ruler/` files are CONCISE and REFERENCE `.agent/` for details. Never duplicate content.

---

## **Current Documentation State**

### Available Now (16 docs - 76% coverage)
- ✅ QUICK_START.md (Portuguese, for developers)
- ✅ System/project_overview.md
- ✅ System/angular_best_practices.md
- ✅ System/angular_unit_testing_guide.md
- ✅ System/angular_reference.md
- ✅ System/jest_reference.md
- ✅ System/dark_mode_reference.md
- ✅ System/nx_architecture_rules.md
- ✅ SOPs/templates_de_prompt.md (9 templates)
- ✅ SOPs/git_commit_instructions.md
- ✅ Tasks/README.md (PRD template)
- ✅ Tasks/EXAMPLE_fix_process_form_validation_bug.md

### Planned (5 docs)
- 🔜 System/project_architecture.md
- 🔜 System/nx_structure.md
- 🔜 System/graphql_schema.md
- 🔜 System/features_overview.md
- 🔜 System/tech_stack.md

---

## **Project Context (Important)**

- **Framework**: Angular 18+ (standalone components, signals)
- **Monorepo**: Nx workspace
- **UI**: PrimeNG v18 (Aura theme) + Tailwind CSS v3
- **Dark Mode**: PrimeNG + Tailwind (`.p-dark` class)
- **API**: BFF REST + External API REST.
- **Testing**: Jest (unit) + Cypress (E2E)
- **Language**: TypeScript
- **Main Branch**: develop
- **Documentation Language**:
  - Portuguese for user-facing docs (QUICK_START.md, templates)
  - English for technical/AI context docs (System/, SOPs/)

**Do NOT document**:
- ❌ Database schema (doesn't exist - uses external GraphQL API)
- ❌ Backend (frontend-only project)
- ❌ LLM layer (not applicable)

---

## # When asked to INITIALIZE documentation

### Step 1: Deep Scan
- Read `.agent/README.md` first to understand current structure
- Scan codebase to understand:
  - Nx workspace structure (apps/, libs/)
  - Angular components, services, modules
  - Domains and features entities
  - Routing structure
  - Testing setup

### Step 2: Create Core Documentation
Create/update in this priority order:

**High Priority:**
1. `System/project_architecture.md` - Nx + Angular architecture overview
2. `System/nx_structure.md` - Detailed apps and libs structure
3. `System/graphql_schema.md` - GraphQL queries, mutations, types
4. `System/tech_stack.md` - Complete dependencies and versions

**Medium Priority:**
5. `System/features_overview.md` - All implemented features
6. `SOPs/how_to_add_new_feature.md` - Step-by-step feature guide
7. `SOPs/how_to_create_new_library.md` - Nx library creation

**Low Priority:**
8. `SOPs/how_to_run_tests.md` - Jest + Cypress guide
9. `SOPs/how_to_build_and_deploy.md` - Build + Docker + AWS

### Step 3: Update Indexes
- Update `.agent/README.md` with all new docs
- Update `.agent/System/README.md` if System/ docs added
- Update `.agent/SOPs/README.md` if SOPs added
- Update version number and statistics

### Step 4: Consolidation Rules
- ✅ Merge related content into single file when possible
- ✅ Use cross-references instead of duplicating
- ✅ Keep QUICK_START.md focused on essentials
- ❌ Don't create separate docs for small topics
- ❌ Don't duplicate information between `.agent/` and `.ruler/`

---

## # When asked to UPDATE documentation

### Step 1: Read Current State
1. Read `.agent/README.md` to understand what exists
2. Identify which document(s) need updating:
   - New feature → `System/features_overview.md` + create PRD in `Tasks/`
   - Architecture change → `System/project_architecture.md`
   - New library → `System/nx_structure.md`
   - New dependency → `System/tech_stack.md`
   - GraphQL change → `System/graphql_schema.md`
   - New procedure → Create SOP in `SOPs/`
   - Dark Mode → `.ruler/DARK_MODE_GUIDE.md` (then update `System/dark_mode_reference.md`)
   - Angular rules → `System/angular_best_practices.md`
   - Testing rules → `System/angular_unit_testing_guide.md`

### Step 2: Decision Matrix

| Change Type | Update Where | Priority |
|------------|--------------|----------|
| **New feature** | System/features_overview.md + Tasks/[name].md | High |
| **Architecture** | System/project_architecture.md | High |
| **New lib** | System/nx_structure.md | High |
| **New dependency** | System/tech_stack.md | High |
| **GraphQL schema** | System/graphql_schema.md | High |
| **Dark Mode** | .ruler/DARK_MODE_GUIDE.md + System/dark_mode_reference.md | Medium |
| **New component** | Maybe System/features_overview.md | Low |
| **New procedure** | Create SOPs/[name].md | Medium |
| **Bug fix** | Usually don't document | N/A |

### Step 3: Update Files
- Update identified documentation file(s)
- Keep changes focused and accurate
- Add examples when helpful
- Update "Last update" date at bottom

### Step 4: Update Indexes
- Always update `.agent/README.md` with:
  - New documents in "Available documents" sections
  - Updated statistics (total docs, coverage %)
  - Version number (if significant change)
- Update subfolder README if needed (System/README.md, SOPs/README.md)

### Step 5: Maintain Consistency
- Use same formatting/structure as existing docs
- Follow markdown conventions
- Use relative links
- Include metadata at bottom (Last update, Version)

---

## # When CREATING new doc files

### Required Sections
Every new document should include:

```markdown
# [Title]

**Last update**: YYYY-MM-DD
**Version**: 1.0.0

---

## 📌 Summary

[Brief description]

---

## [Main Content Sections]

...

---

## 📚 References

### Related Documentation
- [Link to related doc 1]
- [Link to related doc 2]

### External Resources
- [External link if applicable]

---

**Last update**: YYYY-MM-DD
**Version**: 1.0.0
```

### Naming Conventions
- Use snake_case: `project_architecture.md`
- Be descriptive: `how_to_add_new_feature.md`
- Language-specific prefix optional: `templates_de_prompt.md` (Portuguese)

### Content Guidelines
- ✅ Use Portuguese for user-facing docs (QUICK_START, templates)
- ✅ Use English for technical/AI context docs
- ✅ Include practical examples
- ✅ Add code snippets when helpful
- ✅ Cross-reference related docs
- ✅ Keep it concise but complete
- ❌ Don't duplicate content from other docs
- ❌ Don't create docs for trivial topics

---

## # Special Cases

### Updating QUICK_START.md
- Keep it simple and direct
- Focus on what developers need immediately
- Link to detailed docs, don't duplicate content
- Use Portuguese (simple, friendly language)
- Include practical examples from the project

### Updating Dark Mode Documentation
1. Update `.ruler/DARK_MODE_GUIDE.md` (complete technical guide)
2. Update `System/dark_mode_reference.md` (reference for AI)
3. Update `QUICK_START.md` if rules changed (user-facing)
4. Update Template 8 in `SOPs/templates_de_prompt.md` if needed

### Creating PRDs (Tasks/)
- Use template from `Tasks/README.md`
- PRDs are OPTIONAL (only for large features >1 day)
- PRDs can be LOCAL/PERSONAL (git ignores `feat_*.md`, `fix_*.md`, etc.)
- See `Tasks/EXAMPLE_fix_process_form_validation_bug.md` for reference

### Updating Rules (.ruler/)
- `.ruler/` files are CONCISE and REFERENCE `.agent/`
- Don't duplicate content from `.agent/` in `.ruler/`
- After updating `.ruler/*.md`, run `ruler` to regenerate `CLAUDE.md`
- See `.ruler/README.md` for workflow

---

## # Final Checklist

When updating documentation:
- [ ] Read `.agent/README.md` first
- [ ] Identified correct file(s) to update
- [ ] Updated content with accurate information
- [ ] Added examples if helpful
- [ ] Updated "Last update" date
- [ ] Updated `.agent/README.md` indexes
- [ ] Updated statistics if applicable
- [ ] Maintained consistent formatting
- [ ] Cross-referenced related docs
- [ ] Tested all links work
- [ ] No duplicate content between files
- [ ] Followed language convention (PT for users, EN for technical)

---

**Remember**: Good documentation is maintained documentation. Keep it updated, accurate, and concise.
