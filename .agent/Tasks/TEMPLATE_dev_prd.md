---
id: DEV_PRD_WORK_XXXX
task_id: WORK-XXXX
status: aguardando-review
type: bug | enhancement | feature
priority: P2
complexity: M
created: YYYY-MM-DD
modules: []
---

# WORK-XXXX: [Titulo da Task]

---

## Contexto

[Descricao clara do que acontece hoje, qual o problema ou qual a oportunidade.
Para bugs: qual o comportamento atual vs esperado.
Para enhancements: o que existe hoje e o que precisa melhorar.
Para features: por que essa feature e necessaria agora.]

---

## Analise do Agente

### Classificacao

| Aspecto | Detalhe |
|---------|---------|
| Tipo | bug / enhancement / feature |
| Root cause (se bug) | [descricao da causa raiz] |
| Modulos relacionados | [lista de mod_*.md consultados] |
| Arquivos-chave | [lista dos arquivos mais relevantes] |

### Artefatos Existentes

| Artefato | Modulo | Tipo | Acao Recomendada |
|----------|--------|------|------------------|
| [nome] | [modulo] | facade / service / component / dto | reutilizar / estender / nenhuma |

### Gaps Identificados (a criar)

| Artefato | Tipo | Localizacao Sugerida | Justificativa |
|----------|------|---------------------|---------------|
| [nome] | facade / service / component / dto | `libs/scope/lib/path` | [por que criar] |

### Conflitos Potenciais

| Artefato / Regra | Modulo | Descricao do Conflito |
|------------------|--------|-----------------------|
| [nome] | [modulo] | [descricao] |

_(Se nenhum conflito: "Nenhum conflito identificado.")_

---

## Decisoes Tomadas

| # | Decisao | Rationale | Alternativa Descartada |
|---|---------|-----------|------------------------|
| 1 | [o que foi decidido] | [por que essa escolha] | [o que nao foi escolhido e por que] |
| 2 | [decisao] | [rationale] | [alternativa] |

---

## Estrategia de Implementacao

### Etapa 1: [Nome da etapa]
- **O que**: [descricao objetiva]
- **Onde**: `libs/scope/lib/path`
- **Tipo de mudanca**: criar / modificar / deletar
- **Impacto**: [arquivos afetados]

### Etapa 2: [Nome da etapa]
- **O que**: [descricao]
- **Onde**: `libs/scope/lib/path`
- **Tipo de mudanca**: criar / modificar / deletar
- **Impacto**: [arquivos afetados]

### Etapa 3: [Nome da etapa]
...

---

## Riscos

| Risco | Probabilidade | Impacto | Mitigacao |
|-------|:------------:|:-------:|-----------|
| [descricao do risco] | baixa / media / alta | baixo / medio / alto | [como mitigar] |

---

## Checklist de Aprovacao

Revise cada item antes de aprovar esta PRD:

- [ ] A analise do contexto esta correta
- [ ] Os artefatos reutilizaveis estao corretos (nada foi ignorado)
- [ ] Os gaps identificados fazem sentido (nada desnecessario)
- [ ] A estrategia de implementacao e viavel
- [ ] As decisoes tomadas sao razoaveis
- [ ] Os riscos estao cobertos
- [ ] Pronta para gerar spec

---

**Instrucoes para o reviewer:**

1. Leia cada secao com atencao
2. Se algo estiver errado, mude o status para `revisao-necessaria` e adicione comentarios inline
3. Se tudo estiver OK, mude o status para `aprovado`
4. Apos aprovacao, execute `/spec` para gerar a spec executavel
