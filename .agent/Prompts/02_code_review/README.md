# Code Review & Understanding

> Prompts para **entender, revisar e auditar** código existente. Output é insight ou diff, não nova feature.

## Quando usar

- Code review antes de PR
- Onboarding em código alheio
- Debugging por inspeção
- Auditoria de arquitetura

## Prompts

| Prompt | Output |
|--------|--------|
| [review-pr.md](./review-pr.md) | Relatório pass/fail por critério |
| [explain-code.md](./explain-code.md) | Explicação textual em markdown |
| [explain-html.md](./explain-html.md) | **Explicação visual em HTML autocontido** |
| [trace-execution.md](./trace-execution.md) | Trace de runtime: fluxo passo-a-passo |
| [audit-architecture.md](./audit-architecture.md) | Audit completo via 3 sub-agentes paralelos |

## Princípio Anthropic aplicado

> "Just-in-time retrieval" — leia o arquivo só quando precisar; use grep antes de Read.
