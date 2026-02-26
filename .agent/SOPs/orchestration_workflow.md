# Workflow de Orquestracao Multi-Task

## Visão Geral

O sistema de orquestracao permite analisar, planejar e implementar multiplas tasks (WORK-xxxx) em paralelo usando agentes especializados.

## Fluxo Completo

```
/orchestrate WORK-1234 WORK-1235 WORK-1236
        |
        v
  [Classificacao: bug / enhancement / feature]
        |
   +---------+---------+
   |         |         |
   v         v         v
 bug-      enhance-   explore +
 investigator ment-analyst arch-validate
   |         |         |
   v         v         v
  [Analise estruturada por task]
        |
        v
  [prd-writer cria DEV_PRD para cada task]
        |
        v
  [REVIEW HUMANO — dev le e aprova cada PRD]
        |
        v
  /spec (converte PRDs aprovadas em specs)
        |
        v
  [SPEC_WORK_XXXX.md para cada task]
        |
        v
  [Implementacao: /task (individual) ou /task-team (paralelo)]
        |
        v
  [Cleanup: PRDs deletadas, specs marcadas done]
```

## Comandos Disponiveis

### /orchestrate [tasks]

Inicia a analise de multiplas tasks. Aceita tasks no formato:

```
/orchestrate WORK-1234 WORK-1235 WORK-1236
/orchestrate WORK-1234 (bug no form de cadastro) WORK-1235 (melhoria no filtro)
/orchestrate WORK-1234, WORK-1235, WORK-1236
```

O orquestrador vai:
1. Listar e classificar cada task
2. Pedir confirmacao da classificacao
3. Analisar todas em paralelo
4. Criar PRDs para review

### /spec

Converte PRDs aprovadas em specs executaveis:

```
/spec
/spec WORK-1234
/spec cleanup
```

### /task

Implementa uma spec individual (sequencial, uma por vez).

### /task-team

Implementa multiplas specs em paralelo usando Agent Teams:

```
/task-team
/task-team WORK-1234 WORK-1235
```

O comando vai:
1. Listar specs pendentes em `.agent/Tasks/`
2. Verificar conflitos de arquivos entre specs
3. Criar um team com `TeamCreate`
4. Criar tasks compartilhadas com `TaskCreate` (contendo a spec completa)
5. Spawnar um teammate por spec com `isolation: worktree`
6. Monitorar progresso e repassar mensagens
7. Fazer cleanup ao finalizar

**Controles durante execucao:**
- `Shift+Down`: alternar entre teammates
- `Ctrl+T`: ver task list compartilhada
- "como esta o progresso?": ver status de todas as tasks
- "shutdown dev-WORK-1234": encerrar um teammate
- "cleanup team": encerrar tudo

## Tipos de Agentes

| Agente | Quando Usado | O que Faz |
|--------|-------------|-----------|
| `orchestrator` | /orchestrate | Classifica tasks, coordena agents |
| `bug-investigator` | Task tipo bug | Investiga root cause, traca data flow |
| `enhancement-analyst` | Task tipo enhancement | Consulta business rules, mapeia reuso |
| `prd-writer` | Apos analise | Cria PRD legivel para dev review |
| `spec-writer` | Apos aprovacao | Transforma PRD em spec executavel |
| `implementer` | /task-team | Teammate que implementa 1 spec end-to-end |

## Ciclo de Vida dos Arquivos

### DEV_PRD_WORK_XXXX.md
- **Criada por**: prd-writer (via /orchestrate)
- **Local**: `.agent/Tasks/`
- **Review por**: Desenvolvedor humano
- **Status**: aguardando-review → aprovado/rejeitado/revisao-necessaria
- **Deletada quando**: Spec correspondente marcada como `done`

### SPEC_WORK_XXXX.md
- **Criada por**: spec-writer (via /spec)
- **Local**: `.agent/Tasks/`
- **Consumida por**: Agente de implementacao (/task ou Agent Teams)
- **Status**: pending → in_progress → done/blocked
- **Mantida como**: Registro historico

## Guia para Reviewers

Ao revisar uma DEV_PRD:

### O que verificar

1. **Secao "Contexto"**: A descricao do problema esta correta?
2. **Secao "Analise do Agente"**: Os artefatos mapeados existem de fato?
3. **Secao "Decisoes Tomadas"**: As decisoes fazem sentido? O rationale e solido?
4. **Secao "Estrategia"**: As etapas estao na ordem correta? Falta algo?
5. **Secao "Riscos"**: Algum risco nao coberto?

### Como aprovar

1. Abra o arquivo `DEV_PRD_WORK_XXXX.md`
2. Revise cada secao
3. Altere o campo **Status** no topo:
   - `aprovado` — pronto para gerar spec
   - `revisao-necessaria` — adicione comentarios inline sobre o que ajustar
   - `rejeitado` — a estrategia toda precisa ser refeita

### Dica

Se so uma parte precisa de ajuste, use `revisao-necessaria` e adicione uma secao no final:

```markdown
## Feedback do Reviewer

- [ ] Decisao #2: Prefiro usar o `ProcessFacade` existente ao inves de criar novo
- [ ] Etapa 3: Falta considerar o dark mode
- [ ] Risco: Nao mencionou impacto no mobile
```

## Troubleshooting

### "Nenhuma PRD aprovada encontrada"
Execute `/orchestrate` primeiro para criar as PRDs, depois revise e aprove.

### "Task muito vaga para classificar"
Forneca mais contexto ao orquestrador: `/orchestrate WORK-1234 (descricao detalhada do que acontece)`

### "Spec com status blocked"
Abra o SPEC e leia a secao "Bloqueio". Resolva o bloqueio e mude status para `pending` novamente.

### "Agent Teams: teammates conflitando em arquivos"
Certifique-se de que cada teammate trabalha em specs que afetam escopos/libs diferentes. Se houver overlap, implemente sequencialmente.
