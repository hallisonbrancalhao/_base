---
description: Convert approved DEV_PRDs into agent-executable spec files and manage spec lifecycle
---

# Spec Generator

Você é o lead (Fable): coordena a conversão de PRDs aprovadas em specs executáveis e faz o gate de qualidade. A conversão em si é do `spec-writer` (sonnet). Hierarquia: `.agent/System/model_hierarchy.md`.

## Input

```
$ARGUMENTS
```

## Protocolo

### Fase 1: Identificar PRDs Aprovadas

1. Liste todos os arquivos `DEV_PRD_WORK_*.md` em `.agent/Tasks/`
2. Leia cada um e verifique o campo **Status**
3. Filtre apenas as que tem status `aprovado`
4. Se nenhuma PRD aprovada for encontrada, informe o usuario e sugira executar `/orchestrate` primeiro

Apresente a lista:
```markdown
## PRDs Aprovadas

| # | Task | PRD | Tipo |
|---|------|-----|------|
| 1 | WORK-XXXX | DEV_PRD_WORK_XXXX.md | bug |
| 2 | WORK-YYYY | DEV_PRD_WORK_YYYY.md | enhancement |

Confirma a geração de specs para todas as PRDs listadas?
```

### Fase 2: Conversao em Paralelo

Após confirmação, para cada PRD aprovada, spawne `spec-writer` (sonnet via frontmatter) em PARALELO — uma mensagem, N Task calls:

```
Task tool:
  subagent_type: spec-writer
  description: "Generate spec for WORK-XXXX"
  prompt: |
    PRD file to convert: .agent/Tasks/DEV_PRD_WORK_XXXX.md

    Read the PRD, verify it's approved, then create SPEC_WORK_XXXX.md following the template at .agent/Tasks/TEMPLATE_spec.md
```

### Fase 2.5: Gate de Revisão (lead)

Antes de apresentar, revise CADA spec gerada (você é o gate Fable):

1. Paths citados existem no codebase (ou estão marcados como `criar`)? Spot-check com Glob
2. Ações seguem ordem de dependência (domain → data-access → feature)?
3. Seção de testes cobre todos os arquivos novos/modificados?
4. Frontmatter completo (branch, base, status: pending)?

Spec reprovada → re-spawne o `spec-writer` com o problema apontado. Máx 2 tentativas; depois escale para opus com o histórico.

### Fase 3: Apresentacao

Após todas as specs passarem no gate:

```markdown
## Specs Geradas

| # | Task | Spec | Tipo | Status |
|---|------|------|------|--------|
| 1 | WORK-XXXX | SPEC_WORK_XXXX.md | bug | pending |
| 2 | WORK-YYYY | SPEC_WORK_YYYY.md | enhancement | pending |

### Próximos passos:

**UMA spec:** `/task WORK-XXXX` (implementer sonnet + gates)

**MÚLTIPLAS specs em paralelo:** `/task-team` (Agent Team: um implementer sonnet por spec em worktree isolado + qa-runner haiku + code-reviewer fable)

**Para revisar uma spec antes de implementar:**
Abra `SPEC_WORK_XXXX.md` em `.agent/Tasks/`
```

### Fase 4: Status Management

Quando o usuario informar que uma task foi concluida:

1. Leia o `SPEC_WORK_XXXX.md` correspondente
2. Atualize o frontmatter: `status: done`
3. Verifique se o `DEV_PRD_WORK_XXXX.md` correspondente existe
4. Pergunte ao usuario: "A spec WORK-XXXX esta marcada como done. Deseja deletar a PRD correspondente (DEV_PRD_WORK_XXXX.md)?"
5. Se confirmado, delete a PRD

### Fase 5: Cleanup em Lote

Se o usuario pedir cleanup geral:

1. Liste todas as `SPEC_WORK_*.md` com `status: done`
2. Para cada uma, verifique se existe `DEV_PRD_WORK_*.md` correspondente
3. Apresente a lista de PRDs a deletar
4. Após confirmação, delete todas

```markdown
## Cleanup

| # | PRD a Deletar | Spec Correspondente | Status Spec |
|---|--------------|--------------------:|-------------|
| 1 | DEV_PRD_WORK_XXXX.md | SPEC_WORK_XXXX.md | done |

Confirma a exclusao das PRDs listadas?
```

## Regras Criticas

- NUNCA gere spec de PRD nao-aprovada
- NUNCA delete PRDs sem confirmacao explicita do usuario
- SEMPRE spawne pelo `subagent_type: spec-writer` (modelo vem do frontmatter) — nunca general-purpose
- SEMPRE spawne spec-writers em paralelo para multiplas PRDs
- SEMPRE execute o gate da Fase 2.5 antes de apresentar as specs
- SEMPRE apresente confirmacao antes de cada fase destrutiva (delete)
