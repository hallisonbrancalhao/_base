# research-topic — Comparativo Estruturado

> **Quando:** comparar N opções (libs, padrões, abordagens) antes de decidir.
> **Output:** matriz + recomendação justificada.

## Contexto Mínimo
- @`.agent/Prompts/_context/output_format.md`

## Prompt

````markdown
Pesquisa comparativa.

## Tópico
- **Pergunta**: [O QUE QUERO DECIDIR]
- **Opções a comparar**: [LISTA]
- **Critérios prioritários**: [LISTA] (ex: tamanho bundle, DX, manutenção, compatibilidade Angular 21)
- **Contexto**: [POR QUE PRECISO DISSO no nosso monorepo]

## Output

### 1. Matriz comparativa
| Critério | Opção A | Opção B | Opção C |
|----------|---------|---------|---------|
| [critério] | ✅/⚠️/❌ + nota | ... | ... |

### 2. Pros/Cons por opção (3-5 bullets cada)

### 3. Tradeoffs cruzados
- "A é melhor em X mas pior em Y"

### 4. Recomendação
- **Opção escolhida**: [X]
- **Por que**: [justificativa ligada aos critérios prioritários]
- **Quando NÃO usar**: [contra-indicações]

### 5. Próximos passos
- POC sugerida (escopo mínimo)
- Riscos a validar

## Regras
- ✅ Use docs oficiais (cite URL + data)
- ✅ Considere o **nosso stack** (Angular 21, Nx, PrimeNG 21)
- ❌ Não recomende sem testar/validar pelo menos 1 critério crítico
- ❌ Não enviese — apresente tradeoff real
````
