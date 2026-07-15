# .agent/Prompts/ — Biblioteca de Prompts

> Biblioteca curada de prompts versionados para uso com Claude Code, Cursor, ou qualquer LLM com tool use. Estruturada segundo princípios de [context engineering da Anthropic](./\_meta/context_engineering_principles.md).

---

## Princípios (resumo)

1. **Menor conjunto de tokens de alto sinal** que maximize sucesso (Anthropic, 2025)
2. **Just-in-time retrieval** — referencie `.agent/System/*.md`, não copie conteúdo
3. **Sub-agentes paralelos** para investigações multi-arquivo (retorno ≤ 1500 tokens cada)
4. **Compaction** quando contexto longo: peça resumo antes que sature
5. **Examples > rules** quando possível (mostre, não descreva)

Detalhe completo: [`_meta/context_engineering_principles.md`](./_meta/context_engineering_principles.md).

---

## Estrutura

```
Prompts/
├── README.md                       ← VOCÊ ESTÁ AQUI
├── _context/                       ← Blocos reutilizáveis (just-in-time loading)
│   ├── tech_stack.md
│   ├── critical_rules.md
│   ├── doc_references.md
│   └── output_format.md
├── _meta/
│   ├── TEMPLATE_prompt.md          ← Base para criar novos prompts
│   └── context_engineering_principles.md
├── 01_two_way_interaction/         ← Conversacional, iterativo
├── 02_code_review/                 ← Entender + revisar
├── 03_design_prototypes/           ← Screenshot → código
└── 04_reports_research/            ← Investigar + documentar
```

---

## Índice por Caso de Uso

### 🗣️ Two-way Interaction (diálogo iterativo)

| Prompt | Quando |
|--------|--------|
| [debug-pair-simple](./01_two_way_interaction/debug-pair-simple.md) | Bug 1-2 arquivos, IA pergunta antes de propor |
| [debug-pair-complex](./01_two_way_interaction/debug-pair-complex.md) | Bug multi-arquivo com 3 sub-agentes paralelos |
| [refactor-dialog](./01_two_way_interaction/refactor-dialog.md) | Refactor incremental com aprovação por passo |
| [spec-clarify](./01_two_way_interaction/spec-clarify.md) | Esclarecer requisitos vagos → ata p/ PRD |
| [pair-architect](./01_two_way_interaction/pair-architect.md) | Co-design de arquitetura → ADR |

### 🔍 Code Review & Understanding

| Prompt | Quando |
|--------|--------|
| [review-pr](./02_code_review/review-pr.md) | Code review estruturado pass/fail |
| [explain-code](./02_code_review/explain-code.md) | Explicação textual em markdown |
| [**explain-html**](./02_code_review/explain-html.md) | **Explicação visual em HTML autocontido** ⭐ |
| [trace-execution](./02_code_review/trace-execution.md) | Trace temporal de runtime |
| [audit-architecture](./02_code_review/audit-architecture.md) | Audit via 3 sub-agentes paralelos |

### 🎨 Design & Prototypes

| Prompt | Quando |
|--------|--------|
| [01_design_system](./03_design_prototypes/01_design_system.md) | Extrair tokens + theme.ts de screenshot |
| [02_create_components](./03_design_prototypes/02_create_components.md) | Componente standalone de screenshot |
| [03_page_development](./03_design_prototypes/03_page_development.md) | Página inteira de screenshot/Figma |
| [04_design_handoff](./03_design_prototypes/04_design_handoff.md) | UX → PRD de dev |

### 📊 Reports, Research & Learning

| Prompt | Quando |
|--------|--------|
| [research-topic](./04_reports_research/research-topic.md) | Comparar N opções → recomendação |
| [generate-report](./04_reports_research/generate-report.md) | Relatório executivo de audit/perf/security |
| [adr-document](./04_reports_research/adr-document.md) | Registrar decisão arquitetural |
| [learning-path](./04_reports_research/learning-path.md) | Roadmap de onboarding |

---

## Como Usar

### 1. Escolha o prompt pelo caso de uso
Use a tabela acima ou navegue pela categoria.

### 2. Carregue só o contexto necessário
Cada prompt lista um bloco "Contexto Mínimo" — geralmente 2-4 arquivos do `_context/` + 1-2 de `.agent/System/`. **Não carregue tudo**.

### 3. Preencha as variáveis
Os blocos ```markdown contêm `[VARIAVEL]` em colchetes. Substitua antes de enviar.

### 4. Para tópicos complexos, divida em sub-agentes
Prompts marcados com "sub-agentes paralelos" já trazem a divisão. O coordenador só sintetiza.

### 5. Salve outputs persistentes
- ADRs: `.agent/Plans/adrs/`
- HTMLs explicativos: `.agent/Plans/explained/`
- Reports: `.agent/Plans/reports/`
- Learning paths: `.agent/Plans/learning/`

---

## Criar Novo Prompt

1. Copie `_meta/TEMPLATE_prompt.md`
2. Coloque na categoria correta (1-4)
3. Atualize a tabela neste README
4. Use **referências leves** (`@.agent/System/...`) em vez de copiar conteúdo

---

## Comandos Slash Relacionados

Os prompts desta pasta complementam os slash commands existentes (vide `.claude/`):

| Slash | Categoria correspondente |
|-------|--------------------------|
| `/plan WORK-xxxx` | Two-way (após `spec-clarify`) |
| `/spec` | Tasks/ (geração de spec executável) |
| `/orchestrate` | Two-way + Code Review (multi-task) |
| `/review` | Code Review |
| `/audit-report` | Code Review (audit-architecture) |
| `/pentest` | Code Review (security) |

---

**Última atualização**: 2026-05-13
**Versão**: 3.0.0 (context-engineering refactor)
