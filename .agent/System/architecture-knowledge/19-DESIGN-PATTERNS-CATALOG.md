# Design Patterns Catalog (Catalogo de Padroes de Projeto)

## Visao Geral

Este catalogo lista **todos os design patterns** identificados na arquitetura, com contexto de quando e por que usa-los.

---

## Padroes Criacionais

### 1. Factory Method (Provider Functions)

**Onde**: Criacao de providers para DI
**Por que**: Desacopla a criacao de objetos da configuracao do framework

```typescript
function provideCoursesMongoService() {
  return createServiceProvider(
    CoursesService,          // Abstracoes
    CoursesMongoServiceImpl, // Implementacao
    [getModelToken('Course')]
  );
}
```

### 2. Abstract Factory (createServiceProvider / createUseCaseProvider)

**Onde**: Helpers genericos para criar providers
**Por que**: Uma unica factory cria providers para qualquer tipo

```typescript
function createServiceProvider<A extends Abstract, T extends Type>(
  abstraction: A,
  implementation: T,
  deps: any[]
) { /* ... */ }
```

### 3. Builder (DocumentBuilder / Swagger)

**Onde**: Configuracao de Swagger
**Por que**: Construcao fluente de objetos complexos

```typescript
const config = new DocumentBuilder()
  .setTitle('API')
  .addBearerAuth()
  .setContact('Author', 'url', 'email')
  .build();
```

---

## Padroes Estruturais

### 4. Facade

**Onde**: EntityFacade, AuthenticationFacade, LayoutFacade
**Por que**: Interface simplificada para um subsistema complexo (Use Cases + State)

```typescript
class CourseFacade extends State<CourseState> {
  // Esconde complexidade de use cases, state e subscriptions
  load() { ... }
  create(data) { ... }
  setFilter(filter) { ... }
}
```

### 5. Adapter

**Onde**: MongoServiceImpl, HttpServiceImpl, LocalServiceImpl
**Por que**: Traduz interface do dominio para interface da infraestrutura

```typescript
// Port (dominio)
abstract class CoursesService { abstract create(): Promise<Course>; }

// Adapter (infra)
class CoursesMongoServiceImpl extends MongoService<Course> {
  // Traduz operacoes de dominio para MongoDB
}
```

### 6. Proxy (HTTP Interceptor)

**Onde**: authInterceptor, loaderInterceptor
**Por que**: Intercepta e modifica requests/responses transparentemente

```typescript
const authInterceptor: HttpInterceptorFn = (req, next) => {
  const token = localStorage.getItem('accessToken');
  return next(token ? req.clone({ headers: ... }) : req);
};
```

### 7. Composite (Module Composition)

**Onde**: AppModule, provider arrays
**Por que**: Trata um grupo de objetos como um unico

```typescript
function provideAcademy() {
  return [...provideServices(), ...provideUseCases(), ...provideFacades()];
}
```

### 8. Decorator (NestJS/Angular Decorators)

**Onde**: @Allowed(), @Roles(), @User(), @ApiPage()
**Por que**: Adiciona comportamento a metodos/classes sem modificar o codigo

```typescript
@Allowed()          // Marca como publico
@ApiBearerAuth()    // Documenta auth
@Roles(['manager']) // Define roles
```

---

## Padroes Comportamentais

### 9. Command (Use Case Pattern)

**Onde**: Todos os Use Cases
**Por que**: Encapsula uma operacao como objeto com execute()

```typescript
interface UseCase<I, O> {
  execute(input: I): Promise<O> | Observable<O>;
}

class CreateCourseUseCase implements UseCase<EditableCourse, Course> {
  execute(data: EditableCourse) { return this.service.create(data); }
}
```

### 10. Strategy

**Onde**: HttpService vs LocalService vs MongoService
**Por que**: Algoritmos intercambiaveis (mesma interface, comportamento diferente)

```typescript
// Strategy 1: HTTP
{ provide: CourseService, useClass: CourseHttpServiceImpl }

// Strategy 2: Local Storage
{ provide: CourseService, useClass: CourseLocalServiceImpl }

// Consumidor nao muda:
constructor(private service: CourseService) {}
```

### 11. Template Method

**Onde**: MongoService com hooks (applyFilter, applyPopulate, etc.)
**Por que**: Define esqueleto do algoritmo, subclasses customizam passos

```typescript
class MongoService<T> {
  async find(params) {
    const filter = this.applyFilter(params.filter);  // Hook
    const sort = this.applySort(params.sort);          // Hook
    let query = this.model.find(filter).sort(sort);
    query = this.applyPopulate(query);                 // Hook
    return query.exec();
  }

  // Hooks para override
  protected applyFilter(f) { return f; }
  protected applyPopulate(q) { return q; }
}
```

### 12. Observer (RxJS / BehaviorSubject)

**Onde**: State management, route params, form value changes
**Por que**: Notificar interessados quando estado muda

```typescript
class State<T> {
  private state$ = new BehaviorSubject<T>(initial);

  protected select<R>(selector: (s: T) => R): Observable<R> {
    return this.state$.pipe(map(selector), distinctUntilChanged());
  }
}
```

### 13. Chain of Responsibility (Guards)

**Onde**: AuthGuard → RolesGuard → Controller permissions
**Por que**: Processa request em cadeia, cada elo decide se passa ou rejeita

```
Request → AuthGuard → RolesGuard → Controller
            │             │           │
        Verifica JWT  Verifica Role  Verifica Owner
```

### 14. Mediator (Controller / Facade)

**Onde**: Controllers delegam para Facades, que delegam para Use Cases
**Por que**: Centraliza comunicacao entre objetos

```
Controller → Facade → Use Case → Service → Database
```

### 15. State (State Machine Pattern)

**Onde**: AuthenticationFacade (loading, sended, auth states)
**Por que**: Gerencia transicoes de estado de forma previsivel

```typescript
// Estados possiveis
{ loading: false, sended: false, auth: null }  // Inicial
{ loading: true, sended: false, auth: null }   // Enviando codigo
{ loading: false, sended: true, auth: null }   // Codigo enviado
{ loading: false, sended: false, auth: {...} } // Autenticado
```

---

## Padroes Arquiteturais

### 16. Hexagonal Architecture (Ports & Adapters)

**Onde**: Toda a estrutura domain ↔ data
**Por que**: Isola dominio de infraestrutura

### 17. Clean Architecture (Layered)

**Onde**: Camadas api → domain → data → feature → app
**Por que**: Dependencias apontam para dentro

### 18. CQRS Lite (Command Query Separation)

**Onde**: Use Cases separados por operacao (Create vs Find)
**Por que**: Cada operacao tem sua propria classe e logica

### 19. Repository Pattern

**Onde**: EntityService abstrato implementado por MongoService/HttpService
**Por que**: Abstrai acesso a dados

### 20. Module Pattern (Feature Modules)

**Onde**: Feature shells com routing e providers isolados
**Por que**: Encapsula feature completa como unidade independente

---

## Padroes de UI

### 21. Container/Presentational

**Onde**: *Container (smart) + *Component (dumb)
**Por que**: Separa logica de apresentacao

### 22. Sheet/Dialog Pattern

**Onde**: CreateAlbumSheet, UserPhotoDialog
**Por que**: Fluxos de interacao isolados com retorno tipado

```typescript
class CreateAlbumSheet extends SheetComponent<EditableAlbum> {
  onSubmit() {
    this.close(this.form.getRawValue()); // Retorno tipado
  }
}
```

### 23. Typed Form Pattern

**Onde**: UserForm, EventForm, AlbumForm
**Por que**: Formularios com seguranca de tipos completa

---

## Padroes de Infraestrutura

### 24. Dependency Injection

**Onde**: Todo o projeto
**Por que**: Inversao de controle, testabilidade

### 25. Barrel Export Pattern

**Onde**: index.ts em cada pacote
**Por que**: Controle de API publica

### 26. Environment Pattern

**Onde**: Env class, env.ts (dev/prod)
**Por que**: Configuracao por ambiente sem mudar codigo

### 27. Interceptor Pattern

**Onde**: HTTP interceptors (auth, loader)
**Por que**: Cross-cutting concerns transparentes

---

## Matriz de Aplicabilidade

| Pattern | Quando usar | Quando NAO usar |
|---------|------------|-----------------|
| **Facade** | Subsistema complexo com multiplos use cases | Operacao simples com 1 dependencia |
| **Adapter** | Integrar com infraestrutura externa | Logica interna do dominio |
| **Template Method** | Algoritmo com passos customizaveis | Algoritmo sem variacao |
| **Command** | Operacao encapsulada com input/output | Getter simples |
| **Strategy** | Multiplas implementacoes da mesma interface | Implementacao unica |
| **Observer** | Estado que muda ao longo do tempo | Dados estaticos |
| **Factory** | Criacao configuravel de objetos | Instanciacao direta |
| **Guard Chain** | Multiplas verificacoes de seguranca | Uma unica verificacao |
| **Decorator** | Adicionar metadata sem alterar classe | Logica complexa |

---

## Como Aplicar em Qualquer Projeto

1. **Identifique o problema** antes de escolher o pattern
2. **Nao force patterns** - use apenas quando resolvem um problema real
3. **Combine patterns** - Facade + State + Observer funcionam juntos
4. **Mantenha consistencia** - se usou Template Method em um service, use em todos
5. **Documente decisoes** - por que este pattern foi escolhido aqui
6. **Revise periodicamente** - patterns podem se tornar overhead se o contexto mudar
