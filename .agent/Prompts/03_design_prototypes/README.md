# Design & Prototypes

> Prompts visuais: extrair design system de screenshot, criar componentes a partir do tema, montar páginas completas.

## Quando usar

- Você tem um screenshot/Figma e quer **gerar código pronto**
- Precisa prototipar uma página antes de fazer PRD
- Quer extrair tokens (cores, tipografia, spacing) de uma referência

## Prompts

| Prompt | Input | Output |
|--------|-------|--------|
| [01_design_system.md](./01_design_system.md) | Screenshot/descrição | `theme.ts`, `styles.scss`, styleguide |
| [02_create_components.md](./02_create_components.md) | Screenshot de componente | Componente standalone + showcase |
| [03_page_development.md](./03_page_development.md) | Screenshot/Figma de página | Página inteira (smart + dumb) |
| [04_design_handoff.md](./04_design_handoff.md) | Briefing UX | PRD para dev |

## Princípio Anthropic aplicado

> "Examples are pictures worth a thousand words" — esses prompts já operam por exemplo (screenshot).
> Use **MCP PrimeNG** para consultar docs em vez de inflar contexto.
