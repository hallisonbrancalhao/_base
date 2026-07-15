# review-pr — Code Review Estruturado

> **Quando:** revisar PR antes de aprovar (manual ou IA).
> **Output:** relatório pass/fail por critério com paths e linhas.

## Contexto Mínimo
- @`.agent/Prompts/_context/critical_rules.md`
- @`.agent/System/typescript_clean_code.md`
- @`.agent/System/nx_architecture_rules.md`

## Prompt

````markdown
Revisar PR.

## Escopo
- **Branch**: [feature/WORK-XXXX]
- **Arquivos**: [LISTA ou `git diff main...HEAD --name-only`]
- **Tipo**: bug | enhancement | feature | refactor
- **Descrição**: [O QUE MUDOU]

## Checklist (reporte pass/fail + linha exata)

### TypeScript
- [ ] Funções ≤ 5 statements
- [ ] Funções ≤ 3 parâmetros
- [ ] Nomes auto-documentados
- [ ] Sem comentários óbvios

### Angular
- [ ] Standalone components
- [ ] Signals (sem BehaviorSubject)
- [ ] `input()` / `output()`
- [ ] `@if` / `@for`
- [ ] `inject()`

### PrimeNG
- [ ] Componentes (não diretivas)
- [ ] `#templateName` (não `pTemplate=`)

### Arquitetura
- [ ] Facade pattern para lógica
- [ ] Boundaries Nx respeitadas (rodar `nx lint`)
- [ ] Imports diretos (não barrel) quando definido em tsconfig
- [ ] `index.ts` exporta apenas o público

### Testes
- [ ] Mock de **todas** dependências
- [ ] Schemas configurados (`NO_ERRORS_SCHEMA`)
- [ ] `data-testid` para queries DOM
- [ ] Cobertura ≥ 80% no diff

### Segurança / Dados
- [ ] Sem secrets hardcoded
- [ ] Sem `console.log` em prod
- [ ] Validação no boundary (backend)
- [ ] `class-validator` **só** no backend (não FE)

## Output

```markdown
# Review: [TITULO]

## ✅ Pass (N)
- [criterio]: ok

## ❌ Fail (N)
- [criterio] em `arquivo:linha`: [problema]
  - **Fix sugerido**: [trecho]

## ⚠️ Sugestões (N)
- [opcional]: [melhoria]

## Veredicto: APROVAR / MUDANÇAS NECESSÁRIAS / BLOQUEAR
```
````
