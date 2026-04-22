---
name: performance-auditor
description: |
  Performance Audit - Detecta problemas de performance gerados por IA em código Angular/NestJS: N+1 queries, race conditions e memory leaks.
  TRIGGERS: audit performance, performance review, detectar N+1, race condition, memory leak, vazamento de memoria, relatório completo, validar performance, performance report, concurrency issue, subscription leak, queries redundantes
---

# @performance-auditor - Performance Audit

Audita riscos de performance introduzidos por código gerado por IA em monorepo Angular/Nx + NestJS. Foco em três detectores críticos: **N+1**, **Race Condition** e **Memory Leak**.

## Required Reading

Antes de auditar, consulte:
- `.agent/System/project_architecture.md`
- `.agent/System/angular_best_practices.md`
- `.agent/System/nx_architecture_rules.md`

---

## Invocation Pattern

```
@performance-auditor
  task: [escopo da auditoria]
  scope: affected | lib:[name] | all
  detectors: n-plus-one | race-condition | memory-leak | all
```

---

## Detector 1: N+1 Queries

> **Problema**: LLMs adoram fazer loop chamando query individual em vez de batch/join.
> Em dev com 100 requests funciona. Em prod com 10k requests × 20 queries = 200k queries na DB.

### Técnica Principal — Middleware Contador de Queries

Implementação de ~15 linhas no ORM que **conta queries por request** e alerta acima de um threshold.

#### NestJS + TypeORM (exemplo):

```typescript
@Injectable()
export class QueryCounterInterceptor implements NestInterceptor {
  intercept(ctx: ExecutionContext, next: CallHandler) {
    const counter = { n: 0 };
    getDataSource().subscribers.push({ afterLoad: () => counter.n++ });
    return next.handle().pipe(tap(() => {
      if (counter.n > 15) Logger.warn(`N+1 suspect: ${counter.n} queries/req`);
    }));
  }
}
```

Configurável por request ou global. Loga + marca para code review quando ultrapassa threshold (15 queries é um bom ponto de partida).

### Backend (NestJS / TypeORM) — além do middleware

- Uso de `findOne` dentro de loops (`for`, `map`, `forEach`) sobre coleções
- Repositories sem `relations` / `leftJoinAndSelect` quando a resposta precisa de dados relacionados
- `await` sequencial em `.map()` em vez de `Promise.all` com `IN`/`whereInIds`
- Resolvers GraphQL sem DataLoader

Grep patterns:
```bash
rg "for.*await.*find" libs/**/data-source
rg "\.map\(async.*find" libs/**/data-source
rg "findOne.*\n.*findOne" -U libs/**/data-source
```

### Frontend (Angular)

- `forkJoin` ou `switchMap` disparando 1 request por item de uma lista
- Facades que emitem múltiplos `httpClient.get` em cascata em vez de endpoint agregado
- `@for` template disparando method calls (`{{ getItem(id) }}`) que disparam HTTP

---

## Detector 2: Race Condition

> **Problema**: LLM vê `await`/`async` e monta sequência assíncrona sem pensar em 2 requests chegando ao mesmo tempo.
> Consequências: saldo negativo, double booking, contador errado, deadlock.

### Técnica Principal — Property-Based Testing

Teste tradicional: `input X → esperar output Y`. Property-based test: define uma **propriedade invariante** e a lib **bombardeia a função com inputs aleatórios** tentando violá-la.

Libs por stack:
- **Node/TypeScript**: `fast-check`
- **Python**: `hypothesis`
- **Java/Kotlin**: `jqwik`

#### Exemplo com `fast-check` (Node/TypeScript):

```typescript
import fc from 'fast-check';

test('saldo nunca fica negativo sob concorrência', () => {
  fc.assert(fc.property(fc.array(fc.integer()), async (ops) => {
    await Promise.all(ops.map(op => account.apply(op)));
    expect(account.balance).toBeGreaterThanOrEqual(0);
  }), { numRuns: 1000 });
});
```

### Backend (além do property test)

- Operações de escrita sem transação (`@Transactional()` / `QueryRunner`)
- Read-modify-write sem lock pessimista/otimista (`setLock('pessimistic_write')`)
- Contadores via `find → save` (deve ser `UPDATE ... SET x = x + 1`)
- Jobs/cron simultâneos sem idempotency key

### Frontend (Angular)

- `switchMap` vs `mergeMap` trocados em search/typeahead (mergeMap entrega resposta antiga depois)
- `signal.set(signal() + 1)` em vez de `signal.update(v => v + 1)`
- Múltiplos `subscribe` encadeados sem `combineLatest`/`withLatestFrom`
- `effect()` disparando HTTP sem proteção de reentrância

Grep patterns:
```bash
rg "mergeMap.*http" libs/**/data-access
rg "\.set\(.*\(\)\)" libs/**/data-access
```

---

## Detector 3: Memory Leak

> **Problema**: Em dev não percebe. Em prod a memória sobe de 200MB → 2GB até o OOM killer matar o processo.
> Causas comuns: queue que nunca esvazia, cache em memória sem TTL.

### Técnica Principal — Profiling de Processo Vivo

Monitorar CPU e memória **sem reiniciar ou instrumentalizar** o processo:

| Stack | Ferramenta | Uso |
|-------|------------|-----|
| Python | `py-spy` | `py-spy record -o profile.svg --pid <PID>` (flame graph) |
| Go | `pprof` | `go tool pprof http://localhost:6060/debug/pprof/heap` |
| Node | `--inspect` + Chrome DevTools | HEAP snapshot comparando 2 momentos |
| Browser (Angular) | Chrome DevTools → Memory | HEAP snapshot → comparar antes/depois |
| Android | LeakCanary | Detecção automática + Android Profiler |

**Fluxo de análise**:
1. Tirar snapshot 1 → executar ação repetidas vezes → snapshot 2
2. Se há objetos retidos na HEAP **sem referência ativa esperada**, é leak
3. Usar flame graph (py-spy, pprof) para ver onde memória está sendo alocada

### Frontend (Angular)

- `.subscribe(` sem `takeUntilDestroyed()` / `takeUntil(destroy$)`
- `EventListener` em `window`/`document` sem cleanup em `DestroyRef`
- `setInterval`/`setTimeout` sem `clearInterval`/`clearTimeout`
- `BehaviorSubject` em `providedIn: 'root'` acumulando itens sem `complete()`
- Arrays que só crescem (`items = [...items, ...new]`) em signals/serviços
- `computed()` referenciando closure externa que segura objeto pesado

Grep patterns:
```bash
rg "\.subscribe\(" libs/**/feature-* | rg -v "takeUntilDestroyed|take\(1\)"
rg "setInterval|addEventListener" libs/**/feature-*
```

### Backend

- Caches `Map`/`Object` globais sem TTL nem `maxSize`
- Event emitters com listeners registrados por request
- Streams (`createReadStream`) sem `pipe` finalizado / `destroy()`
- Filas (BullMQ, RabbitMQ) sem dead-letter nem limite de retries

---

## Output Format

```markdown
## Performance Audit Report

### Summary
- Files scanned: N
- Critical findings: N
- High findings: N
- Medium findings: N

### N+1 Findings
| File | Line | Severity | Evidence | Recommendation |
|------|------|----------|----------|----------------|
| ... | ... | critical | `await repo.findOne(id)` dentro de `.map` | Usar `findBy({ id: In(ids) })` |

### Race Condition Findings
| File | Line | Severity | Evidence | Recommendation |

### Memory Leak Findings
| File | Line | Severity | Evidence | Recommendation |

### Action Plan
1. [Prioridade crítica]
2. [Prioridade alta]
3. [Prioridade média]
```

---

## Regras de Saída

- Sempre reportar caminho absoluto do arquivo + número da linha
- Severidade: `critical` | `high` | `medium` | `low`
- Nunca sugerir refactor sem citar o código exato encontrado
- Para cada achado, sugerir snippet de correção com no máximo 5 instruções (seguindo padrão do projeto)
