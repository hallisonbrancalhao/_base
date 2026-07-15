# Princípios de Context Engineering

> Baseado em [Anthropic — Effective Context Engineering for AI Agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents).
> Resumo aplicado ao monorepo `@base/source`.

---

## Definição

Context engineering = curadoria estratégica de tokens (informação) disponíveis ao LLM durante a inferência. É a evolução do prompt engineering: enquanto este escreve instruções discretas, aquele gerencia **continuamente** o que entra e sai da janela de contexto a cada turno.

---

## Princípio Fundamental

> "O menor conjunto possível de tokens de alto sinal que maximize a probabilidade do resultado desejado."

Contexto é recurso finito. Toda adição compete por atenção. **Lean, não curto.**

---

## Atenção é Limitada (Context Rot)

- Transformers têm n² relações entre tokens — atenção fica diluída em contexto longo
- Modelos têm menos experiência de treino com janelas extensas
- Performance degrada **gradualmente**, não bruscamente

**Implicação prática:** quanto mais carregamos no contexto, pior o desempenho. Carregar tudo "por garantia" piora resultados.

---

## System Prompt (Altitude Correta)

| Anti-padrão | Boa prática |
|-------------|-------------|
| If/else hardcoded e frágil | Seções organizadas (XML/Markdown) |
| Diretrizes vagas e abstratas | Sinais concretos e mínimos |
| Tudo num bloco gigante | `<background>`, `<instructions>`, `## Tool guidance` |

**Comece mínimo** no modelo mais forte; adicione clarificação só nos modos de falha observados.

---

## Tools (Contrato Agente ↔ Ambiente)

Boas tools são:
- Autocontidas e robustas a erro
- Claras quanto ao uso pretendido
- Token-efficient no retorno
- Mínimas em sobreposição

**Anti-padrão crítico**: toolset inchado com responsabilidades sobrepostas. "Se um humano não consegue dizer qual tool usar, o agente também não consegue."

---

## Examples (Few-shot Curado)

- Use **exemplos canônicos diversos** que mostram o comportamento esperado
- Não liste edge cases exaustivamente
- "Uma imagem vale mais que mil palavras" — vale para LLM também

---

## Recuperação Just-in-Time

> Mantenha **identificadores leves** (paths, URLs, queries) e carregue **sob demanda** via tools.

**Por quê:**
- Armazenamento eficiente
- Disclosure progressivo (descoberta incremental)
- Contexto auto-gerenciado focado no relevante
- Metadados (hierarquia, naming, timestamps) já guiam comportamento

**Aplicação no nosso monorepo:**
- Cite `.agent/System/xxx.md` em vez de inline-citar o arquivo
- Use `nx graph` em vez de listar todas as libs no prompt
- Use grep dinâmico em vez de carregar arquivos preemptivamente

**Híbrido:** pré-computar para velocidade + exploração autônoma para adaptabilidade.

---

## Tarefas Longas — 3 Técnicas

### 1. Compaction
Sumarize o histórico ao chegar perto do limite, reinicialize com sumário comprimido.
- Maximize **recall** primeiro
- Depois melhore **precision** removendo ruído
- Preserve: decisões arquiteturais, issues abertos, detalhes de implementação
- Limpe outputs redundantes de tools

### 2. Structured Note-Taking
Agentes escrevem notas persistentes em memória externa, recuperam quando precisam.
- Permite tracking de N tool calls sem inchar contexto

### 3. Sub-Agent Architectures
Sub-agentes especializados com **contextos limpos**, retornando sumários destilados (1k–2k tokens) ao coordenador.
- Separação de responsabilidades
- Exploração profunda fica isolada
- Lead agent só sintetiza

---

## Quando Usar Cada Técnica

| Tarefa | Técnica |
|--------|---------|
| Diálogo iterativo extenso | Compaction |
| Desenvolvimento com marcos claros | Note-taking |
| Pesquisa/análise complexa | Sub-agentes paralelos |

---

## Princípio Geral

> "Faça a coisa mais simples que funcionar."

Conforme os modelos melhoram, **reduza** engenharia prescritiva e dê mais autonomia operacional. Não engessar.

---

## Aplicação aos Templates desta Pasta

1. **Cada prompt aqui** começa com bloco mínimo (`_context/`) — só o necessário
2. **Referências, não cópias** — `.agent/System/xxx.md` em vez de colar conteúdo
3. **Sub-agentes paralelos** estão no template `02_code_review/audit-architecture.md` e em `01_two_way_interaction/debug-pair-complex.md`
4. **Compaction** é responsabilidade do harness; templates de tarefas longas alertam quando se aproximar do limite
5. **Output enxuto** — `output_format.md` proíbe filler
