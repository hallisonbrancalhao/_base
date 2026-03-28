# Architecture Knowledge Base

Documentacao completa dos conceitos, teorias, metodologias e padroes de arquitetura extraidos de um projeto de referencia. **Todo o conteudo e generico e aplicavel a qualquer projeto.**

---

## Fundamentos Arquiteturais

| # | Documento | Descricao |
|---|-----------|-----------|
| 01 | [Clean Architecture](01-CLEAN-ARCHITECTURE.md) | Camadas concentricas, regra de dependencia, inversao de dependencia, separacao de concerns |
| 02 | [Domain-Driven Design](02-DOMAIN-DRIVEN-DESIGN.md) | Entidades, Value Objects, Aggregates, Bounded Contexts, Ubiquitous Language, Reference Pattern |
| 03 | [Use Case Pattern](03-USE-CASE-PATTERN.md) | Padrao Command com `execute()`, input/output tipados, organizacao, providers, client vs server |
| 04 | [Ports & Adapters](04-PORTS-AND-ADAPTERS.md) | Portas abstratas, adapters concretos, base classes extensiveis, troca de implementacao |

## Infraestrutura & Tecnicas

| # | Documento | Descricao |
|---|-----------|-----------|
| 05 | [Dependency Injection](05-DEPENDENCY-INJECTION.md) | Tokens, provider factories, composicao aditiva, modulos globais, forRoot pattern |
| 06 | [Repository Pattern](06-REPOSITORY-PATTERN.md) | EntityService generico, Template Method, query system, paginacao, schemas, adapters |
| 07 | [State Management](07-STATE-MANAGEMENT.md) | State base class, EntityFacade, selectors, commands, server facade, fluxo de dados |
| 08 | [Reactive Programming](08-REACTIVE-PROGRAMMING.md) | RxJS patterns, Signals, computed/effect, lifecycle management, async pipe |

## TypeScript & Qualidade

| # | Documento | Descricao |
|---|-----------|-----------|
| 09 | [Type Safety Patterns](09-TYPE-SAFETY-PATTERNS.md) | Generics com constraints, mapped types, conditional types, utility types, typed forms, error types |
| 10 | [Module Boundaries](10-MODULE-BOUNDARIES.md) | Tagging system, matriz de dependencias, ESLint enforcement, path aliases, client/server split |

## Organizacao & Estrutura

| # | Documento | Descricao |
|---|-----------|-----------|
| 11 | [Monorepo Architecture](11-MONOREPO-ARCHITECTURE.md) | Nx workspace, vertical slices, affected commands, cache, path aliases, composicao de apps |
| 12 | [Frontend Patterns](12-FRONTEND-PATTERNS.md) | Standalone components, OnPush, feature shell, route providers, template syntax, interceptors |
| 13 | [Backend Patterns](13-BACKEND-PATTERNS.md) | NestJS modules, controllers, guards, custom decorators, exception handling, bootstrap |

## Seguranca & Formularios

| # | Documento | Descricao |
|---|-----------|-----------|
| 14 | [Error Handling](14-ERROR-HANDLING.md) | Hierarquia de erros tipados, error maps, traducao para HTTP, validation pipe, fluxo completo |
| 15 | [Form Architecture](15-FORM-ARCHITECTURE.md) | TypedForm, form classes, FormArray, validacao dinamica, auto-save, ControlContainer |
| 16 | [Authentication & Authorization](16-AUTHENTICATION-AUTHORIZATION.md) | Passwordless, JWT, guards em cadeia, RBAC, interceptors, route guards |

## Automacao & DevOps

| # | Documento | Descricao |
|---|-----------|-----------|
| 17 | [Code Generation](17-CODE-GENERATION.md) | Nx generators, templates EJS, name transformation, barrel management, plugin structure |
| 18 | [Testing, CI/CD & DevOps](18-TESTING-CI-CD.md) | Jest, affected commands, GitHub Actions, Docker, deploy pipeline, commit convention |

## Referencia

| # | Documento | Descricao |
|---|-----------|-----------|
| 19 | [Design Patterns Catalog](19-DESIGN-PATTERNS-CATALOG.md) | 27 design patterns catalogados: criacionais, estruturais, comportamentais, arquiteturais, UI, infra |

---

## Mapa de Conceitos

```
                         ┌──────────────────────┐
                         │  CLEAN ARCHITECTURE  │ (01)
                         │  Regra de dependencia │
                         └──────────┬───────────┘
                    ┌───────────────┼───────────────┐
              ┌─────▼─────┐  ┌─────▼─────┐  ┌─────▼──────┐
              │    DDD     │  │  USE CASE  │  │ PORTS &    │
              │ Entidades  │  │  Pattern   │  │ ADAPTERS   │
              │ (02)       │  │  (03)      │  │ (04)       │
              └─────┬──────┘  └─────┬──────┘  └─────┬──────┘
                    │               │               │
              ┌─────▼───────────────▼───────────────▼──────┐
              │          DEPENDENCY INJECTION (05)          │
              │     Provider Factories, Token System        │
              └──────────────────┬─────────────────────────┘
                    ┌────────────┼────────────┐
              ┌─────▼─────┐ ┌───▼────┐ ┌─────▼──────┐
              │REPOSITORY │ │ STATE  │ │  REACTIVE  │
              │ Pattern   │ │ MGMT   │ │    PROG    │
              │ (06)      │ │ (07)   │ │   (08)     │
              └───────────┘ └────────┘ └────────────┘
                    │            │            │
              ┌─────▼────────────▼────────────▼──────┐
              │       TYPE SAFETY PATTERNS (09)       │
              │   Generics, Mapped Types, Utility     │
              └──────────────────┬───────────────────┘
                                 │
              ┌──────────────────▼───────────────────┐
              │      MODULE BOUNDARIES (10)          │
              │   ESLint enforcement, Tagging        │
              └──────────────────┬───────────────────┘
                    ┌────────────┼────────────┐
              ┌─────▼─────┐ ┌───▼────┐ ┌─────▼──────┐
              │ MONOREPO  │ │FRONTEND│ │  BACKEND   │
              │ (11)      │ │ (12)   │ │   (13)     │
              └───────────┘ └────────┘ └────────────┘
                    │            │            │
           ┌───────┼────────────┼────────────┼───────┐
     ┌─────▼─┐ ┌───▼──┐ ┌──────▼───┐ ┌──────▼─────┐│
     │ERRORS │ │FORMS │ │  AUTH    │ │CODE GEN   ││
     │ (14)  │ │ (15) │ │  (16)   │ │  (17)     ││
     └───────┘ └──────┘ └─────────┘ └───────────┘│
                                                   │
              ┌───────────────────────────────────▼─┐
              │       TESTING & CI/CD (18)          │
              │     Jest, GitHub Actions, Docker    │
              └────────────────────────────────────┘
                                 │
              ┌──────────────────▼───────────────────┐
              │    DESIGN PATTERNS CATALOG (19)      │
              │  27 patterns identificados e usados  │
              └──────────────────────────────────────┘
```

---

## Como Usar Esta Documentacao

1. **Para entender a arquitetura**: Comece pelos documentos 01-04 (fundamentos)
2. **Para implementar**: Siga 05-08 (infraestrutura e tecnicas)
3. **Para garantir qualidade**: Leia 09-10 (type safety e boundaries)
4. **Para organizar o projeto**: Veja 11-13 (monorepo, front, back)
5. **Para features especificas**: Consulte 14-16 (erros, forms, auth)
6. **Para automatizar**: Use 17-18 (generators, CI/CD)
7. **Como referencia rapida**: Consulte 19 (catalogo de patterns)

Cada documento e **autocontido** e termina com uma secao **"Como Aplicar em Qualquer Projeto"** com passos praticos.
