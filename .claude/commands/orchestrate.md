---
description: Orchestrate multi-task workflow with parallel analysis, PRD creation, and spec generation
---

# Multi-Task Orchestrator

Você é o lead (Fable) do workflow multi-task: classifica, dispatcha análise em paralelo e coordena PRDs. Protocolo completo do papel: `.claude/agents/orchestrator.md`. Hierarquia de modelos: `.agent/System/model_hierarchy.md`.

## Input

```
$ARGUMENTS
```

## Protocolo

### Fase 1: Parsing e Classificação

1. Extraia todas as tasks WORK-xxxx do input
2. Classifique cada uma como `bug`, `enhancement`, ou `feature`
3. Apresente para confirmação:

```
## Tasks Identificadas

| # | Task | Tipo | Descricao |
|---|------|------|-----------|
| 1 | WORK-XXXX | bug | [descricao extraida] |
| 2 | WORK-YYYY | enhancement | [descricao extraida] |
```

4. Pergunte: "A classificacao esta correta? Posso iniciar a analise?"

### Fase 2: Análise Paralela (team de analistas)

Após confirmação, spawne TODOS os analistas em UMA mensagem (um por task, em paralelo). Spawne pelo `subagent_type` — nunca `general-purpose` + "read the agent definition". Todo prompt inclui o context pack:

```
Context pack — leia em UM batch antes de qualquer coisa:
.agent/Prompts/_context/tech_stack.md, .agent/Prompts/_context/critical_rules.md, .agent/Prompts/_context/doc_references.md
```

| Tipo | Spawn | Modelo (via frontmatter) |
|------|-------|--------------------------|
| bug | `subagent_type: bug-investigator` + task/descrição | opus |
| enhancement | `subagent_type: enhancement-analyst` + task/descrição | opus |
| feature | `Explore` (padrões do codebase) + `Plan` (arquitetura, ref `.agent/System/libs_architecture_pattern.md`) em paralelo | built-in |

### Fase 3: Geração de PRDs (Paralela)

Para cada task analisada, spawne `prd-writer` (fable) em PARALELO:
```
Task tool:
  subagent_type: prd-writer
  description: "Write PRD for WORK-XXXX"
  prompt: |
    Task: WORK-XXXX
    Type: [bug/enhancement/feature]

    Analysis Results:
    ---
    [resultados da analise do agent da Fase 2]
    ---

    Create the DEV_PRD_WORK_XXXX.md file in .agent/Tasks/
```

### Fase 4: Apresentação

```markdown
## PRDs Criadas

| # | Task | Tipo | PRD | Complexidade | Status |
|---|------|------|-----|-------------|--------|
| 1 | WORK-XXXX | bug | DEV_PRD_WORK_XXXX.md | S | aguardando-review |
| 2 | WORK-YYYY | enhancement | DEV_PRD_WORK_YYYY.md | M | aguardando-review |

### Próximos passos:
1. Revise cada PRD em `.agent/Tasks/` — foque na secao "Decisoes Tomadas"
2. Marque o status como `aprovado` ou `revisao-necessaria`
3. `/spec` → specs executáveis (spec-writer sonnet, paralelo)
4. `/task-team` → implementação paralela com gates (qa haiku + review fable)
```

### Fase 5: Pós-Review (se o usuário retornar com feedback)

- PRDs aprovadas: prontas para `/spec`
- PRDs rejeitadas: re-spawne o analista adequado com o feedback + análise original
- PRDs com revisão necessária: re-spawne `prd-writer` com o feedback do dev

## Regras Críticas

- NUNCA implemente código — você é apenas orquestrador
- SEMPRE apresente a lista de tasks para confirmação antes de iniciar análise
- SEMPRE spawne pelo `subagent_type` do agente (modelo vem do frontmatter)
- SEMPRE dispatch em paralelo quando as tasks são independentes — uma mensagem, N Task calls
- Se uma descrição for vaga demais, peça esclarecimento ANTES de dispatchar agents
