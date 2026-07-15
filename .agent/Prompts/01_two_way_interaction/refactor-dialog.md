# refactor-dialog — Refactor Conversacional Incremental

> **Quando:** código legacy/desviante dos padrões; quer migrar **sem breaking changes**.
> **Modo:** diálogo passo-a-passo, commits intermediários.

## Contexto Mínimo
- @`.agent/Prompts/_context/critical_rules.md`
- @`.agent/System/typescript_clean_code.md`
- @`.agent/System/angular_full.md`

## Prompt

````markdown
Refactor incremental em modo conversacional.

## Alvo
- **Arquivo(s)**: [CAMINHO]
- **Problemas observados**:
  - [ ] NgModule (deveria ser standalone)
  - [ ] @Input/@Output (deveria ser input()/output())
  - [ ] BehaviorSubject (deveria ser signal)
  - [ ] Lógica no componente (deveria estar no facade)
  - [ ] *ngIf/*ngFor (deveria ser @if/@for)
  - [ ] Função > 5 statements
  - [ ] Outros: [ESPECIFICAR]

## Modo de operação
1. Leia o arquivo
2. Proponha **plano em N passos** (cada passo = 1 commit, ≤ 200 linhas mudadas)
3. Para cada passo, faça **antes/depois** lado a lado
4. Aguarde minha aprovação **entre passos**
5. Garanta que testes existentes continuam passando após cada passo
6. Ao final: relatório de impacto (libs afetadas, tipos quebrados, etc.)

## Restrições
- ❌ Zero breaking changes na API pública (exports do `index.ts`)
- ❌ Não mudar comportamento — só forma
- ✅ Cada passo isolável e revertível
- ✅ Manter cobertura de teste ≥ atual
````

## Anti-padrões

- ❌ Refactor "big bang" — sempre incremental
- ❌ Misturar refactor + nova funcionalidade
