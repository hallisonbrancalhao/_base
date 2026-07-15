# debug-pair-simple — Debug Conversacional (1 arquivo)

> **Quando:** bug em 1-2 arquivos, sintoma conhecido, causa nebulosa.
> **Modo:** diálogo — a IA pergunta antes de propor.

## Contexto Mínimo
- @`.agent/Prompts/_context/critical_rules.md`
- @`.agent/System/angular_full.md` (se Angular)
- @`.agent/System/angular_unit_testing_guide.md` (se for escrever teste)

## Prompt

````markdown
Vou debugar um bug com você em modo **pair programming**. NÃO proponha solução de imediato.

## Bug
- **Arquivo**: [CAMINHO]
- **Sintoma**: [O QUE VEJO]
- **Esperado**: [O QUE DEVERIA ACONTECER]
- **Repro**: [PASSOS, se souber]

## Modo de operação (IMPORTANTE)
1. Leia o arquivo
2. Faça **no máximo 3 perguntas** para refinar o entendimento (estado, inputs, race conditions, env)
3. Aguarde minhas respostas
4. Forme uma **hipótese ranqueada** (top 3 causas + probabilidade)
5. Peça permissão antes de modificar código
6. Aplique fix mínimo
7. Sugira teste regressão (data-testid, mock completo)

## Regras
- ✅ Diga "não sei" se for o caso
- ✅ Cite `arquivo:linha`
- ❌ Não invente APIs/métodos
- ❌ Não refatore além do bug
````

## Anti-padrões

- ❌ Aceitar a primeira hipótese sem evidência
- ❌ Refatorar "de passagem" — fix mínimo
