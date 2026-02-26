---
description: Plan a single task (WORK-xxxx) with context investigation and DEV_PRD creation
---

# Single-Task Planning

Planejamento individual de uma task. Versao focada e objetiva — para multiplas tasks use `/orchestrate`.

## Input

```
$ARGUMENTS
```

## Protocolo

### Fase 1: Identificar a Task

1. Extraia o WORK-xxxx e a descricao do input
2. Classifique como `bug`, `enhancement`, ou `feature`
3. Confirme com o usuario:

```
Task: WORK-XXXX
Tipo: [bug/enhancement/feature]
Descricao: [resumo]

Correto? Posso iniciar a analise?
```

### Fase 2: Investigacao (Paralela)

Spawne os agents adequados ao tipo da task em PARALELO:

**Para bugs** — spawne `bug-investigator`:
```
Use Task tool:
  subagent_type: general-purpose
  description: "Investigate bug WORK-XXXX"
  prompt: |
    Read the agent definition at .claude/agents/bug-investigator.md and follow its protocol exactly.

    Task: WORK-XXXX
    Description: [descricao do bug]

    Investigate this bug and return a structured analysis following the report format in the agent definition.
```

**Para enhancements** — spawne `enhancement-analyst`:
```
Use Task tool:
  subagent_type: general-purpose
  description: "Analyze enhancement WORK-XXXX"
  prompt: |
    Read the agent definition at .claude/agents/enhancement-analyst.md and follow its protocol exactly.

    Task: WORK-XXXX
    Description: [descricao da melhoria]

    Analyze this enhancement and return a structured analysis following the report format in the agent definition.
```

**Para features** — spawne TWO agents em paralelo:
```
Use Task tool (agent 1):
  subagent_type: Explore
  description: "Explore codebase for WORK-XXXX"
  prompt: |
    Explore the codebase to understand patterns relevant to: [descricao da feature]
    Focus on: libs/ structure, existing facades, component patterns, testing patterns
    Return: patterns to follow, files to reference, libs that exist vs need creation

Use Task tool (agent 2):
  subagent_type: Plan
  description: "Validate architecture for WORK-XXXX"
  prompt: |
    Analyze architecture requirements for: [descricao da feature]
    Reference: .agent/System/libs_architecture_pattern.md
    Return: libs to create with paths, dependencies, tag requirements, potential risks
```

### Fase 3: Geracao da DEV_PRD

Spawne `prd-writer` com os resultados da analise:
```
Use Task tool:
  subagent_type: general-purpose
  description: "Write PRD for WORK-XXXX"
  prompt: |
    Read the agent definition at .claude/agents/prd-writer.md and follow its protocol exactly.

    Task: WORK-XXXX
    Type: [bug/enhancement/feature]

    Analysis Results:
    ---
    [resultados da analise da Fase 2]
    ---

    Create the DEV_PRD_WORK_XXXX.md file in .agent/Tasks/
```

### Fase 4: Apresentacao

```markdown
## PRD Criada

| Task | Tipo | PRD | Complexidade | Status |
|------|------|-----|-------------|--------|
| WORK-XXXX | [tipo] | DEV_PRD_WORK_XXXX.md | [S/M/L/XL] | aguardando-review |

### Próximos passos:
1. Revise a PRD em `.agent/Tasks/DEV_PRD_WORK_XXXX.md`
2. Foque na secao "Decisoes Tomadas"
3. Marque o status como `aprovado` no frontmatter
4. Execute `/spec` para gerar a spec executável

### Ordem de execucao pos-spec:

1. @nx-operator
   task: Generate libs
   commands: [list from spec]

2. @coder
   task: Implement domain/interfaces
   scope: libs/{scope}/domain

3. @coder
   task: Implement data-access/facades
   scope: libs/{scope}/data-access

4. @coder (or @frontend-developer)
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

## Regras

- NUNCA implemente código — apenas planeje
- SEMPRE confirme a classificacao da task antes de investigar
- SEMPRE use o template `TEMPLATE_dev_prd.md` (via prd-writer agent)
- Se a descricao for vaga, peca esclarecimento ANTES de dispatchar agents
