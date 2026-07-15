# audit-architecture — Audit Completo (sub-agentes paralelos)

> **Quando:** validar saúde arquitetural de scope/lib antes de release, após refactor grande, ou para onboarding.
> **Modo:** coordenador + 3 sub-agentes paralelos, retorno consolidado.

## Contexto Mínimo
- @`.agent/Prompts/_context/critical_rules.md`
- @`.agent/System/nx_architecture_rules.md`
- @`.agent/System/libs_architecture_pattern.md`

## Prompt

````markdown
Audit arquitetural.

## Escopo
- **Target**: [scope/lib, ex: `libs/payment/*`]
- **Profundidade**: leve (lint only) / média (+ testes) / completa (+ performance + security)

## Sub-agentes em paralelo (cada um retorna ≤ 1500 tokens)

### Agente 1 — `@arch-validator`
- Boundaries Nx respeitadas?
- Tags consistentes?
- Imports diretos vs barrel?
- `index.ts` expõe só o público?

### Agente 2 — `@code-reviewer`
- Padrões do `.agent/System/typescript_clean_code.md`?
- Standalone + signals + inject()?
- Funções ≤ 5 statements?

### Agente 3 — `@performance-auditor`
- N+1 queries (backend)?
- Subscriptions sem unsubscribe?
- Memory leaks (event listeners não removidos)?
- Computed signals com efeitos colaterais?

## Síntese (após os 3 retornos)

```markdown
# Audit: [TARGET] — [DATA]

## Score
- Arquitetura: X/10
- Code Quality: X/10
- Performance: X/10
- **Geral: X/10**

## 🔴 Críticos (N)
- [path:linha]: descrição + fix sugerido

## 🟡 Atenção (N)
- [...]

## 🟢 OK
- [...]

## Plano de Remediação
1. [passo crítico]
2. [...]
```

## Regras
- ✅ Sempre cite `arquivo:linha`
- ✅ Score honesto, não inflacionar
- ❌ Não duplique findings entre agentes
````
