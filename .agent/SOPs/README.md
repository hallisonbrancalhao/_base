# SOPs - Standard Operating Procedures

This folder contains standard procedures for executing common tasks in the Microfront Workflow project.

## 📋 What are SOPs?

SOPs (Standard Operating Procedures) are step-by-step guides to:
- ✅ Execute repetitive tasks consistently
- ✅ Onboard new developers
- ✅ Reduce errors in critical processes
- ✅ Document established best practices
- ✅ Facilitate future automation

## 🎯 When to Use SOPs?

Use SOPs when you need to:
- ✅ Add new feature/library
- ✅ Build and deploy
- ✅ Run tests (unit, E2E)
- ✅ Update documentation
- ✅ Solve common problems
- ✅ Configure development environment

## 📂 Available SOPs

### ✅ `git_commit_instructions.md`
**Status**: Available

**Covers**:
1. Conventional commits specification
2. Commit format and structure
3. Valid commit types (feat, fix, docs, etc.)
4. Examples of good and bad commits
5. Automatic validation with commitlint

**When to use**: Every time you make a commit

---

### ✅ `how_to_use_agent_structure_with_ai.md`
**Status**: Available ⭐ NEW

**Covers**:
1. Complete workflow for using `.agent/` structure with AI assistants
2. Step-by-step guide with real bug fix example
3. Creating PRDs/Tasks for bugs and features
4. Writing effective prompts for AI
5. Executing parallel agents for complex tasks
6. Testing, documentation, and verification

**When to use**: When working with AI assistants (Claude Code) on bugs, features, or investigations

**Real Example Included**: Process form validation bug fix from process-detail-container.component.ts

---

### ✅ `ai_prompt_templates.md`
**Status**: Available ⭐ NEW

**Covers**:
1. Ready-to-use prompt templates for common tasks
2. Bug fix templates (simple and complex)
3. Feature implementation templates (small and large)
4. Testing, refactoring, and code review templates
5. Investigation and understanding templates
6. Quick copy-paste snippets

**When to use**: Before prompting AI - copy appropriate template and fill in your details

**Templates Included**:
- 🐛 Bug Fix (Simple)
- 🐛 Bug Fix (Complex - Parallel)
- ✨ New Feature (Small)
- ✨ New Feature (Complex - Parallel)
- 🧪 Add Tests
- 🔄 Refactor Code
- 📚 Code Review
- 🔍 Investigate/Understand Code

---

### 🔜 `how_to_add_new_feature.md`
**Status**: Planned

**Covers**:
1. Plan the feature (create PRD)
2. Create lib structure in Nx
3. Implement following Angular conventions
4. Write tests (Jest + Cypress)
5. Code review
6. Deploy

**When to use**: Always when starting new feature implementation

---

### 🔜 `how_to_create_new_library.md`
**Status**: Planned

**Covers**:
1. Decide library type (api, data-access, features, ui, shell)
2. Use Nx generators
3. Configure exports
4. Add to project graph
5. Update documentation

**When to use**: When creating new lib in Nx monorepo

---

### 🔜 `how_to_run_tests.md`
**Status**: Planned

**Covers**:
1. Unit tests with Jest
2. E2E tests with Cypress
3. Coverage reports
4. Test debugging
5. CI/CD test pipeline
6. Testing conventions (follow ANGULAR_UNIT_TESTING_GUIDE.md)

**When to use**: When developing, before commit, in CI/CD

---

### 🔜 `how_to_build_and_deploy.md`
**Status**: Planned

**Covers**:
1. Local build (development, production)
2. Build with Docker
3. Deploy to staging
4. Deploy to production (AWS)
5. Rollback in case of problems
6. Post-deploy verification

**When to use**: When making release, deploying

---

### 🔜 `how_to_update_documentation.md`
**Status**: Planned

**Covers**:
1. When to update docs
2. Which documents to update
3. How to update System/, Tasks/, SOPs/
4. Documentation versioning
5. Documentation review

**When to use**: After implementing feature, architectural change

---

### 🔜 `how_to_troubleshoot_common_issues.md`
**Status**: Planned

**Covers**:
1. Build problems
2. Test problems
3. Dependency problems
4. GraphQL problems
5. Nx cache problems

**When to use**: When encountering common error, troubleshooting

---

### 🔜 `how_to_do_code_review.md`
**Status**: Planned

**Covers**:
1. Code review checklist
2. Verify compliance with CLAUDE.md
3. Verify tests
4. Verify performance
5. Approve/request changes

**When to use**: When reviewing PRs

---

### 🔜 `how_to_setup_environment.md`
**Status**: Planned

**Covers**:
1. Dependencies installation
2. IDE configuration (VS Code)
3. Git hooks configuration (Husky)
4. ESLint/Prettier configuration
5. GraphQL codegen configuration
6. Environment variables

**When to use**: First setup, new developer

---

## 📝 Template for New SOPs

When creating a new SOP, use the structure below:

```markdown
# How to [Do Something] - SOP

**Last update**: YYYY-MM-DD
**Version**: X.Y.Z
**Owner**: Name
**Estimated time**: XX minutes

---

## 📌 Objective

[Brief description of what this SOP teaches]

---

## 🎯 Prerequisites

- [ ] Prerequisite 1
- [ ] Prerequisite 2
- [ ] Prerequisite 3

---

## 🚀 Step by Step

### Step 1: [Step Name]

**Description**: [What to do in this step]

**Commands**:
```bash
# Command here
```

**Expected result**: [What should happen]

**Troubleshooting**:
- Problem X → Solution Y

---

### Step 2: [Step Name]

...

---

## ✅ Final Verification

After completing all steps, verify:
- [ ] Verification 1
- [ ] Verification 2
- [ ] Verification 3

---

## ⚠️ Common Problems

### Problem 1
**Symptom**: [Problem description]
**Cause**: [Why it happens]
**Solution**: [How to solve]

### Problem 2
...

---

## 📚 References

- [Link to related doc]
- [Link to tool]

---

## 📝 Additional Notes

[Important notes, tips, warnings]

---

**Last update**: YYYY-MM-DD
**Version**: X.Y.Z
```

---

## 🔄 SOP Creation Workflow

```
1. Identify repetitive/important task
   ↓
2. Execute task documenting each step
   ↓
3. Create SOP using template
   ↓
4. Test SOP with new person
   ↓
5. Adjust based on feedback
   ↓
6. Publish SOP (commit)
   ↓
7. Update this README
```

---

## 📊 Statistics

- **Total SOPs**: 3
- **Planned SOPs**: 8
- **SOPs in creation**: 0
- **Ready SOPs**: 3 (git_commit_instructions, how_to_use_agent_structure_with_ai, ai_prompt_templates)
- **Last general update**: 2025-10-10

---

## 🎯 Creation Priorities

### High Priority (create first)
1. [ ] `how_to_add_new_feature.md`
2. [ ] `how_to_run_tests.md`
3. [ ] `how_to_setup_environment.md`

### Medium Priority
4. [ ] `how_to_create_new_library.md`
5. [ ] `how_to_update_documentation.md`
6. [ ] `how_to_do_code_review.md`

### Low Priority
7. [ ] `how_to_build_and_deploy.md`
8. [ ] `how_to_troubleshoot_common_issues.md`

---

## 🤝 Contributing

### Create New SOP
1. Identify task that needs SOP
2. Execute task documenting each step
3. Use template above
4. Test with someone who doesn't know the task
5. Adjust based on feedback
6. Commit: `docs: add SOP for [task name]`
7. Update this README

### Update Existing SOP
1. Identify needed improvement/correction
2. Update document
3. Increment version (patch/minor/major)
4. Commit: `docs: update SOP [task name]`

---

## 📚 References

### Project Documentation
- [.agent/README.md](../README.md) - Main .agent folder README
- [CLAUDE.md](../../CLAUDE.md) - Rules and conventions
- [ANGULAR_UNIT_TESTING_GUIDE.md](../../ANGULAR_UNIT_TESTING_GUIDE.md) - Testing guide
- [Tasks/README.md](../Tasks/README.md) - PRDs and features
- [System/README.md](../System/README.md) - System documentation

### Tools
- [Nx CLI](https://nx.dev/nx-api/nx/documents/run)
- [Angular CLI](https://angular.dev/cli)
- [Jest CLI](https://jestjs.io/docs/cli)
- [Cypress CLI](https://docs.cypress.io/guides/guides/command-line)

---

## 💡 Tips

### For Developers
- **ALWAYS** follow SOPs for consistency
- **UPDATE** the SOP if you find a better way
- **SHARE** feedback about SOPs
- **CREATE** new SOP if you identify gap

### For AI/Assistants
- **CONSULT** SOPs before executing tasks
- **FOLLOW** steps exactly as documented
- **SUGGEST** improvements to SOPs when identified
- **REFERENCE** SOPs when guiding users

---

**Keep SOPs updated!** Outdated SOPs cause more problems than they help.

---

**Last update**: 2025-10-10
**Version**: 1.0.0
