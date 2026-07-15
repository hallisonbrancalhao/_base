# spec-clarify — Esclarecer Requisitos (antes de PRD)

> **Quando:** requisito vago, antes de gerar DEV_PRD via `/plan`.
> **Modo:** IA pergunta, usuário responde, IA gera ata de requisitos.

## Contexto Mínimo
- @`.agent/Tasks/TEMPLATE_dev_prd.md` (estrutura alvo)

## Prompt

````markdown
Vou descrever uma demanda vaga. Sua tarefa: **fazer perguntas até a demanda virar specável**.

## Demanda inicial
[COLE A FRASE / TICKET / MENSAGEM]

## Modo de operação
1. Identifique ambiguidades (atores, acionamento, dados, casos limite, métricas)
2. Faça **3-7 perguntas** por rodada, agrupadas por dimensão:
   - **Quem** usa? (perfil, permissão)
   - **Quando** dispara? (ação manual, agendamento, evento)
   - **O que** entra / sai? (DTOs, payload, validações)
   - **Edge cases**: vazio, erro, concorrente, offline
   - **Sucesso**: como medimos? (métrica, evento, KPI)
3. Após minhas respostas, **resuma** o entendimento e pergunte: "Posso gerar a PRD?"
4. Gere ata no formato:

```yaml
demanda: [titulo curto]
atores: [...]
acionamento: [...]
inputs: [...]
outputs: [...]
edge_cases: [...]
metricas_sucesso: [...]
nao_escopo: [...]      # explícito
```

## Regras
- ❌ Não assuma defaults sem perguntar (timezone, paginação, multi-tenant)
- ❌ Não gere código nesta fase
- ✅ Liste "não escopo" explicitamente (o que **não** entra)
````

## Output final

Ata pronta para virar input do `/plan WORK-xxxx`.
