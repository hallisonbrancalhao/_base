# Hierarquia de Modelos por Função

> Política obrigatória para todos os comandos e agentes. Cada spawn de subagente DEVE respeitar esta matriz.

## Matriz

| Tier | Modelo | Alias (frontmatter/override) | Função | Onde |
|------|--------|------------------------------|--------|------|
| 1 | **Fable 5** | `fable` | Planejar + revisar (gates de decisão e qualidade) | Sessão principal (lead), `orchestrator`, `prd-writer`, `code-reviewer` |
| 2 | **Opus 4.8** | `opus` | Raciocínio profundo (root cause, auditorias, ofensivo) | `bug-investigator`, `enhancement-analyst`, `pentester`, `performance-auditor`, `security-auditor`, `architecture-reviewer` |
| 3 | **Sonnet 5** | `sonnet` | Execução padrão do que já foi planejado | `implementer`, `spec-writer` |
| 4 | **Haiku 4.5** | `haiku` | Trabalho braçal mecânico (rodar pipeline, coletar, formatar) | `qa-runner`, exploração em massa, scaffolding |

IDs completos (para SDK/CI): `claude-fable-5`, `claude-opus-4-8`, `claude-sonnet-5`, `claude-haiku-4-5-20251001`.

## Regra de Decisão

```
A etapa DECIDE estratégia ou APROVA qualidade?      → fable
A etapa exige INVESTIGAÇÃO profunda / adversária?    → opus
A etapa EXECUTA instruções já decididas (spec)?      → sonnet
A etapa é MECÂNICA (rodar comando, formatar, contar)? → haiku
```

Na dúvida entre dois tiers, use o mais barato e configure gate de revisão no tier acima.

## Como Aplicar

1. **Agentes de `.claude/agents/`**: o campo `model:` no frontmatter é a fonte de verdade. Spawne SEMPRE pelo `subagent_type` com o nome do agente — nunca `general-purpose` + "leia o agent definition" (isso descarta model, tools, maxTurns e permissionMode do agente).
2. **Skills mecânicas sem agente próprio** (git-operator, import-fixer, nx-operator, domain-scaffolder): spawne `general-purpose` com override `model: haiku` e prompt "Read `.claude/skills/[nome]/SKILL.md` and execute it for: [tarefa]".
3. **Exploração**: use o agente built-in `Explore` (já otimizado para busca barata). Investigação com julgamento é opus (`bug-investigator`), não Explore.
4. **Sessão principal**: é o lead (Fable). Orquestra, decide e revisa — não implementa nem roda pipeline inline quando há agente para isso.

## Escalação

- Agente falhou 2× na mesma etapa → o lead escala UM tier (haiku→sonnet→opus) reenviando a tarefa com o histórico do erro.
- Nunca escale silenciosamente: registre o motivo na task (TaskUpdate) ou no resumo.
- Nunca comece um tier acima "por garantia" — o gate de revisão existe para isso.

## Context Pack (obrigatório em todo spawn)

Todo prompt de subagente inclui esta instrução:

```
Context pack — leia em UM batch antes de qualquer coisa:
.agent/Prompts/_context/tech_stack.md
.agent/Prompts/_context/critical_rules.md
.agent/Prompts/_context/doc_references.md   (demais docs: just-in-time)
```

Além do pack, o prompt carrega SOMENTE o insumo da tarefa (spec, análise, diff range). Nada de colar documentação inteira — ponteiros + pack dão contexto pleno pelo caminho mais curto.

## Team Activation Policy

| Situação | Ação |
|----------|------|
| ≥ 2 unidades de trabalho independentes (specs, tasks, auditorias) | Team: N teammates em paralelo + task list compartilhada (`/task-team`, `/orchestrate`, `/audit-report`) |
| Unidades com dependência entre si | Mesmo team, wire com `blockedBy` — o teammate espera o bloqueador |
| 1 unidade | 1 agente único do tier certo (sem overhead de team) |
| Qualquer implementação concluída | Gate: `qa-runner` (haiku) → `code-reviewer` (fable) antes de considerar done |

## Fluxo de Referência (plan → exec)

```
/plan ou /orchestrate   lead fable + análise opus + PRD fable
        ↓ (humano aprova PRD)
/spec                   conversão sonnet (paralela) + gate de paths pelo lead
        ↓
/task ou /task-team     implementer(s) sonnet [worktree se paralelo]
        ↓
qa-runner haiku → code-reviewer fable → merge/commit
```
