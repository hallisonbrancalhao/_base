<!--
TEMPLATE para criar novos prompts neste repositório.
Princípios: smallest set of high-signal tokens.
-->

# [NOME DO PROMPT] - [Categoria]

> **Quando usar:** [1 frase descrevendo o caso ideal]
> **Categoria:** Two-way / Code Review / Design / Reports
> **Tempo estimado:** [curto < 5min | médio 5-30min | longo > 30min]

---

## Contexto Mínimo (load just-in-time)

<!-- Cite só o que for relevante para esta tarefa. NÃO copie todos os arquivos. -->

- @`.agent/Prompts/_context/tech_stack.md`
- @`.agent/Prompts/_context/critical_rules.md`
- @`.agent/Prompts/_context/output_format.md`
- [Documento específico da tarefa, se houver]

---

## Variáveis de Input

| Variável | Tipo | Descrição |
|----------|------|-----------|
| `[VAR_1]` | string | [o que preencher] |
| `[VAR_2]` | path | [caminho de arquivo] |

---

## Prompt

````markdown
[COLE O PROMPT AQUI — pronto para usar com variáveis preenchidas]
````

---

## Output Esperado

[Descrever estrutura do output: seções, formato, exemplos]

---

## Sub-Agentes (se aplicável)

<!-- Quando dividir em paralelo? Quais retornam o quê? -->

| Sub-agente | Tarefa | Retorno (max ~1500 tokens) |
|------------|--------|----------------------------|
| explorer | mapear arquivos relevantes | lista de paths + 1 linha cada |
| debugger | causa raiz | hipótese + evidência |

---

## Anti-padrões

- ❌ [coisa específica a evitar neste tipo de prompt]
- ❌ [outra]

---

## Exemplo Preenchido

````markdown
[Exemplo real com variáveis substituídas]
````
