# Repository Pattern & Generic Services

## Conceito

O Repository Pattern abstrai o acesso a dados atras de uma interface. O dominio trabalha com entidades, e o repositorio traduz isso para a tecnologia de persistencia (MongoDB, HTTP, localStorage, etc.).

Nesta arquitetura, o padrao e implementado via **EntityService generico** com **Template Method Pattern** para extensibilidade.

---

## Hierarquia de Abstracoes

```
┌─────────────────────────────────────┐
│  Interfaces Segregadas (SOLID I)    │
│  Create<T>, Find<T>, Update<T>...   │
└─────────────┬───────────────────────┘
              │ implements
┌─────────────▼───────────────────────┐
│  EntityService<T extends Entity>    │
│  (Classe Abstrata - Port generico)  │
└─────────────┬───────────────────────┘
              │ extends
┌─────────────▼───────────────────────┐
│  CoursesService (Port especializado)│
│  Adiciona metodos especificos       │
└─────────────┬───────────────────────┘
              │ extends (implementa)
┌─────────────▼───────────────────────┐
│  MongoService<T> (Adapter base)     │
│  Logica MongoDB reutilizavel        │
└─────────────┬───────────────────────┘
              │ extends
┌─────────────▼───────────────────────┐
│  CoursesMongoServiceImpl (Adapter)  │
│  Overrides especificos de Courses   │
└─────────────────────────────────────┘
```

---

## Interface Segregation (SOLID I)

Cada operacao CRUD e uma interface independente:

```typescript
interface Create<T extends Entity> {
  create(data: EditableEntity<T>): Promise<T>;
}

interface Find<T extends Entity> {
  find(params: QueryParams<T>): Promise<Page<T>>;
}

interface FindOne<T extends Entity> {
  findOne(id: string): Promise<T | null>;
}

interface Update<T extends Entity> {
  update(id: string, data: EditableEntity<T>): Promise<T | null>;
}

interface Delete<T extends Entity> {
  delete(id: string): Promise<T>;
}
```

**Beneficio**: Um servico pode implementar apenas `Find<T>` e `FindOne<T>` se so precisa de leitura.

---

## EntityService Generico

A classe abstrata base que compoe todas as interfaces:

### Server-side (Promise-based)

```typescript
abstract class EntityService<T extends Entity>
  implements Create<T>, Find<T>, FindOne<T>, Update<T>, Delete<T>
{
  abstract create(data: Omit<EditableEntity<T>, 'id'>): Promise<T>;
  abstract find(params: QueryParams<T>): Promise<Page<T>>;
  abstract findOne(id: string): Promise<T | null>;
  abstract findOneBy<P extends keyof T>(prop: P, value: T[P]): Promise<T | null>;
  abstract update(id: string, data: EditableEntity<T>): Promise<T | null>;
  abstract delete(id: string): Promise<T>;
}
```

### Client-side (Observable-based)

```typescript
abstract class EntityService<T extends Entity>
  implements Create<T>, Find<T>, FindOne<T>, Update<T>, Delete<T>
{
  abstract create(data: EditableEntity<T>): Observable<T>;
  abstract find(params: QueryParams<T>): Observable<Page<T>>;
  abstract findOne(id: string): Observable<T | null>;
  abstract update(id: string, data: EditableEntity<T>): Observable<T>;
  abstract delete(id: string): Observable<T>;
}
```

---

## Template Method Pattern (MongoService)

O `MongoService<T>` implementa o EntityService com MongoDB e expoe **hooks extensiveis**:

```typescript
abstract class MongoService<T> implements EntityService<T> {
  constructor(protected model: Model<T>) {}

  async find(params: QueryParams<T>): Promise<Page<T>> {
    const { page = 0, size = 10, filter, sort } = params;
    const skip = page * size;

    // HOOKS: Metodos que subclasses podem override
    const queryFilter = this.applyFilter(filter);
    const querySort = this.applySort(sort);

    let query = this.model
      .find(queryFilter)
      .sort(querySort)
      .skip(skip)
      .limit(size);

    // HOOK: Customizar population de referencias
    query = this.applyPopulate(query);

    const data = (await query.exec()).map(doc => doc.toJSON());
    const items = await this.model.countDocuments(queryFilter);
    const pages = Math.ceil(items / size);

    return { data, items, pages };
  }

  async create(data: EditableEntity<T>): Promise<T> {
    // HOOK: Transformar dados antes de persistir
    const parsed = this.applyEditableParser(data);
    return (await this.model.create(parsed)).toJSON();
  }

  // HOOKS EXTENSIVEIS (Template Method)
  protected applyFilter(filter: QueryFilter<T>): RootFilterQuery<T> {
    return { ...filter };
  }

  protected applySort(sort: QuerySort<T>): SortOrder {
    return createQuerySort(sort);  // 'asc' → 1, 'desc' → -1
  }

  protected applyPopulate(query: Query<T>): Query<T> {
    return query;  // Sem population por padrao
  }

  protected applyEditableParser(data: EditableEntity<T>): EditableEntity<T> {
    return data;  // Sem transformacao por padrao
  }
}
```

### Customizacao via Override

```typescript
class CoursesMongoServiceImpl extends MongoService<Course> {
  // Override: filtro com $in para arrays de IDs
  protected override applyFilter(filter: QueryFilter<Course>) {
    const ids = (filter.contributors ?? []) as string[];
    return ids.length
      ? createQueryFilterIn(filter, 'contributors', ...ids)
      : { ...filter };
  }

  // Override: popular referencias
  protected override applyPopulate(query: Query<Course>) {
    return query
      .populate('owner', 'name displayName')
      .populate('subjects')
      .populate('contributors', 'name displayName');
  }

  // Override: converter IDs de relacoes
  protected override applyEditableParser(data: EditableEntity<Course>) {
    return {
      ...data,
      owner: objectId(data.owner as string),
      subjects: (data.subjects as string[]).map(objectId),
    };
  }
}
```

---

## Query System

### QueryParams (Parametros de Busca)

```typescript
interface QueryParams<T> {
  page?: number;        // Pagina atual (0-based)
  size?: number;        // Itens por pagina (default: 10)
  sort?: QuerySort<T>;  // Ordenacao
  filter?: QueryFilter<T>; // Filtros
  location?: QueryLocation; // Geolocation query
}
```

### Paginacao

```typescript
// Calculo
const skip = page * size;
const items = await model.countDocuments(filter);
const pages = Math.ceil(items / size);

// Retorno
interface Page<T> {
  data: T[];     // Dados da pagina
  items: number; // Total de itens
  pages: number; // Total de paginas
}
```

### Filtros Type-Safe

```typescript
// Filtro generico - cada campo da entidade pode ser filtrado
type QueryFilter<T> = {
  [P in keyof T]?: T[P] extends object
    ? QueryFilter<T[P]> | string | boolean | RegExp
    : Partial<T[P]> | string | RegExp;
};

// Transformacao para MongoDB
function createQueryFilter(filter: object) {
  const result = {};
  for (const [key, value] of Object.entries(filter)) {
    if (typeof value === 'string') {
      result[key] = new RegExp(value, 'i');  // Case-insensitive regex
    } else {
      result[key] = value;
    }
  }
  return result;
}

// Filtro com $in (arrays de IDs)
function createQueryFilterIn(filter: object, field: string, ...ids: string[]) {
  const { [field]: _, ...rest } = filter;
  return {
    ...createQueryFilter(rest),
    [field]: { $in: ids.map(id => new ObjectId(id)) },
  };
}
```

### Ordenacao Type-Safe

```typescript
// Apenas campos escalares (nao objetos) podem ser ordenados
type NonObjectKeys<T> = {
  [K in keyof T]: T[K] extends object ? never : K;
}[keyof T];

type QuerySort<T> = {
  [P in keyof Pick<T, NonObjectKeys<T>>]?: SortDirection;
};

// Transformacao para MongoDB
function createQuerySort(sort: QuerySort<any>) {
  const result = {};
  for (const [key, value] of Object.entries(sort)) {
    result[key] = value === 'asc' ? 1 : -1;
  }
  return result;
}
```

### Queries Geoespaciais

```typescript
async findByLocation({ lat, lng, max, min }: LocationFilter) {
  return this.model.find({
    location: {
      $near: {
        $geometry: { type: 'Point', coordinates: [lat, lng] },
        $maxDistance: max,
        $minDistance: min,
      },
    },
  });
}
```

---

## Schema/Model Mapping (MongoDB)

### Schema Factory

```typescript
function createSchema<T>(SchemaClass: Type<T>): Schema<T> {
  const schema = SchemaFactory.createForClass(SchemaClass);

  // Virtual ID: _id → id
  schema.virtual('id').get(function() {
    return this._id.toString();
  });

  // Timestamps automaticos
  schema.set('timestamps', true);

  // JSON transform: remove _id, inclui virtuals
  schema.set('toJSON', {
    virtuals: true,
    transform: (doc, ret) => {
      delete ret._id;
      delete ret.__v;
      return ret;
    },
  });

  return schema;
}
```

### Schema Definition

```typescript
@Schema()
class CourseCollection extends Document implements Course {
  override id: string;  // Virtual

  @Prop({ required: true })
  title: string;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'UserCollection' })
  owner: UserCollection;

  @Prop([{ type: mongoose.Schema.Types.ObjectId, ref: 'SubjectCollection' }])
  subjects: SubjectCollection[];

  @Prop(raw({ min: { type: Number }, max: { type: Number } }))
  salary?: Range;

  @Prop({ type: PointSchema, index: '2dsphere' })
  location: PointCollection;
}

const CourseSchema = createSchema(CourseCollection);
```

---

## Adapters Alternativos

### HTTP Adapter (Frontend)

```typescript
abstract class HttpService<T> implements EntityService<T> {
  constructor(private http: HttpClient, private env: Env, private endpoint: string) {}

  create(data: EditableEntity<T>): Observable<T> {
    return this.http.post<T>(this.url, data);
  }

  find(params: QueryParams<T>): Observable<Page<T>> {
    return this.http.get<Page<T>>(this.url, {
      params: createQueryParams(params),  // Serializa para URLSearchParams
    });
  }
}
```

### Local Storage Adapter (Offline)

```typescript
abstract class LocalService<T extends Entity> implements EntityService<T> {
  constructor(private storage: StorageService, private key: string) {}

  create(data: EditableEntity<T>): Observable<T> {
    const entity = { ...data, id: crypto.randomUUID() } as T;
    const items = this.getAll();
    items.push(entity);
    this.storage.set(this.key, JSON.stringify(items));
    return of(entity);
  }

  find(params: QueryParams<T>): Observable<Page<T>> {
    const items = this.getAll();
    const filtered = params.filter
      ? items.filter(item => matchesFilter(item, params.filter))
      : items;
    const skip = (params.page ?? 0) * (params.size ?? 10);
    const data = filtered.slice(skip, skip + (params.size ?? 10));
    return of({
      data,
      items: filtered.length,
      pages: Math.ceil(filtered.length / (params.size ?? 10)),
    });
  }
}
```

---

## Como Aplicar em Qualquer Projeto

1. **Defina um EntityService<T> generico** com CRUD base
2. **Segregue interfaces** (Create, Find, Update, Delete) para flexibilidade
3. **Crie base classes por tecnologia** (MongoBase, HttpBase, etc.)
4. **Use Template Method Pattern** para hooks extensiveis
5. **Implemente queries type-safe** com generics (QueryFilter<T>, QuerySort<T>)
6. **Padronize paginacao** com Page<T> em todos os repositorios
7. **Use factory de schemas** para consistencia (IDs virtuais, timestamps, JSON transform)
