---
description: Plan a new feature using sub-agents for context investigation and PRD creation
---

# Feature Planning Workflow

You will help plan a new feature by orchestrating specialized sub-agents.

## Planning Pipeline

```
User Request → Context Investigation → PRD Creation → Review → Finalize
```

## Step 1: Context Investigation (Parallel)

Launch these sub-agents **in parallel** to gather context:

### 1.1 Codebase Exploration
```
Use Task tool:
  subagent_type: Explore
  prompt: |
    Explore the codebase to understand:
    1. Existing patterns for similar features
    2. Relevant libs and their structure in libs/{scope}/
    3. Dependencies and imports used
    4. Testing patterns

    Focus areas:
    - libs/ directory structure
    - Existing facades and their patterns
    - Component structure and templates

    Return a summary of:
    - Patterns to follow
    - Files to reference
    - Libs that exist vs need creation
```

### 1.2 Architecture Validation
```
Use Task tool:
  subagent_type: Plan
  prompt: |
    Analyze the architecture requirements for this feature:
    1. Which libs need to be created (domain, data-access, feature-*)
    2. Dependency matrix compliance
    3. Tag requirements (type:*, scope:*)
    4. Import patterns to follow

    Reference: .agent/System/libs_architecture_pattern.md

    Return:
    - Libs to create with full paths
    - Dependencies between libs
    - Potential architecture risks
```

### 1.3 UX Research (if UI feature)
```
Use Task tool:
  subagent_type: general-purpose
  prompt: |
    Read .agent/Agents/design/@ux-researcher.md

    Conduct quick UX research for this feature:
    1. Identify target user persona
    2. Map the user journey
    3. List key pain points to address
    4. Define success metrics

    Keep it concise - 1 persona, 1 journey, 3-5 pain points.
```

## Step 2: PRD Creation

After investigation results, create the PRD:

1. **Read the PRD template**: `.agent/Tasks/README.md`

2. **Fill the AI Context Block** with:
   ```yaml
   feature:
     name: "{feature-name}"
     type: feature
     scope: {scope}
     complexity: S|M|L|XL

   nx_impact:
     libs_to_create:
       - path: "libs/{scope}/domain"
         type: domain
         tags: ["type:domain", "scope:{scope}"]
       - path: "libs/{scope}/data-access"
         type: data-access
         tags: ["type:data-access", "scope:{scope}"]
       - path: "libs/{scope}/feature-{name}"
         type: feature
         tags: ["type:feature", "scope:{scope}"]
   ```

3. **Write Functional Requirements** from investigation findings

4. **Define API contracts** (if backend involved)

5. **Set Definition of Done** criteria

## Step 3: Plan Review (Parallel)

Launch review agents **in parallel**:

### 3.1 Code Quality Review
```
Use Task tool:
  subagent_type: general-purpose
  prompt: |
    Read .agent/Agents/quality/@code-reviewer.md

    Review this PRD for code quality concerns:
    - Single Responsibility adherence
    - Component complexity estimation
    - Test coverage feasibility
    - Potential security issues

    PRD Content:
    {prd_content}

    Return: List of concerns with severity (critical/warning/info)
```

### 3.2 Architecture Review
```
Use Task tool:
  subagent_type: general-purpose
  prompt: |
    Read .agent/Agents/quality/@arch-validator.md

    Validate PRD architecture:
    - Nx lib structure compliance
    - Dependency matrix violations
    - Facade pattern usage
    - Import patterns (direct vs barrel)

    PRD Content:
    {prd_content}

    Return: List of architecture issues with recommendations
```

## Step 4: Finalize

1. **Incorporate review feedback** into the PRD

2. **Generate PRD filename**:
   ```
   PRD-YYYY-MM-###_{feature_name}.md
   ```

3. **Write PRD** to `.agent/Tasks/`

4. **Create plan summary** in `.agent/Plans/` (Claude's native plan mode will archive this)

5. **Return next steps**:
   - Which agents to invoke for implementation
   - Order of execution
   - Estimated complexity

## Output

The planning workflow produces:

### PRD File
Location: `.agent/Tasks/PRD-YYYY-MM-###_{feature_name}.md`

### Next Steps
```markdown
## Implementation Workflow

Execute agents in order:

1. @nx-operator
   task: Generate libs
   commands: [list from PRD]

2. @coder
   task: Implement domain/interfaces
   scope: libs/{scope}/domain

3. @coder
   task: Implement data-access/facades
   scope: libs/{scope}/data-access

4. @coder (or @frontend-developer / @backend-architect)
   task: Implement feature components
   scope: libs/{scope}/feature-{name}

5. @test-writer
   task: Write unit tests
   target: All new code

6. @qa-runner
   task: Validate
   checks: lint, test, build

7. @git-operator
   task: Commit changes
```

---

**Start by describing the feature you want to plan.**
