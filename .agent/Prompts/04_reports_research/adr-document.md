# adr-document — Architecture Decision Record

> **Quando:** registrar decisão arquitetural já tomada (memória institucional).
> Para **co-design** antes de decidir, use [pair-architect.md](../01_two_way_interaction/pair-architect.md).

## Contexto Mínimo
- @`.agent/Prompts/_context/output_format.md`

## Prompt

````markdown
Gerar ADR.

## Input
- **Título da decisão**: [VERBO + OBJETO, ex: "Adotar Signals em vez de BehaviorSubject"]
- **Status**: proposed | accepted | superseded
- **Data**: [YYYY-MM-DD]
- **Decisores**: [nomes / squad]
- **Contexto**: [problema que motivou]
- **Decisão tomada**: [o que foi escolhido]
- **Alternativas consideradas**: [LISTA com 1 linha cada]

## Formato

```markdown
# ADR-[N]: [Título]

- **Status**: [accepted]
- **Data**: [YYYY-MM-DD]
- **Decisores**: [...]
- **Tags**: [angular, state-management, ...]

## Contexto
[1-3 parágrafos: por que essa decisão foi necessária, o que estava acontecendo antes]

## Decisão
[O que será feito, escrito em voz ativa: "Vamos X" / "Adotamos Y"]

## Alternativas Consideradas
1. **[Alt A]** — descartada porque [razão]
2. **[Alt B]** — descartada porque [razão]

## Consequências
### Positivas
- [...]

### Negativas
- [...]

### Neutras
- [...]

## Reversibilidade
- **Custo de reverter**: baixo / médio / alto
- **Pontos de não-retorno**: [se houver]

## Links
- PR: [...]
- Issue: [...]
- Doc relacionada: [`.agent/System/...`]
```

## Regras
- ✅ Escreva como se um novo dev fosse ler em 6 meses
- ✅ Honestidade nas negativas — toda decisão tem tradeoff
- ❌ Não retrofite "razões boas" — escreva as razões reais
````

## Onde salvar
```
.agent/Plans/adrs/[NNNN]_[titulo-kebab].md
```
Numeração sequencial: ADR-0001, ADR-0002, ...
