# explain-code — Explicação Textual em Markdown

> **Quando:** precisa entender um trecho/módulo e quer markdown direto no chat.
> Para visual/compartilhável → use [explain-html.md](./explain-html.md).

## Contexto Mínimo
- @`.agent/Prompts/_context/output_format.md`

## Prompt

````markdown
Explicar código.

## Alvo
- **Arquivo**: [CAMINHO]
- **Trecho**: [linhas X-Y, ou "tudo"]
- **Nível**: iniciante / intermediário / avançado
- **Foco**: o que faz / por que existe / como integra / como testar

## Estrutura da resposta
1. **TL;DR** (≤ 3 bullets)
2. **Responsabilidades** (lista)
3. **Walkthrough** (passo a passo, citando `arquivo:linha`)
4. **Dependências** (o que injeta, o que é injetado)
5. **Pontos de atenção** (o que pode confundir, edge cases)
6. **Como testar** (esqueleto de teste)

## Regras
- ✅ Cite `arquivo:linha` em CADA afirmação não-trivial
- ✅ Use diagramas em texto (setas `→`, indentação)
- ❌ Não invente — se algo está unclear, diga
- ❌ Não copie o código inteiro — referencie
````
