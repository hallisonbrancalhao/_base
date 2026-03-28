# Clean Architecture & Arquitetura Hexagonal

## O Que e Por Que

Clean Architecture (Robert C. Martin) e Arquitetura Hexagonal (Alistair Cockburn) sao abordagens que organizam codigo em camadas concentricas onde **dependencias sempre apontam para dentro** - da infraestrutura para o dominio, nunca o contrario.

O objetivo central: **o dominio (regras de negocio) nao conhece nem depende de frameworks, bancos de dados, APIs ou interfaces de usuario**. Isso garante que a logica de negocio seja testavel, portavel e resiliente a mudancas tecnologicas.

---

## Principio Fundamental: Regra de Dependencia

```
┌──────────────────────────────────────────────────────────┐
│  APP (Bootstrap, Configuracao, Composicao)               │
│  ┌────────────────────────────────────────────────────┐  │
│  │  FEATURE (Paginas, Containers, Rotas)              │  │
│  │  ┌──────────────────────────────────────────────┐  │  │
│  │  │  DATA (Repositories concretos, HTTP, DB)     │  │  │
│  │  │  ┌────────────────────────────────────────┐  │  │  │
│  │  │  │  DOMAIN (Entidades, Use Cases, Ports)  │  │  │  │
│  │  │  │  ┌──────────────────────────────────┐  │  │  │  │
│  │  │  │  │  API (Interfaces, Contratos)     │  │  │  │  │
│  │  │  │  └──────────────────────────────────┘  │  │  │  │
│  │  │  └────────────────────────────────────────┘  │  │  │
│  │  └──────────────────────────────────────────────┘  │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

**Regra**: Cada camada so pode importar da camada imediatamente interna (ou mais internas). Nunca da camada externa.

---

## As Camadas em Detalhe

### 1. API Layer (Nucleo)
- **Conteudo**: Interfaces TypeScript, tipos, enums, constantes, contratos
- **Responsabilidade**: Definir a linguagem comum entre todas as camadas
- **Dependencias**: Nenhuma (zero imports externos)
- **Exemplo**: `Entity`, `UseCase<I, O>`, `Page<T>`, `QueryParams<T>`

### 2. Domain Layer
- **Conteudo**: Use Cases, Services abstratos, DTOs de dominio
- **Responsabilidade**: Regras de negocio puras
- **Dependencias**: Apenas API layer e utilitarios puros
- **Exemplo**: `CreateCourseUseCase`, `CoursesService` (abstrato)

### 3. Data Layer
- **Conteudo**: Implementacoes de repositorios, schemas de banco, mappers
- **Responsabilidade**: Traduzir entre dominio e infraestrutura
- **Dependencias**: Domain, API, Util
- **Exemplo**: `CoursesMongoServiceImpl`, `CourseSchema`

### 4. Feature Layer
- **Conteudo**: Componentes de UI, rotas, containers, formularios
- **Responsabilidade**: Orquestrar interacao do usuario com o dominio
- **Dependencias**: Data (facades), UI, Util, API
- **Exemplo**: `EventContainer`, `AccountFeatureShellRoutes`

### 5. App Layer
- **Conteudo**: Bootstrap, configuracao, composicao final
- **Responsabilidade**: Montar todas as pecas e iniciar a aplicacao
- **Dependencias**: Todas as camadas
- **Exemplo**: `AppModule`, `app.config.ts`, `main.ts`

---

## Inversao de Dependencia na Pratica

O principio mais importante: **camadas externas dependem de abstracoes definidas nas camadas internas**.

```
Dominio define:
  abstract class CoursesService {
    abstract create(data): Promise<Course>
    abstract find(params): Promise<Page<Course>>
  }

Infraestrutura implementa:
  class CoursesMongoServiceImpl extends CoursesService {
    create(data) { return this.model.create(data) }
    find(params) { return this.model.find(filter).skip(...) }
  }

Aplicacao conecta:
  { provide: CoursesService, useClass: CoursesMongoServiceImpl }
```

O Use Case recebe `CoursesService` no construtor - ele nao sabe (nem precisa saber) se por tras ha MongoDB, PostgreSQL, uma API HTTP ou um mock de teste.

---

## Beneficios Concretos

| Beneficio | Como se manifesta |
|-----------|-------------------|
| **Testabilidade** | Use Cases testados com mocks simples das portas |
| **Portabilidade** | Trocar MongoDB por PostgreSQL = implementar novo adapter |
| **Paralelismo** | Times podem trabalhar em camadas diferentes simultaneamente |
| **Clareza** | Cada arquivo tem responsabilidade clara e previsivel |
| **Manutencao** | Mudancas em infraestrutura nao propagam para dominio |

---

## Anti-Patterns a Evitar

1. **Importar framework no dominio**: Use Cases nao devem importar decorators do NestJS ou Angular
2. **Logica de negocio no controller**: Controllers devem apenas delegar para facades/use cases
3. **Entidades com metodos de persistencia**: Entidades sao estruturas de dados, nao Active Record
4. **Dependencia circular entre camadas**: Se A depende de B e B de A, a separacao falhou
5. **Skip de camadas**: Feature importando diretamente do Domain (sem passar pela Data)

---

## Como Aplicar em Qualquer Projeto

1. **Defina seus contratos primeiro**: Crie interfaces/tipos antes de implementar
2. **Crie a camada de dominio sem framework**: Use Cases como classes puras com `execute()`
3. **Use classes abstratas como Ports**: O dominio define O QUE precisa, nao COMO
4. **Implemente adapters por tecnologia**: Um adapter MongoDB, um HTTP, um mock para testes
5. **Componha via DI**: Use injecao de dependencia para conectar ports a adapters
6. **Enforce com lint rules**: Configure regras de lint para impedir imports ilegais

---

## Diferenca: Clean Architecture vs Hexagonal

| Aspecto | Clean Architecture | Hexagonal |
|---------|-------------------|-----------|
| **Foco** | Camadas concentricas | Ports & Adapters |
| **Terminologia** | Entities, Use Cases, Controllers | Domain, Ports, Adapters |
| **Metafora** | Cebola com camadas | Hexagono com portas |
| **Aplicacao** | Complementares - usam-se juntas |

Na pratica, **a implementacao combina ambas**: camadas concentricas da Clean Architecture com o conceito de Ports (interfaces abstratas) e Adapters (implementacoes concretas) da Hexagonal.
