# pair-architect — Co-design de Arquitetura

> **Quando:** decisão arquitetural não-trivial (nova lib, novo padrão, integração externa).
> **Modo:** IA propõe ≥ 2 opções com tradeoffs, usuário escolhe.

## Contexto Mínimo
- @`.agent/Prompts/_context/critical_rules.md`
- @`.agent/System/libs_architecture_pattern.md`
- @`.agent/System/nx_architecture_rules.md`

## Prompt

````markdown
Decisão arquitetural em modo pair-architect.

## Contexto
- **Problema**: [DESCREVER O QUÊ E POR QUÊ]
- **Constraints**: [LIMITES TÉCNICOS / NEGÓCIO / PRAZO]
- **Restrições explícitas**: [SE HÁ ALGO QUE NÃO PODE]

## Modo de operação
1. Confirme entendimento em 1 parágrafo
2. Apresente **2-3 opções** de design, cada uma com:
   - Diagrama textual (camadas, libs, dependências)
   - Quais artefatos novos / modificados
   - Tradeoffs honestos (complexidade, performance, manutenção, time-to-market)
   - Reversibilidade (fácil/difícil voltar atrás)
   - Impacto em testes
3. Recomende **uma** com justificativa explícita
4. Após escolha: gere **ADR** (Architecture Decision Record) em markdown salvando em `.agent/Plans/adrs/[YYYY-MM-DD]_[topico].md`

## Restrições
- ✅ Honestidade: marque incertezas
- ✅ Sempre cite tradeoff (não só "vantagens")
- ❌ Não invente padrões fora do `.agent/System/`
- ❌ Não use "best practices" genéricas — aplique nosso contexto
````

## Output final

ADR no formato:
```markdown
# ADR-[N]: [Título]
Status: proposed | accepted | superseded
Data: YYYY-MM-DD

## Contexto
## Decisão
## Alternativas Consideradas
## Consequências (positivas + negativas)
## Reversibilidade
```
