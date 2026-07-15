# Two-way Interaction

> Prompts **conversacionais e iterativos**, onde a IA esclarece, propõe, recebe feedback e refina. Não são tasks one-shot.

## Quando usar esta categoria

- Você não tem certeza do escopo e precisa **co-pensar**
- O problema é ambíguo e exige **perguntas de esclarecimento**
- A solução vai emergir após **2-5 rodadas** de troca

## Prompts disponíveis

| Prompt | Caso |
|--------|------|
| [debug-pair-simple.md](./debug-pair-simple.md) | Bug com causa pouco clara — diálogo de debug |
| [debug-pair-complex.md](./debug-pair-complex.md) | Bug em múltiplos arquivos — sub-agentes paralelos + síntese |
| [refactor-dialog.md](./refactor-dialog.md) | Refactor incremental conversacional |
| [spec-clarify.md](./spec-clarify.md) | Esclarecer requisitos antes de criar PRD |
| [pair-architect.md](./pair-architect.md) | Co-design de arquitetura de feature |

## Princípio Anthropic aplicado

> "Compaction" — em conversas longas, peça resumo intermediário antes que o contexto sature.
