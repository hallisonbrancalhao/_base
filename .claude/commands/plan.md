---
description: Plan a single task (WORK-xxxx) with context investigation and DEV_PRD creation
---

# Single-Task Planning

Planejamento individual de uma task. Para múltiplas tasks use `/orchestrate`.
Você é o lead (Fable): decide, orquestra e revisa. A investigação é dos agentes opus; a PRD é do `prd-writer` (fable). Hierarquia: `.agent/System/model_hierarchy.md`.

## Input

```
$ARGUMENTS
```

## Protocolo

### Fase 1: Identificar a Task

1. Extraia o WORK-xxxx e a descrição do input
2. Classifique como `bug`, `enhancement`, ou `feature`
3. Confirme com o usuário:

```
Task: WORK-XXXX
Tipo: [bug/enhancement/feature]
Descricao: [resumo]

Correto? Posso iniciar a analise?
```

### Fase 2: Investigação (Paralela)

Spawne pelo `subagent_type` do agente — NUNCA `general-purpose` + "read the agent definition" (isso descarta model/tools/maxTurns do agente). Todo prompt inclui o context pack.

**Para bugs** — `bug-investigator` (opus):
```
Task tool:
  subagent_type: bug-investigator
  description: "Investigate bug WORK-XXXX"
  prompt: |
    Task: WORK-XXXX
    Description: [descricao do bug]

    Context pack — leia em UM batch antes de qualquer coisa:
    .agent/Prompts/_context/tech_stack.md, .agent/Prompts/_context/critical_rules.md, .agent/Prompts/_context/doc_references.md

    Investigate this bug and return a structured analysis following your report format.
```

**Para enhancements** — `enhancement-analyst` (opus):
```
Task tool:
  subagent_type: enhancement-analyst
  description: "Analyze enhancement WORK-XXXX"
  prompt: |
    Task: WORK-XXXX
    Description: [descricao da melhoria]

    Context pack — leia em UM batch antes de qualquer coisa:
    .agent/Prompts/_context/tech_stack.md, .agent/Prompts/_context/critical_rules.md, .agent/Prompts/_context/doc_references.md

    Analyze this enhancement and return a structured analysis following your report format.
```

**Para features** — DOIS agentes em paralelo (mesma mensagem):
```
Task tool (agent 1):
  subagent_type: Explore
  description: "Explore codebase for WORK-XXXX"
  prompt: |
    Explore the codebase to understand patterns relevant to: [descricao da feature]
    Focus on: libs/ structure, existing facades, component patterns, testing patterns
    Return: patterns to follow, files to reference, libs that exist vs need creation

Task tool (agent 2):
  subagent_type: Plan
  description: "Validate architecture for WORK-XXXX"
  prompt: |
    Analyze architecture requirements for: [descricao da feature]
    Reference: .agent/System/libs_architecture_pattern.md and .agent/System/nx_architecture_rules.md
    Return: libs to create with paths, dependencies, tag requirements, potential risks
```

### Fase 3: Geração da DEV_PRD

Spawne `prd-writer` (fable) com os resultados:
```
Task tool:
  subagent_type: prd-writer
  description: "Write PRD for WORK-XXXX"
  prompt: |
    Task: WORK-XXXX
    Type: [bug/enhancement/feature]

    Analysis Results:
    ---
    [resultados da analise da Fase 2]
    ---

    Create the DEV_PRD_WORK_XXXX.md file in .agent/Tasks/
```

### Fase 4: Apresentação

```markdown
## PRD Criada

| Task | Tipo | PRD | Complexidade | Status |
|------|------|-----|-------------|--------|
| WORK-XXXX | [tipo] | DEV_PRD_WORK_XXXX.md | [S/M/L/XL] | aguardando-review |

### Próximos passos:
1. Revise a PRD em `.agent/Tasks/DEV_PRD_WORK_XXXX.md` (foque em "Decisoes Tomadas")
2. Marque o status como `aprovado` no frontmatter
3. `/spec` → gera a spec executável (spec-writer, sonnet)
4. `/task` (1 spec) ou `/task-team` (várias specs em paralelo) → implementer(s) sonnet + gates qa-runner (haiku) e code-reviewer (fable)
```

## Regras

- NUNCA implemente código — apenas planeje
- SEMPRE confirme a classificação da task antes de investigar
- SEMPRE spawne pelo `subagent_type` correto — o modelo vem do frontmatter do agente
- Se a descrição for vaga, peça esclarecimento ANTES de dispatchar agents
