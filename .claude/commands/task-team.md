---
description: Launch Agent Teams to implement multiple SPEC files in parallel with independent teammates
---

# Task Team — Implementacao Paralela com Agent Teams

Leia os arquivos SPEC em `.agent/Tasks/` e lance um team de agentes para implementar em paralelo.

## Input

```
$ARGUMENTS
```

## Protocolo

### Fase 1: Descoberta de Specs

1. Liste todos os arquivos `SPEC_WORK_*.md` em `.agent/Tasks/`
2. Leia o frontmatter YAML de cada um
3. Filtre apenas os que tem `status: pending`
4. Se nenhuma spec pendente, informe o usuario e sugira executar `/orchestrate` + `/spec` primeiro

Apresente a lista:

```markdown
## Specs Disponiveis

| #   | Spec              | Task      | Tipo        | Branch                 | Base    |
| --- | ----------------- | --------- | ----------- | ---------------------- | ------- |
| 1   | SPEC_WORK_1234.md | WORK-1234 | bug         | feature/WORK-1234-nome | master  |
| 2   | SPEC_WORK_1235.md | WORK-1235 | enhancement | feature/WORK-1235-nome | develop |
| 3   | SPEC_WORK_1236.md | WORK-1236 | feature     | feature/WORK-1236-nome | develop |
```

Pergunte: "Quais specs deseja implementar em paralelo? (todas / numeros separados por virgula / cancelar)"

### Fase 2: Analise de Conflitos

Antes de criar o team, verifique se as specs selecionadas tem overlap de arquivos:

1. Leia cada spec selecionada por completo
2. Extraia as listas "Arquivos a Criar" e "Arquivos a Modificar"
3. Cruze os paths — se duas specs tocam o mesmo arquivo, ALERTE:

```markdown
## Alerta: Conflito de Arquivos

| Arquivo                       | Specs que tocam                |
| ----------------------------- | ------------------------------ |
| `libs/shared/data-access/...` | SPEC_WORK_1234, SPEC_WORK_1235 |

Recomendacao: Implemente WORK-1234 e WORK-1235 sequencialmente.
Deseja continuar mesmo assim? (sim / remover conflitantes / cancelar)
```

Se nao houver conflitos, prossiga direto.

### Fase 3: Criar o Team

Use a tool TeamCreate:

```
TeamCreate:
  team_name: "work-sprint-YYYYMMDD"
  description: "Implementing [N] specs in parallel: WORK-1234, WORK-1235, WORK-1236"
```

### Fase 4: Criar Tasks no Task List

Para cada spec selecionada, crie uma task compartilhada via TaskCreate.
Leia o conteudo COMPLETO da spec para incluir no description.

```
TaskCreate:
  subject: "WORK-XXXX: [titulo da spec]"
  description: |
    Implemente a spec abaixo seguindo TODAS as instrucoes.

    ## Contexto do Projeto
    - Nx monorepo Angular 19+ com PrimeNG 21+
    - Standalone components, signals, @if/@for
    - Facade Pattern obrigatorio
    - Imports diretos (nao barrel)
    - Leia .agent/System/base_rules.md e .agent/System/angular_best_practices.md

    ## Spec Completa
    [conteudo completo do SPEC_WORK_XXXX.md]

    ## Instrucoes de Finalizacao
    1. Apos implementar, rode: npx nx affected:lint --base=HEAD~1 && npx nx affected:test --base=HEAD~1 && npx nx affected:build --base=HEAD~1
    2. Se tudo passar, faca commit: git add [arquivos] && git commit -m "feat(scope): WORK-XXXX descricao"
    3. Marque esta task como completed via TaskUpdate
    4. Atualize o frontmatter do SPEC_WORK_XXXX.md para status: done
  activeForm: "Implementing WORK-XXXX"
```

Se houver dependencias entre specs (ex: uma cria um DTO que outra consome), use TaskUpdate para wiring:

```
TaskUpdate:
  taskId: "[id da task dependente]"
  addBlockedBy: ["[id da task prerequisito]"]
```

### Fase 5: Spawnar Teammates

Para cada spec, spawne um teammate via Task tool com `team_name`.
Use `isolation: "worktree"` para que cada teammate trabalhe em uma copia isolada do repo.

```
Task tool:
  team_name: "work-sprint-YYYYMMDD"
  name: "dev-WORK-XXXX"
  subagent_type: general-purpose
  model: opus
  isolation: worktree
  prompt: |
    Voce e um desenvolvedor Angular/Nx especializado. Sua unica tarefa e implementar o WORK-XXXX.

    IMPORTANTE:
    1. Leia a task atribuida a voce no task list (use TaskList + TaskGet)
    2. A task contem a spec COMPLETA com todas as instrucoes
    3. Siga CADA acao sequencial na ordem listada
    4. Leia .agent/System/base_rules.md e .agent/System/angular_best_practices.md para padroes
    5. Use imports diretos (nao barrel): import { X } from '@scope/lib/path/file'
    6. Apos implementar, rode lint + test + build
    7. Se passar, faca o commit seguindo a convencao
    8. Marque a task como completed
    9. Atualize o SPEC_WORK_XXXX.md frontmatter para status: done

    Se encontrar um bloqueio, marque a task como blocked e envie mensagem ao team lead explicando.
```

### Fase 6: Monitoramento

Apos spawnar todos os teammates:

1. Informe o usuario:

```markdown
## Team Criado

| Teammate      | Spec              | Status  |
| ------------- | ----------------- | ------- |
| dev-WORK-1234 | SPEC_WORK_1234.md | spawned |
| dev-WORK-1235 | SPEC_WORK_1235.md | spawned |
| dev-WORK-1236 | SPEC_WORK_1236.md | spawned |

### Comandos uteis:

- **Shift+Down**: Alternar entre teammates (in-process mode)
- **Ctrl+T**: Ver task list compartilhada
- **Enter**: Ver sessao do teammate selecionado
- Enviar mensagem: diga "envie mensagem para dev-WORK-1234: [conteudo]"
- Ver progresso: diga "TaskList" ou "como esta o progresso?"
- Parar teammate: diga "shutdown dev-WORK-1234"
- Encerrar tudo: diga "cleanup team"
```

2. Monitore via TaskList periodicamente quando o usuario perguntar pelo progresso
3. Repasse mensagens entre teammates se necessario via SendMessage

### Fase 7: Finalizacao

Quando todos os teammates completarem suas tasks:

1. Use TaskList para confirmar que todas as tasks estao `completed`
2. Para cada teammate finalizado, envie shutdown_request via SendMessage:

```
SendMessage:
  type: shutdown_request
  recipient: "dev-WORK-XXXX"
  content: "Sua task foi completada. Pode encerrar."
```

3. Apos todos responderem, use TeamDelete para limpar
4. Informe o usuario:

```markdown
## Sprint Concluido

| Spec              | Status  | Commit                     |
| ----------------- | ------- | -------------------------- |
| SPEC_WORK_1234.md | done    | feat(scope): WORK-1234 ... |
| SPEC_WORK_1235.md | done    | feat(scope): WORK-1235 ... |
| SPEC_WORK_1236.md | blocked | [motivo]                   |

### Proximos passos:

- Specs done: prontas para PR
- Specs blocked: resolver bloqueio e re-executar /task-team
- Cleanup PRDs: execute /spec cleanup
```

## Regras Criticas

- NUNCA spawne teammates que tocam os mesmos arquivos sem alertar primeiro
- SEMPRE use `isolation: worktree` para evitar conflitos de git
- SEMPRE crie as tasks no task list ANTES de spawnar teammates
- SEMPRE inclua a spec completa no description da task (teammates nao tem contexto do lead)
- SEMPRE monitore via TaskList — nao assuma que tudo esta funcionando
- Se um teammate reportar bloqueio, avalie se outro teammate pode ajudar ou se precisa de intervencao humana
- NUNCA faca TeamDelete enquanto houver teammates ativos
