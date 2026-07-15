# design-handoff — UX → Dev PRD

> **Quando:** UX precisa entregar especificação completa para o time de dev.
> **Output:** PRD pronta para `/plan WORK-xxxx`.

## Contexto Mínimo
- @`.agent/Tasks/TEMPLATE_dev_prd.md`
- @`.agent/Prompts/_context/critical_rules.md`
- @`.agent/System/primeng_best_practices.md`
- @`.agent/System/dark_mode_reference.md`

## Prompt

````markdown
Gerar PRD para handoff UX → Dev.

## Briefing
- **Feature**: [NOME]
- **Scope**: [admin / public / client / simulator / ...]
- **Figma**: [LINK]
- **Descrição**: [O QUE A TELA FAZ E POR QUÊ]

## Telas
1. **[Nome tela 1]**: [propósito]
2. **[Nome tela 2]**: [propósito]

## Dados
- **Entidade**: [NOME]
- **Campos**: [campo: tipo | enum]
- **Relações**: [foreign keys]
- **Ações**: criar / editar / listar / filtrar / excluir
- **Estados visuais**: loading, empty, error, success, parcial

## Métricas
- Eventos Datadog: [LISTA]

## Tarefa
1. Mapear scope em `libs/[scope]/` — quais libs existem, quais criar
2. Identificar componentes PrimeNG (consulte MCP PrimeNG)
3. Documentar:
   - Componentes por tela com props
   - Estados visuais (loading/empty/error/success)
   - Responsividade (mobile/tablet/desktop)
   - Dark mode (surface tokens)
   - `data-testid` em interativos
   - Acessibilidade (contraste, focus, ARIA)
4. Gerar PRD usando `.agent/Tasks/TEMPLATE_dev_prd.md`
5. Listar checklist de implementação priorizado:
   - P0: domain + DTOs
   - P1: data-access (facade + repository)
   - P2: feature (componentes)
   - P3: rotas + integração
   - P4: testes

## Restrições
- ❌ Não decidir negócio — só especificar
- ✅ Marcar TODOS open questions explicitamente
````
