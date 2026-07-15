---
description: Implementar task do .agent/Tasks com contexto completo
---

# Task — Implementação de UMA Spec

Você é o lead (Fable): seleciona a spec, delega ao `implementer` (sonnet) e revisa o resultado. Para ≥ 2 specs use `/task-team`. Hierarquia: `.agent/System/model_hierarchy.md`.

## Input

```
$ARGUMENTS
```

## Protocolo

### Fase 1: Selecionar a Task

1. Se $ARGUMENTS traz um WORK-xxxx, localize `SPEC_WORK_XXXX.md` em `.agent/Tasks/`
2. Senão, liste specs com `status: pending` e pergunte qual implementar
3. Sem spec disponível? Duas rotas:
   - Existe DEV_PRD aprovada → rode `/spec` primeiro
   - Task legada (TASK/BUG/PRD antigo sem spec) → use o arquivo da task como spec informal no passo seguinte (modo legacy)

### Fase 2: Delegar ao Implementer

Spawne UM `implementer` (sonnet via frontmatter). Sem worktree — trabalho solo direto na branch:

```
Task tool:
  subagent_type: implementer
  description: "Implement WORK-XXXX"
  prompt: |
    Implemente a spec abaixo end-to-end (implementacao → testes → validacao → commit).
    Nao ha task list neste modo — a spec esta inline abaixo; ignore TaskList/TaskGet e va direto a implementacao.

    ## Spec
    [conteudo completo do SPEC_WORK_XXXX.md — ou da task legada]

    ## Finalizacao
    1. npx nx affected:lint/test/build --base=HEAD~1 — tudo verde
    2. Commit convencional: feat|fix(scope): WORK-XXXX descricao
    3. Reporte: arquivos criados/modificados, resultado da validacao, hash do commit
```

Implementer falhou validação 2× → escale UM tier: re-spawne com `model: opus` + histórico do erro.

### Fase 3: Review Gate (lead)

Revise o diff você mesmo (`git diff HEAD~1`) contra `.agent/Prompts/_context/critical_rules.md`:

- Diff ≤ ~300 linhas → revisão inline sua
- Diff maior → spawne `code-reviewer` (fable) com o range

Findings critical/high → devolva ao implementer (re-spawn com os findings). Verde → prossiga.

### Fase 4: Fechamento

1. Atualize `SPEC_WORK_XXXX.md` → `status: done` (ou o status da task legada)
2. Resumo: arquivos, commit, QA, veredicto do review
3. Próxima task pendente? Ofereça continuar

## Regras

- NUNCA implemente inline — o implementer executa, você decide e revisa
- SEMPRE inclua a spec COMPLETA no prompt (o subagente não tem seu contexto)
- SEMPRE aplique o review gate antes de marcar done
- Escalação de modelo só com falha registrada (2×), nunca preventiva
