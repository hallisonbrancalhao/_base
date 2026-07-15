# debug-pair-complex — Debug com Sub-agentes Paralelos

> **Quando:** bug em N arquivos, causa desconhecida, possível issue de arquitetura ou race condition.
> **Modo:** coordenador + 3 sub-agentes em paralelo (Anthropic: sub-agent architecture).

## Contexto Mínimo
- @`.agent/Prompts/_context/critical_rules.md`
- @`.agent/System/nx_architecture_rules.md`

## Prompt

````markdown
Bug complexo. Você é **coordenador** e vai usar 3 sub-agentes em paralelo.

## Bug
- **Scope/Feature**: [NOME]
- **Sintomas**: [LISTA]
- **Arquivos suspeitos**: [LISTA]
- **Impacto**: [USUÁRIOS / TIMING / FREQUÊNCIA]

## Sub-agentes (executar EM PARALELO, retornar ≤ 1500 tokens cada)

### Agente 1 — Code Investigator
Tarefa: Ler [ARQUIVOS] e mapear:
- Signals/observables envolvidos e onde mudam
- Subscriptions sem `takeUntilDestroyed` ou `async pipe`
- Race conditions (Promise.all, forkJoin com side effects)
- Estado mutado fora de facade
Retorno: lista ranqueada de hipóteses com `arquivo:linha` + evidência.

### Agente 2 — Test Auditor
Tarefa: Ler `*.spec.ts` correspondentes.
- Cobertura do código suspeito?
- Cenários ausentes (erro, vazio, concorrente)?
- Mocks corretos? Schemas configurados?
Retorno: cenários faltantes + 1 exemplo de teste novo (esqueleto).

### Agente 3 — Architecture Reviewer
Tarefa: Validar contra `.agent/System/nx_architecture_rules.md`.
- Lógica no lugar certo (facade vs component)?
- Boundaries violadas?
- Import direto vs barrel ok?
Retorno: violações encontradas (se houver) + recomendações.

## Síntese (após receber os 3 retornos)
1. **Causa raiz** consolidada
2. **Fix proposto** (código antes/depois, mínimo)
3. **Testes regressão** (1-2 cenários)
4. **Recomendações arquiteturais** (separadas do fix; podem virar nova task)

## Regras
- Não comece a fixar antes de ter os 3 retornos
- Se hipóteses divergirem, peça mais info antes de assumir
````

## Anti-padrões

- ❌ Rodar sub-agentes sequencialmente — paralelo é o ponto
- ❌ Misturar refactor com fix — separar
