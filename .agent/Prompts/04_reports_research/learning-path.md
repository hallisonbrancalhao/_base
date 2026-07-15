# learning-path — Roadmap de Aprendizado

> **Quando:** novo dev no time, ou você quer aprender domínio/tech nova **dentro do contexto do projeto**.
> **Output:** plano em N etapas com referências reais do repo.

## Contexto Mínimo
- @`.agent/README.md`
- @`.agent/Prompts/_context/doc_references.md`

## Prompt

````markdown
Gerar roadmap de aprendizado.

## Aluno
- **Background**: [linguagens/frameworks que já conhece]
- **Gap**: [o que NÃO conhece e precisa aprender]
- **Tempo disponível**: [horas/dia × dias]
- **Objetivo final**: [ex: "conseguir abrir PR sozinho em feature-X"]

## Output

```markdown
# Learning Path: [TÓPICO] — [DATA]

## Tempo total estimado: [X horas]

## Etapa 1: Fundamentos ([Y horas])
- **Objetivo**: [...]
- **Leituras**:
  - `.agent/System/xxx.md` (seção Y)
  - Doc externa: [URL]
- **Exercício prático**: [tarefa pequena no repo, ex: "ler `libs/foo/` e desenhar grafo de deps"]
- **Critério de pronto**: [verificável, ex: "explica em 2min o que é facade"]

## Etapa 2: [...]

## Etapa N: Aplicação
- **Tarefa real**: [PR pequeno em código real]
- **Mentor sugerido**: [@agente ou pessoa]

## Recursos
- 📚 Internos: `.agent/...`
- 🌐 Externos: [URLs com data de validade]
- 🛠️ Tools: `nx graph`, MCP servers
- 🎮 Sandboxes: `.agent/Prompts/03_design_prototypes/*` para experimentar

## Checkpoints de auto-avaliação
- [ ] [pergunta de verificação 1]
- [ ] [pergunta 2]
```

## Regras
- ✅ Referencie **arquivos reais** do repo (não genérico)
- ✅ Cada etapa tem **exercício prático**, não só leitura
- ✅ Tempo realista
- ❌ Não copie tutorial genérico de internet — adapte ao nosso stack
````

## Onde salvar
```
.agent/Plans/learning/[YYYY-MM-DD]_[topico]_[aluno].md
```
