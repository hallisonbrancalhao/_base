# Regras fundamentais do projeto

## 🚫 REGRAS CRÍTICAS — Não negociáveis

### 1. DTOs com decorators são EXCLUSIVAMENTE backend

Frontend (qualquer `data-access`, `feature-*`, `ui-*`, `apps/web|mobile`) NUNCA importa `*.dto.ts` que contenha decorators de `class-validator`/`class-transformer`. Esses decorators chamam `Reflect.getMetadata` em runtime e quebram o boot do app no browser.

**FE consome:** `interfaces/*.interface.ts`, `enums/`, `types/`, `schemas/` (Zod).
**FE proibido:** `dtos/*.dto.ts`, `dtos/*.decorator.ts`, e os pacotes `class-validator` / `class-transformer`.

**Sincronia:** toda classe DTO/Entity do BE faz `implements IXxx`.

**Enforcement:** `bannedExternalImports: ['class-validator', 'class-transformer']` para tags `type:data-access`, `type:feature`, `type:ui`, `type:app` — ver `nx_architecture_rules.md`.

→ Detalhes em [interface-dto-architecture.md](./interface-dto-architecture.md).

### 2. Web é signal-first SEM zone.js

`apps/web` usa `provideZonelessChangeDetection()`. Proibido `NgZone`, `zone.js`, `setTimeout` para forçar CD. Tudo via `signal()`, `computed()`, `effect()`, `input()`, `output()`.

---

## Antes de começar qualquer implementação, leia o arquivo abaixo para entender a estrutura atual da documentação do projeto e as diretrizes para assistentes de IA.
- [Boas Práticas para Arquivos Barrel](./barrel_best_practices.md)
- [Libs Rules](./libs_architecture_pattern.md)
- [Padrões DTO e Interface](./interface-dto-architecture.md)


## 🔄 Documentation Workflow

```
Implement Feature
    ↓
Update System/features_overview.md
    ↓
Create/Update PRD in Tasks/
    ↓
Create SOP if new process
    ↓
Update this README
```

---
