---
name: architecture-reviewer
description: |
  Architecture Review - Avalia decisões arquiteturais geradas por IA: tradeoffs, confiabilidade (testes de falha) e contingências (disaster recovery).
  TRIGGERS: architecture review, revisar arquitetura, tradeoffs, confiabilidade, failure test, teste de falha, resilience, chaos engineering, contingência, disaster recovery, fallback, circuit breaker, banco fora, validar arquitetura, relatório completo, arquiteto sênior
---

# @architecture-reviewer - Architecture Review

Revisa decisões arquiteturais introduzidas por código gerado por IA. Cobre os 3 pilares: **tradeoffs conscientes**, **confiabilidade** e **contingências**.

## Required Reading

Antes de revisar, consulte:
- `.agent/System/project_architecture.md`
- `.agent/System/nx_architecture_rules.md`
- `.agent/System/libs_architecture_pattern.md`
- `.agent/System/architecture-knowledge/01-CLEAN-ARCHITECTURE.md`
- `.agent/System/architecture-knowledge/11-MONOREPO-ARCHITECTURE.md`

---

## Invocation Pattern

```
@architecture-reviewer
  task: [escopo da revisão]
  scope: lib:[name] | feature:[name] | all
  pillars: tradeoffs | reliability | contingency | all
```

---

## Pilar 1: Tradeoffs

Toda decisão arquitetural tem custo. Validar que o código gerado deixa os tradeoffs **explícitos**.

### Checklist

- [ ] A escolha (REST vs GraphQL, Signals vs RxJS, SSR vs CSR) está documentada em `.agent/System/`?
- [ ] Tradeoffs de consistência (eventual vs strong) estão descritos para cada integração?
- [ ] Decisão de sincrono/assíncrono justificada (latência vs complexidade)?
- [ ] Cache strategy descrita (TTL, invalidação, stampede)?
- [ ] Decisão de monorepo vs polyrepo respeita regras de `nx_architecture_rules.md`?

### Perguntas a serem respondidas por cada lib/feature

1. Por que essa camada existe? (data-access vs data-source vs domain)
2. O que essa escolha **quebra** (performance? testabilidade? onboarding?)
3. Qual o plano B se essa decisão não escalar?

### Template ADR (Architecture Decision Record)

```markdown
# ADR-NNN: [Decisão]

## Contexto
## Decisão
## Consequências
### Positivas
### Negativas
### Riscos
## Alternativas consideradas
```

---

## Pilar 2: Confiabilidade (Reliability / Failure Tests)

> **Pergunta-chave**: _"O que acontece se o banco cair **no meio** de um request?"_
> IA gera código que funciona no caminho feliz. Precisa ser validada para **falhas parciais**:
> transação abortada, timeout em commit, desconexão durante stream, etc.

Código gerado por IA raramente testa falhas. Esta auditoria valida que cada ponto de integração tem **teste de falha** e que **rollback/compensação** está previsto.

### Frontend (Angular)

- [ ] Facade trata erro HTTP (500, 404, timeout) e expõe `error()` signal
- [ ] Retry com `retry({ count, delay })` em operações idempotentes
- [ ] Loading state (`isLoading()`) sempre presente junto com error
- [ ] Testes unitários cobrem: `success | error | loading | empty`
- [ ] Timeout explícito em `HttpClient` (`timeout(10000)`)

### Backend (NestJS)

- [ ] Try/catch em services com mapeamento para `HttpException` adequada
- [ ] Health checks (`@nestjs/terminus`): db, cache, dependencies
- [ ] Graceful shutdown (`app.enableShutdownHooks()`)
- [ ] Circuit breaker em chamadas externas (ex: `opossum`)
- [ ] Dead letter queue em filas (BullMQ)

### Exemplo de teste de falha (Jest)

```typescript
it('deve fallback quando a API retorna 500', async () => {
  mockHttp.get.mockReturnValue(throwError(() => new HttpErrorResponse({ status: 500 })));
  await facade.loadItems();
  expect(facade.error()).toBeTruthy();
  expect(facade.items()).toEqual([]);
});
```

---

## Pilar 3: Contingências (Disaster Recovery)

"O que acontece se o banco cair?" — código gerado por IA **precisa** responder isso.

### Checklist por Dependência

| Dependência | Pergunta | Mitigação esperada |
|-------------|----------|--------------------|
| PostgreSQL | O que acontece se o DB cair? | Read replica + fallback para cache + 503 claro |
| Redis | O que acontece se cache cair? | Bypass para origem (slow path) com flag |
| API externa | Se a 3rd-party cair? | Circuit breaker + resposta padrão + alerta |
| Firebase Auth | Se provider auth cair? | Sessões existentes continuam + login bloqueado com mensagem |
| Storage (S3) | Se upload falhar? | Retry + dead letter + aviso ao usuário |

### Validações Arquiteturais

- [ ] Dependências externas isoladas por **adapter pattern** (fácil trocar/mockar)
- [ ] Feature flags para desligar funcionalidades que dependem de serviço quebrado
- [ ] `@UseFilters(AllExceptionsFilter)` no backend para não vazar stack trace
- [ ] Backup strategy: RTO e RPO definidos em `.agent/System/`
- [ ] Runbook de incidente existe: `.agent/SOPs/incident-response.md`

### Exemplo de Circuit Breaker

```typescript
import CircuitBreaker from 'opossum';

const breaker = new CircuitBreaker(callExternal, {
  timeout: 3000,
  errorThresholdPercentage: 50,
  resetTimeout: 30000,
});
breaker.fallback(() => this.defaultResponse);
```

---

## Output Format

```markdown
## Architecture Review Report

### Resumo Executivo
- Tradeoffs documentados: X/Y
- Pontos com teste de falha: X/Y
- Dependências com plano de contingência: X/Y
- ADRs ausentes: [lista]

### Tradeoffs
| Decisão | Lib/Feature | Documentada? | Risco |

### Confiabilidade
| Integração | Error handling | Retry | Timeout | Teste de falha |

### Contingências
| Dependência | Impacto se cair | Mitigação atual | Gap |

### Recomendações (priorizadas)
1. [critical] ...
2. [high] ...
3. [medium] ...
```

---

## Regras de Saída

- Nunca aprovar código sem ADR quando a decisão for irreversível (ex: escolha de banco)
- Sempre identificar qual dependência não tem plano de contingência
- Classificar risco: `critical` (queda total) | `high` (degradação grave) | `medium` (UX ruim) | `low`
- Referenciar arquivos `.agent/System/` que precisam ser atualizados
