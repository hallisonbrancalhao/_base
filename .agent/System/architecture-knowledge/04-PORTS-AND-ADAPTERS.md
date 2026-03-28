# Ports & Adapters (Portas e Adaptadores)

## Conceito

O padrao Ports & Adapters (tambem conhecido como Hexagonal Architecture) define que o dominio se comunica com o mundo externo atraves de **Ports** (interfaces abstratas) e **Adapters** (implementacoes concretas). O dominio nunca conhece a implementacao - apenas o contrato.

---

## Port (Porta)

Uma Port e uma **classe abstrata ou interface** que define um contrato. Ela e declarada **dentro do dominio** e implementada **fora dele**.

### Port Base Generico: EntityService

```typescript
// PORT: Contrato generico para qualquer entidade
// Compoe multiplas interfaces pequenas (Interface Segregation)
abstract class EntityService<T extends Entity>
  implements Create<T>, Find<T>, FindOne<T>, Update<T>, Delete<T>
{
  abstract create(data: EditableEntity<T>): Promise<T>;
  abstract find(params: QueryParams<T>): Promise<Page<T>>;
  abstract findOne(id: string): Promise<T | null>;
  abstract update(id: string, data: EditableEntity<T>): Promise<T | null>;
  abstract delete(id: string): Promise<T>;
}
```

### Ports Especializados por Dominio

```typescript
// Herda do generico e adiciona operacoes especificas
abstract class UsersService extends EntityService<User> {
  abstract findByName(name: string): Promise<User | null>;
  abstract findByEmail(email: string): Promise<User | null>;
  abstract updateCode(id: string, code: UserCode): Promise<User | null>;
  abstract updateRoles(id: string, roles: Roles): Promise<User | null>;
  abstract updateProfile(id: string, profile: UserProfile): Promise<User | null>;
}

// Port que nao segue o padrao EntityService
abstract class RSVPsService {
  abstract create(user: string, event: string, status: RSVPStatus): Promise<RSVP>;
  abstract findByEvent(event: string): Promise<RSVP[]>;
  abstract findConfirmedByEvent(event: string): Promise<RSVP[]>;
}
```

### Ports de Infraestrutura

```typescript
// Criptografia
abstract class CryptoService {
  abstract genSalt(): string;
  abstract hash(value: string, salt?: string | number): string;
  abstract compare(value: string, encrypted: string): boolean;
}

// JWT
abstract class JwtService {
  abstract sign<T>(value: T): string;
  abstract signAsync<T>(value: T): Promise<string>;
  abstract verify<T extends object>(token: string): T;
  abstract verifyAsync<T>(token: string): Promise<T>;
}

// Email
abstract class MailerService {
  abstract send(mail: SendMail): Promise<void>;
}

// Servico externo
abstract class GithubService {
  abstract getContributors(repo: string): Promise<GithubContributor[]>;
  abstract getIssues(repo: string): Promise<GithubIssue[]>;
}
```

---

## Adapter (Adaptador)

Um Adapter e uma **classe concreta** que implementa uma Port. Ele traduz entre o dominio e a infraestrutura.

### Adapter MongoDB (Server)

```typescript
// ADAPTER: Implementacao concreta com MongoDB/Mongoose
class CoursesMongoServiceImpl extends MongoService<Course> {
  constructor(model: Model<CourseCollection>) {
    super(model);
  }

  // Override hooks para customizar comportamento
  protected override applyFilter(filter: QueryFilter<Course>) {
    return createQueryFilterIn(filter, 'contributors', ...ids);
  }

  protected override applyPopulate(query: Query<Course>) {
    return query
      .populate('owner', 'name displayName')
      .populate('subjects');
  }
}
```

### Adapter HTTP (Client)

```typescript
// ADAPTER: Implementacao via HTTP para o frontend
class CourseHttpServiceImpl extends HttpService<Course> {
  constructor(http: HttpClient, env: Env) {
    super(http, env, 'courses');
  }
  // Herda create, find, findOne, update, delete do HttpService
}
```

### Adapter Local Storage (Client - Offline)

```typescript
// ADAPTER: Implementacao com localStorage (fallback/offline)
class CourseLocalServiceImpl extends LocalService<Course> {
  constructor(storage: StorageService) {
    super(storage, 'courses');
  }
  // Herda CRUD usando localStorage
}
```

---

## Base Classes para Adapters

Para evitar duplicacao, adapters herdam de classes base que encapsulam a infraestrutura:

### MongoService (Base para MongoDB)

```typescript
abstract class MongoService<T> implements EntityService<T> {
  constructor(protected model: Model<T>) {}

  async create(data: EditableEntity<T>): Promise<T> {
    return (await this.model.create(data)).toJSON();
  }

  async find(params: QueryParams<T>): Promise<Page<T>> {
    const { page = 0, size = 10, filter, sort } = params;
    const skip = page * size;

    const queryFilter = this.applyFilter(filter);
    const querySort = this.applySort(sort);

    let query = this.model.find(queryFilter).sort(querySort).skip(skip).limit(size);
    query = this.applyPopulate(query);

    const data = (await query.exec()).map(doc => doc.toJSON());
    const items = await this.model.countDocuments(queryFilter);
    const pages = Math.ceil(items / size);

    return { data, items, pages };
  }

  // Hooks extensiveis (Template Method Pattern)
  protected applyFilter(filter) { return { ...filter }; }
  protected applySort(sort) { return createQuerySort(sort); }
  protected applyPopulate(query) { return query; }
  protected applyEditableParser(data) { return data; }
}
```

### HttpService (Base para HTTP)

```typescript
abstract class HttpService<T> implements EntityService<T> {
  constructor(
    private http: HttpClient,
    private env: Env,
    private endpoint: string
  ) {}

  get url() { return `${this.env.api.url}/${this.endpoint}`; }

  create(data: EditableEntity<T>): Observable<T> {
    return this.http.post<T>(this.url, data);
  }

  find(params: QueryParams<T>): Observable<Page<T>> {
    return this.http.get<Page<T>>(this.url, {
      params: createQueryParams(params)
    });
  }

  findOne(id: string): Observable<T> {
    return this.http.get<T>(`${this.url}/${id}`);
  }
}
```

### LocalService (Base para localStorage)

```typescript
abstract class LocalService<T extends Entity> implements EntityService<T> {
  constructor(
    private storage: StorageService,
    private key: string
  ) {}

  create(data: EditableEntity<T>): Observable<T> {
    const entity = { ...data, id: crypto.randomUUID() } as T;
    const items = this.getAll();
    items.push(entity);
    this.storage.set(this.key, JSON.stringify(items));
    return of(entity);
  }
}
```

---

## Composicao: Conectando Ports a Adapters

A conexao acontece via **provider functions** que registram qual adapter implementa qual port:

```typescript
// Registrar MongoService como implementacao de CoursesService
function provideCoursesMongoService() {
  return createServiceProvider(
    CoursesService,              // PORT (abstract class)
    CoursesMongoServiceImpl,     // ADAPTER (concrete class)
    [getModelToken('CourseCollection')]  // Dependencias do adapter
  );
}

// Registrar HttpService como implementacao de CourseService
function provideCourseHttpService() {
  return createServiceProvider(
    CourseService,               // PORT
    CourseHttpServiceImpl,       // ADAPTER
    [HttpClient, Env]            // Dependencias
  );
}
```

**Factory helper**:
```typescript
function createServiceProvider<A extends Abstract, T extends Type>(
  abstraction: A,      // O que sera injetado (Port)
  implementation: T,   // O que sera instanciado (Adapter)
  dependencies: any[]  // O que o Adapter precisa
) {
  return {
    provide: abstraction,
    useFactory(...params) { return new implementation(...params); },
    inject: dependencies,
  };
}
```

---

## Fluxo Completo de uma Operacao

```
1. Controller recebe request HTTP
   ↓
2. Controller chama Facade
   ↓
3. Facade chama Use Case
   ↓
4. Use Case chama Port (abstract class)
   ↓
5. DI resolve Port → Adapter (concrete class)
   ↓
6. Adapter acessa infraestrutura (MongoDB/HTTP/LocalStorage)
   ↓
7. Resultado retorna pelo mesmo caminho
```

---

## Troca de Adapter em Runtime

O poder do padrao: trocar a implementacao sem alterar o dominio.

```typescript
// Desenvolvimento: usar localStorage
{ provide: CourseService, useClass: CourseLocalServiceImpl }

// Producao: usar HTTP
{ provide: CourseService, useClass: CourseHttpServiceImpl }

// Testes: usar mock
{ provide: CourseService, useClass: MockCourseService }
```

O Use Case, o Facade e o Controller nao mudam - apenas a configuracao de DI.

---

## Como Aplicar em Qualquer Projeto

1. **Defina Ports como classes abstratas** no dominio
2. **Crie um EntityService generico** com CRUD base
3. **Especialize ports por dominio** adicionando metodos especificos
4. **Crie base classes para adapters** (MongoBase, HttpBase, etc.)
5. **Implemente adapters por tecnologia**, herdando da base
6. **Use hooks extensiveis** (Template Method) para customizacao
7. **Conecte via provider functions** - nunca instancie adapters diretamente
8. **Teste com mock adapters** - zero dependencia de infraestrutura nos testes
