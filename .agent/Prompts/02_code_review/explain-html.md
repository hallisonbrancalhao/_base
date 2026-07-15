# explain-html — Explicação Visual Interativa (Code Review & Understanding)

> **Quando usar:** quando precisa **entender** algo (código, fluxo, conceito, arquitetura, lib, bug, decisão) e quer um output **visual, navegável e compartilhável** — não apenas markdown.
> **Categoria:** Code Review & Understanding
> **Output:** **HTML autocontido** (1 arquivo, sem dependências externas).

---

## Por que HTML?

Markdown explica em linha; HTML **mostra**. Para:
- Fluxos com setas/conexões (SVG inline)
- Diagramas de dependência (camadas Nx, facade ↔ repo ↔ API)
- "Antes/Depois" lado a lado
- Tabs/Accordion para explicações progressivas (disclosure)
- Tooltips em tokens de código
- Dark mode com toggle

A IA gera **um único `.html`** que abre direto no browser — útil para handoff, onboarding, code review assíncrono e documentação ad-hoc.

---

## Contexto Mínimo

- @`.agent/Prompts/_context/critical_rules.md` (só se a explicação envolver código do projeto)
- @`.agent/Prompts/_context/output_format.md`

---

## Variáveis de Input

| Variável | Descrição |
|----------|-----------|
| `[TOPICO]` | O que explicar (ex: "facade pattern no projeto", "fluxo de autenticação", "lib `@payment/data-access`") |
| `[NIVEL]` | `iniciante` / `intermediario` / `avancado` (define profundidade e jargão) |
| `[ARQUIVOS]` | (opcional) lista de arquivos referenciados, ex: `libs/auth/data-access/src/lib/facades/auth.facade.ts:42-89` |
| `[FOCO]` | (opcional) ângulo específico: `seguranca`, `performance`, `arquitetura`, `onboarding`, `bug-investigation` |

---

## Prompt

````markdown
Gere uma explicação **em HTML autocontido** sobre:

**Tópico:** [TOPICO]
**Nível do leitor:** [NIVEL]
**Foco:** [FOCO]
**Referências (opcional):** [ARQUIVOS]

## Contexto (carregue apenas o necessário)
- Se envolver código do projeto: leia primeiro `.agent/Prompts/_context/critical_rules.md`
- Se envolver Angular/PrimeNG/Nx: cite o `.agent/System/*.md` relevante mas NÃO copie conteúdo

## Requisitos do HTML

### Estrutura (DOCTYPE + 1 arquivo)
- `<!DOCTYPE html>` completo
- `<style>` inline (Tailwind-like, NÃO importar CDN)
- `<script>` inline (vanilla JS, sem libs externas)
- Sem `<link>` externos — tudo autocontido
- Charset utf-8, viewport meta, lang="pt-BR"

### Design
- **Surface tokens** do nosso projeto: `--surface-0`..`--surface-950` como CSS vars
- **Dark mode automático** com `prefers-color-scheme: dark` + botão de toggle (☀️ / 🌙)
- **Mobile-first**: layout funciona em 360px e em 1440px
- Tipografia: system-ui ou ui-sans-serif; mono: ui-monospace
- Cores de destaque: `--accent` (azul) + semânticas (success/warning/danger)

### Componentes Visuais Obrigatórios
Escolha 3-5 dos abaixo conforme o tópico:

| Bloco | Quando usar |
|-------|-------------|
| **TL;DR** | Sempre no topo: 3 bullets, leitura < 30s |
| **Fluxo SVG** | Quando há sequência (request → controller → service → DB) |
| **Diagrama de camadas** | Para arquitetura (Domain ↔ Data-Access ↔ Feature) |
| **Antes/Depois** | Para refactor ou comparação de padrões |
| **Tabs** | Para múltiplas perspectivas (TypeScript / Template / Test) |
| **Accordion** | Para disclosure progressivo (FAQ, deep-dive opcional) |
| **Code blocks com syntax highlight** | Sempre. Implementar highlight via spans coloridos manualmente (sem prismjs) |
| **Glossário em tooltips** | Hover em termo técnico → definição (`<abbr title>` ou tooltip JS) |
| **Quiz no fim** | 2-3 perguntas de verificação (radio + revelar resposta) |

### Conteúdo
1. **Título + meta** (data, nível, tempo de leitura estimado)
2. **TL;DR** em 3 bullets
3. **Por que importa** (motivação concreta para este projeto)
4. **Explicação principal** com pelo menos 1 diagrama SVG inline
5. **Código** (se aplicável): mostre o **mínimo** + comentários inline. Cite `arquivo:linha` quando referenciar real.
6. **Armadilhas comuns** (anti-padrões observados no nosso código)
7. **Quando aplicar / Quando NÃO aplicar**
8. **Próximos passos** (links para `.agent/System/*.md` relevantes)
9. **Quiz de fixação** (opcional, 2-3 perguntas)

### Acessibilidade
- Contraste AA mínimo (não use cor sozinha para sinalizar)
- `<button>` reais (não `<div onclick>`)
- `aria-label` em ícones-só-botão
- `<details>`/`<summary>` para accordion (semântico)
- Keyboard navegável (focus rings visíveis)

### Anti-padrões do HTML
- ❌ Importar Tailwind CDN, Bootstrap, jQuery
- ❌ Imagens externas (use SVG inline ou emoji)
- ❌ `style="color: gray"` — use CSS vars
- ❌ Markdown puro envolvido em `<pre>` — renderize de verdade
- ❌ Texto sem hierarquia (h1 → h2 → h3)
- ❌ Mais de 1 arquivo HTML (deve ser autocontido)

## Output
Forneça **APENAS o conteúdo do `.html`** dentro de um bloco ```html. Sem prólogo, sem explicação fora do HTML — o HTML deve se auto-explicar.
````

---

## Output Esperado (estrutura mínima)

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>[TOPICO] — Explicação</title>
  <style>
    :root {
      --surface-0: #ffffff;
      --surface-50: #f8fafc;
      /* ... até --surface-950 */
      --accent: #3b82f6;
      --text: var(--surface-900);
      --bg: var(--surface-0);
    }
    @media (prefers-color-scheme: dark) {
      :root { --text: var(--surface-0); --bg: var(--surface-950); }
    }
    [data-theme="dark"] { --text: var(--surface-0); --bg: var(--surface-950); }
    /* ... layout, components, syntax highlight ... */
  </style>
</head>
<body>
  <header>
    <h1>[TOPICO]</h1>
    <button id="theme-toggle" aria-label="Alternar tema">🌙</button>
  </header>

  <section class="tldr">
    <h2>TL;DR</h2>
    <ul>...</ul>
  </section>

  <section class="flow">
    <h2>Fluxo</h2>
    <svg viewBox="0 0 800 300">...</svg>
  </section>

  <!-- ... demais blocos ... -->

  <script>
    document.getElementById('theme-toggle').onclick = () => {
      const root = document.documentElement;
      root.dataset.theme = root.dataset.theme === 'dark' ? 'light' : 'dark';
    };
  </script>
</body>
</html>
```

---

## Sub-Agentes (para tópicos complexos)

Quando `[TOPICO]` envolve múltiplos arquivos ou camadas, divida:

| Sub-agente | Tarefa | Retorno |
|------------|--------|---------|
| `explorer` | Mapear arquivos/símbolos do tópico | Lista `path:linha` + 1 frase |
| `debugger` (opcional) | Causa raiz se for bug | Hipótese + evidência |

O coordenador então monta o HTML único com base nos sumários.

---

## Exemplos de Uso

### Onboarding
```
TOPICO: "estrutura de libs Nx neste monorepo"
NIVEL: iniciante
FOCO: onboarding
```
→ HTML com diagrama das camadas + matriz de dependências + tabs com exemplo de cada tipo.

### Code Review
```
TOPICO: "como o AuthFacade gerencia refresh token"
NIVEL: intermediario
ARQUIVOS: libs/auth/data-access/src/lib/facades/auth.facade.ts:42-189
FOCO: seguranca
```
→ HTML com fluxo SVG do refresh, antes/depois (se houver mudança), armadilhas (race conditions em refresh paralelo).

### Pós-bug
```
TOPICO: "bug WORK-1234: dropdown de stores ficou vazio após login"
NIVEL: intermediario
FOCO: bug-investigation
```
→ HTML com timeline do bug, hipóteses, evidências, fix aplicado, teste regressão.

### Arquitetura
```
TOPICO: "Facade Pattern vs Service no Angular"
NIVEL: avancado
FOCO: arquitetura
```
→ HTML com comparação lado a lado, quando usar cada um, exemplos do nosso código.

---

## Anti-padrões deste prompt

- ❌ Pedir explicação genérica sem `[TOPICO]` específico → vira essay de Wikipedia
- ❌ `[NIVEL]: avancado` quando o leitor é iniciante → frustração
- ❌ Listar 20 arquivos em `[ARQUIVOS]` → estoura contexto. Use sub-agente `explorer`.
- ❌ Misturar 3 tópicos em 1 HTML → fica longo demais. Gere 3 HTMLs.

---

## Convenção de Arquivamento

Salve os HTMLs gerados em:

```
.agent/Plans/explained/[YYYY-MM-DD]_[topico-kebab].html
```

Para serem versionados junto com o repo e servirem de memória institucional.
