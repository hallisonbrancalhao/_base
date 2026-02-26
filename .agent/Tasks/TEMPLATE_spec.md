---
id: SPEC_WORK_XXXX
task_id: WORK-XXXX
type: bug | enhancement | feature
status: pending | in_progress | done | blocked
created: YYYY-MM-DD
source_prd: DEV_PRD_WORK_XXXX.md
branch: feature/WORK-XXXX-nome
base: develop | release/** | master
---

# SPEC: WORK-XXXX [Titulo]

## Objetivo

[1-2 frases do que precisa ser feito. Sem contexto de negocio - apenas a acao tecnica.]

## Pre-condicoes

- Branch: `feature/WORK-XXXX-nome` (a partir da base definida no frontmatter)
- Libs existentes que serao usadas:
  - `libs/scope/data-access` — facade, repository
  - `libs/scope/domain` — DTOs, interfaces

## Acoes Sequenciais

### 1. [Acao - ex: Criar DTO no domain]

**Arquivo**: `libs/scope/domain/src/lib/dtos/nome.dto.ts`
**Operacao**: criar
**Conteudo esperado**:
```typescript
// Exemplo de assinatura/estrutura esperada
export interface NomeDto {
  id: string;
  campo: tipo;
}
```

### 2. [Acao - ex: Estender facade no data-access]

**Arquivo**: `libs/scope/data-access/src/lib/facades/nome.facade.ts`
**Operacao**: modificar
**Mudanca**: Adicionar metodo `novoMetodo()` que [descricao precisa]
**Referencia**: Seguir padrao do metodo `metodoExistente()` no mesmo arquivo

### 3. [Acao - ex: Criar componente na feature]

**Arquivo**: `libs/scope/feature-nome/src/lib/components/nome/nome.component.ts`
**Operacao**: criar
**Padrao**: Standalone component com signals, inject facade, @if/@for
**Template**: PrimeNG components (p-table, p-button, etc)
**data-testid**: `nome-component`, `nome-table`, `nome-button-action`

### 4. [Acao - ex: Registrar rota]

**Arquivo**: `libs/scope/feature-nome/src/lib/nome.routes.ts`
**Operacao**: criar
**Padrao**: Lazy-loaded route

### 5. [Acao - ex: Atualizar barrel export]

**Arquivo**: `libs/scope/feature-nome/src/index.ts`
**Operacao**: modificar
**Mudanca**: Exportar `NOME_ROUTES`

---

## Arquivos a Criar

| # | Path | Tipo | Padrao a Seguir |
|---|------|------|-----------------|
| 1 | `libs/scope/domain/src/lib/dtos/nome.dto.ts` | DTO | Interface pura, sem Angular |
| 2 | `libs/scope/feature-nome/src/lib/components/nome.component.ts` | Component | Standalone + signals + PrimeNG |
| 3 | `libs/scope/feature-nome/src/lib/nome.routes.ts` | Routes | Lazy-loaded |

## Arquivos a Modificar

| # | Path | Mudanca | Secao/Linha |
|---|------|---------|-------------|
| 1 | `libs/scope/data-access/src/lib/facades/nome.facade.ts` | Adicionar metodo X | Apos metodo Y |
| 2 | `libs/scope/feature-nome/src/index.ts` | Exportar rota | exports |

## Testes Obrigatorios

| # | Arquivo de Teste | O que Testar |
|---|------------------|--------------|
| 1 | `nome.facade.spec.ts` | metodo novo: happy path + erro |
| 2 | `nome.component.spec.ts` | render estados: loading, empty, data, error |

## Validacao

```bash
npx nx affected:lint --base=HEAD~1
npx nx affected:test --base=HEAD~1
npx nx affected:build --base=HEAD~1
```

## Definition of Done

- [ ] Todos os arquivos criados/modificados conforme listado
- [ ] Testes unitarios escritos e passando (>80% coverage)
- [ ] `nx affected:lint` passando
- [ ] `nx affected:test` passando
- [ ] `nx affected:build` passando
- [ ] Commit seguindo convencao: `feat(scope): WORK-XXXX descricao`
- [ ] Nenhum `throw new Error('TODO')` no codigo

---

**Ao concluir**: Atualize o campo `status` no frontmatter para `done`.
**Se bloqueado**: Atualize para `blocked` e adicione uma secao `## Bloqueio` com a descricao.
