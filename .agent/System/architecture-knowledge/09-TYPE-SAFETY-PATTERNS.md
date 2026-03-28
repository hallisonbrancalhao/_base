# Type Safety Patterns (Padroes de Seguranca de Tipos)

## Conceito

TypeScript vai muito alem de tipos basicos. Tipos avancados como **mapped types**, **conditional types**, **generics com constraints** e **utility types** garantem que erros sejam capturados em tempo de compilacao, nao em runtime.

---

## 1. Generic Constraints (Restricoes Genericas)

### Entity Constraint

```typescript
// T DEVE ter um campo 'id: string'
abstract class EntityService<T extends Entity> {
  abstract findOne(id: string): Promise<T | null>;
}

// Isso FUNCIONA:
class UserService extends EntityService<User> {}  // User tem id

// Isso FALHA em compilacao:
class BadService extends EntityService<{ name: string }> {}  // Sem id
```

### Key Constraint

```typescript
// P DEVE ser uma chave valida de T
abstract findOneBy<P extends keyof T>(prop: P, value: T[P]): Promise<T | null>;

// Uso type-safe:
service.findOneBy('email', 'user@mail.com');  // OK
service.findOneBy('xyz', 'value');             // ERRO: 'xyz' nao existe em User
```

---

## 2. Mapped Types (Tipos Mapeados)

### EditableEntity - Remover Metadados

```typescript
// Remove id, createdAt, updatedAt de qualquer entidade
type EditableEntity<T> = Omit<T, 'id' | 'createdAt' | 'updatedAt'>;

// User com id, name, email, createdAt, updatedAt
// EditableEntity<User> = { name, email }  (sem id e timestamps)
```

### Versao Recursiva (Deep Editable)

```typescript
type EditableEntity<T> = Omit<{
  [K in keyof T]: T[K] extends Array<infer U>
    // Se e array de entidades, aplica recursivamente
    ? U extends { id: string; createdAt: Date; updatedAt: Date }
      ? EditableEntity<Omit<U, 'createdAt' | 'updatedAt'>>[]
      : U[]
    // Se e entidade unica, aplica recursivamente
    : T[K] extends { id: string; createdAt: Date; updatedAt: Date }
    ? EditableEntity<Omit<T[K], 'createdAt' | 'updatedAt'>>
    // Strings podem aceitar string literal ou string generica
    : T[K] extends string
    ? T[K] | string
    : T[K];
}, 'createdAt' | 'updatedAt'>;
```

### QueryFilter - Filtro Type-Safe

```typescript
type QueryFilter<T> = {
  [P in keyof T]?: T[P] extends object
    ? QueryFilter<T[P]> | string | boolean | RegExp  // Recursivo para nested
    : Partial<T[P]> | string | RegExp;                // Scalares
};

// QueryFilter<User> permite:
// { name: 'john' }           OK
// { name: /john/i }          OK (RegExp)
// { contact: { email: 'x' }} OK (nested)
// { xyz: 'test' }            ERRO (campo inexistente)
```

### QuerySort - Apenas Campos Escalares

```typescript
// Filtra apenas chaves cujo valor NAO e objeto
type NonObjectKeys<T> = {
  [K in keyof T]: T[K] extends object ? never : K;
}[keyof T];

// Pega apenas campos escalares
type OnlyChildren<T> = Pick<T, NonObjectKeys<T>>;

// Sort so permite campos escalares
type QuerySort<T> = {
  [P in keyof OnlyChildren<T>]?: SortDirection;
};

// QuerySort<User> permite:
// { name: 'asc' }       OK (string e escalar)
// { active: 'desc' }    OK (boolean e escalar)
// { contact: 'asc' }    ERRO (contact e objeto)
```

---

## 3. Conditional Types (Tipos Condicionais)

### ConvertRelationsToID

Converte referências a objetos em seus IDs automaticamente:

```typescript
type ConvertRelationsToID<T> = {
  [K in keyof T]:
    // Se e Array de objetos com id → Array de IDs
    T[K] extends Array<{ id: infer U }> | undefined ? U[] :
    // Se e objeto com id → apenas o ID
    T[K] extends { id: infer U } | undefined ? U :
    // Caso contrario, mantem o tipo original
    T[K];
};

// Exemplo:
interface Event {
  id: string;
  title: string;
  owner: UserRef;      // { id: string, name: string }
  leaders: UserRef[];   // Array<{ id: string, name: string }>
}

// ConvertRelationsToID<Event> =
// {
//   id: string;
//   title: string;
//   owner: string;        // Apenas o ID
//   leaders: string[];    // Array de IDs
// }
```

### Nested Keys (Chaves Aninhadas)

```typescript
type NestedKeys<T> = {
  [K in keyof T]: T[K] extends object
    ? `${K & string}.${NestedKeys<T[K]>}`  // Recursao com dot notation
    : K & string;
}[keyof T];

// NestedKeys<User> = 'name' | 'active' | 'contact.email' | 'contact.phone' | ...
```

---

## 4. Utility Types Customizados

### Type e Abstract

```typescript
// Tipo para construtores concretos
interface Type<T = any> {
  new (...params: any[]): T;
}

// Tipo para construtores abstratos
type Abstract<T = any> = abstract new (...params: any[]) => T;

// Uso em factory functions
function createProvider<A extends Abstract, T extends Type>(
  abstraction: A,
  implementation: T
) { ... }
```

### Fn (Function Type)

```typescript
type Fn<A = void, B = void> = (arg: A) => B;

// Uso
type Handler = Fn<Event, void>;
type Transformer = Fn<string, number>;
```

### ValueOf

```typescript
type ValueOf<T> = T[keyof T];

// ValueOf<{ a: string; b: number }> = string | number
```

---

## 5. Typed Reactive Forms

O `TypedForm<T>` mapeia uma interface para controles de formulario:

```typescript
// Mapeia campos de T para FormControl/FormGroup
type TypedForm<T> = {
  [K in keyof T]: T[K] extends object
    ? FormGroup<TypedForm<T[K]>>  // Nested → FormGroup
    : FormControl<T[K]>;          // Escalar → FormControl
};

// Uso: formulario completamente tipado
class UserForm extends FormGroup<TypedForm<UpdateUser>> {
  constructor() {
    super({
      id: new FormControl('', { nonNullable: true }),
      profile: new UserProfileForm(),  // FormGroup<TypedForm<UserProfile>>
      contact: new UserContactForm(),
    });
  }
}

// form.controls.id          → FormControl<string>
// form.controls.profile     → FormGroup<TypedForm<UserProfile>>
// form.value.id             → string (type-safe!)
```

---

## 6. Error Type System

```typescript
// Mapeia codigos HTTP a nomes
type ClientErrorMap = {
  400: 'Bad Request';
  401: 'Unauthorized';
  403: 'Forbidden';
  404: 'Not Found';
  409: 'Conflict';
};

type ServerErrorMap = {
  500: 'Internal Server Error';
};

type ErrorMap = ClientErrorMap & ServerErrorMap;

// Erro generico sobre o mapa
class RawError<K extends keyof ErrorMap> extends Error {
  constructor(
    message: string,
    public code: K,            // Tipo literal (400, 401, etc.)
    public name: ErrorMap[K]   // Nome inferido do mapa
  ) {
    super(message);
  }
}

// Erros concretos: codigo e nome sao fixos em compilacao
class NotFoundError extends RawError<404> {
  constructor(message = 'Nao encontrado') {
    super(message, 404, 'Not Found');  // code: 404, name: 'Not Found'
  }
}

// NotFoundError.code  → tipo literal 404 (nao number)
// NotFoundError.name  → tipo literal 'Not Found' (nao string)
```

---

## 7. Generic Provider Types

```typescript
// Extrai tipos dos parametros do construtor
type TypeConstructorParams<T extends Type> = ConstructorParameters<T>;

// Funcao tipada que extrai dependencias
function createUseCaseProvider<T extends Type<UseCase>>(
  useCase: T,
  deps: TypeConstructorParams<T>  // Deve casar com o construtor
) {
  return {
    provide: useCase,
    useFactory: (...params: ConstructorParameters<T>) =>
      new useCase(...params),
    inject: deps,
  };
}

// Se CreateCourseUseCase(coursesService: CoursesService)
// Entao deps DEVE ser [CoursesService]
```

---

## 8. Discriminated Unions

```typescript
// Tipo de formato de evento
type EventFormat = 'online' | 'in-person' | 'hybrid';

// Validacao condicional baseada no formato
onFormatChange(format: EventFormat) {
  if (format === 'in-person') {
    this.controls.address.enable();
    this.controls.address.addValidators(Validators.required);
    this.controls.link.disable();
  } else if (format === 'online') {
    this.controls.link.enable();
    this.controls.link.addValidators(Validators.required);
    this.controls.address.disable();
  }
}

// Roles como union type
type Role = 'director' | 'manager' | 'staff' | 'leader' | 'fellow' | 'donor';

// Agrupamento type-safe
type RoleKey = 'sponsor' | 'worthy' | 'board';
const roleKeys: Record<RoleKey, Role[]> = {
  sponsor: ['donor', 'neighbor'],
  worthy: ['leader', 'staff', 'fellow'],
  board: ['director', 'manager'],
};
```

---

## Principios de Type Safety

1. **Generics com constraints**: Sempre use `<T extends Entity>`, nao `<T>`
2. **Mapped types para derivar**: Nao duplique tipos - derive automaticamente
3. **Conditional types para polimorfismo**: Trate arrays e objetos diferente
4. **Utility types nativos**: Use Omit, Pick, Partial, Record do TypeScript
5. **Literal types para erros**: 404 como tipo, nao number
6. **Template literal types**: `${K}.${NestedKeys<T[K]>}` para dot notation
7. **infer para extrair**: `T[K] extends { id: infer U } ? U : never`

---

## Como Aplicar em Qualquer Projeto

1. **Crie um `Entity` base** com `id: string` como constraint global
2. **Use `EditableEntity<T>`** para inputs de criacao/edicao (remove metadados)
3. **Use `QueryFilter<T>`** para buscas type-safe
4. **Use `QuerySort<T>`** restrito a campos escalares
5. **Crie error types com mapped codes** (ErrorMap com codigos HTTP)
6. **Use `TypedForm<T>`** para formularios completamente tipados
7. **Derive tipos em vez de duplicar** - mapped types > copiar campos manualmente
