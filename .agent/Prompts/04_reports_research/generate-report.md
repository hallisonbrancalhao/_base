# generate-report — Relatório Executivo

> **Quando:** consolidar achados (audit, performance run, security scan) em relatório legível por stakeholders.
> **Output:** markdown + opcional HTML via [explain-html.md](../02_code_review/explain-html.md).

## Contexto Mínimo
- @`.agent/Prompts/_context/output_format.md`

## Prompt

````markdown
Gerar relatório executivo.

## Input
- **Tipo**: audit / performance / security / qa / release-readiness
- **Escopo**: [scope/lib/feature]
- **Período**: [datas ou range de commits]
- **Dados brutos**: [colar logs / output de tools / `nx affected` / lighthouse]

## Estrutura

```markdown
# [TÍTULO] — [DATA]

## Sumário Executivo (1 parágrafo, < 100 palavras)
[Veredito + número-chave]

## Achados Principais
- 🔴 **Críticos** (N): [...]
- 🟡 **Atenção** (N): [...]
- 🟢 **OK**: [...]

## Detalhamento por Categoria
### [Categoria 1]
- Finding + evidência (`arquivo:linha` ou log)
- Impacto + Recomendação

### [Categoria 2]
...

## Plano de Ação Priorizado
| # | Ação | Esforço | Impacto | Owner sugerido |
|---|------|---------|---------|----------------|
| 1 | [...] | S/M/L | A/M/B | [time/agente] |

## Métricas
- [KPIs antes/depois quando possível]

## Anexos
- Comandos rodados
- Versões
```

## Regras
- ✅ Sumário executivo deve ser lido em 30s
- ✅ Cada achado tem evidência verificável
- ❌ Não inflacione severidade
- ❌ Não recomende sem priorizar
````

## Onde salvar
```
.agent/Plans/reports/[YYYY-MM-DD]_[tipo]_[escopo].md
```
