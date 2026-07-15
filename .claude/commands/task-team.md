---
description: Launch Agent Teams to implement multiple SPEC files in parallel with independent teammates
---

# Task Team — Implementação Paralela com Agent Teams

Você é o lead (Fable): monta o team, monitora, integra e revisa. Quem implementa são teammates `implementer` (sonnet), um por spec, em worktrees isolados. Gates finais: `qa-runner` (haiku) e `code-reviewer` (fable). Hierarquia: `.agent/System/model_hierarchy.md`.

> O team é implícito na sessão — NÃO existe TeamCreate/TeamDelete. Teammates são spawnados via Task/Agent tool com `name`, e coordenados pela task list compartilhada (TaskCreate/TaskList) + SendMessage.

## Input

```
$ARGUMENTS
```

## Protocolo

### Fase 1: Descoberta de Specs

1. Liste `SPEC_WORK_*.md` em `.agent/Tasks/` e leia o frontmatter de cada
2. Filtre `status: pending` (ou as specs passadas em $ARGUMENTS)
3. Se nenhuma pendente, sugira `/orchestrate` + `/spec` primeiro

```markdown
## Specs Disponiveis

| #   | Spec              | Task      | Tipo        | Branch                 | Base    |
| --- | ----------------- | --------- | ----------- | ---------------------- | ------- |
| 1   | SPEC_WORK_1234.md | WORK-1234 | bug         | feature/WORK-1234-nome | master  |
```

Pergunte: "Quais specs deseja implementar em paralelo? (todas / numeros / cancelar)"

**1 spec selecionada → use `/task`** (sem overhead de team). Team é para ≥ 2.

### Fase 2: Análise de Conflitos → Dependências

1. Leia cada spec selecionada por completo
2. Extraia "Arquivos a Criar" e "Arquivos a Modificar" e cruze os paths
3. Specs que tocam o mesmo arquivo NÃO saem do team — viram cadeia sequencial via `blockedBy` (o implementer espera bloqueadores no startup):

```markdown
## Conflitos → Dependências

| Arquivo                       | Specs                          | Resolução                    |
| ----------------------------- | ------------------------------ | ---------------------------- |
| `libs/shared/data-access/...` | SPEC_WORK_1234, SPEC_WORK_1235 | 1235 blockedBy 1234          |
```

### Fase 3: Criar Tasks na Task List (ANTES de spawnar)

Para cada spec, crie uma task compartilhada com a spec COMPLETA (teammates não herdam o contexto do lead):

```
TaskCreate:
  subject: "WORK-XXXX: [titulo da spec]"
  description: |
    Implemente a spec abaixo seguindo TODAS as instrucoes.

    ## Context pack — leia em UM batch antes de qualquer coisa
    .agent/Prompts/_context/tech_stack.md
    .agent/Prompts/_context/critical_rules.md
    .agent/Prompts/_context/doc_references.md (demais docs: just-in-time)

    ## Spec Completa
    [conteudo completo do SPEC_WORK_XXXX.md]

    ## Finalizacao
    1. npx nx affected:lint/test/build --base=HEAD~1 — tudo verde
    2. Commit convencional: git add [arquivos] && git commit -m "feat(scope): WORK-XXXX descricao"
    3. TaskUpdate → completed; SPEC_WORK_XXXX.md frontmatter → status: done
  activeForm: "Implementing WORK-XXXX"
```

Wire as dependências da Fase 2:

```
TaskUpdate:
  taskId: "[task dependente]"
  addBlockedBy: ["[task prerequisito]"]
```

### Fase 4: Spawnar Teammates (paralelo, uma mensagem)

Um `implementer` por spec. O protocolo completo já está no agent definition — o prompt só aponta a task:

```
Task/Agent tool:
  subagent_type: implementer
  name: "dev-WORK-XXXX"
  isolation: worktree
  prompt: |
    Voce e o teammate "dev-WORK-XXXX". Sua unica missao: a task "WORK-XXXX" na task list compartilhada.
    Siga seu protocolo (startup → implementacao → testes → validacao → commit → completed).
    Bloqueio irrecuperavel → task blocked + SendMessage ao lead.
```

- `isolation: worktree` é OBRIGATÓRIO com ≥ 2 teammates (cada um commita na própria branch/worktree)
- NÃO passe `model` — vem do frontmatter do implementer (sonnet)

### Fase 5: Monitoramento

1. Apresente o team ao usuário (teammate × spec × status)
2. Acompanhe via TaskList; repasse mensagens entre teammates via SendMessage quando necessário
3. Teammate bloqueado → avalie: outro teammate resolve? Falta decisão humana? Re-spawn com contexto extra?
4. Implementer que falhar validação 2× → escale UM tier (sonnet→opus) re-spawnando com o histórico do erro

### Fase 6: Integração (worktrees → branch base)

Quando todas as tasks estiverem `completed`:

1. Liste as branches dos worktrees (`git branch --list` / output dos teammates)
2. Merge na branch base NA ORDEM das dependências da Fase 2
3. Conflito trivial (imports, barrel) → resolva você mesmo; conflito de lógica → devolva ao implementer da spec mais recente
4. QA agregado do sprint via `qa-runner` (haiku):

```
Task tool:
  subagent_type: qa-runner
  description: "Sprint QA"
  prompt: |
    Run the affected pipeline against base [branch base do sprint].
    Report failures per project. Do not fix anything.
```

Falhas → devolva ao implementer responsável (re-spawn com o QA report), depois repita o QA.

### Fase 7: Review Gate (fable)

Com QA verde, spawne `code-reviewer` sobre o diff agregado:

```
Task tool:
  subagent_type: code-reviewer
  description: "Sprint review"
  prompt: |
    Review the aggregated sprint diff: git diff [base]...HEAD
    Specs implemented: WORK-XXXX, WORK-YYYY
    Return verdict + findings by severity.
```

- `REQUEST_CHANGES` (critical/high) → reabra a task e re-spawne o implementer com os findings
- `APPROVE` → prossiga

### Fase 8: Encerramento

1. SendMessage `shutdown_request` para cada teammate finalizado
2. Confirme specs com `status: done` e apresente:

```markdown
## Sprint Concluido

| Spec              | Status  | Commit                     | QA | Review |
| ----------------- | ------- | -------------------------- | -- | ------ |
| SPEC_WORK_1234.md | done    | feat(scope): WORK-1234 ... | ✅ | ✅     |

### Proximos passos:
- Specs done: prontas para PR (/pr)
- Specs blocked: resolver bloqueio e re-executar /task-team
- Cleanup PRDs: /spec cleanup
```

## Regras Críticas

- SEMPRE crie as tasks na task list ANTES de spawnar teammates
- SEMPRE inclua a spec completa + context pack no description da task (teammates não têm o contexto do lead)
- SEMPRE `isolation: worktree` com ≥ 2 teammates
- SEMPRE spawne `subagent_type: implementer` sem override de model
- NUNCA pule os gates: qa-runner (haiku) → code-reviewer (fable) → só então o sprint está done
- NUNCA deixe conflito de arquivo sem `blockedBy` — paralelismo cego gera merge hell
- Monitore via TaskList — não assuma que está tudo funcionando
