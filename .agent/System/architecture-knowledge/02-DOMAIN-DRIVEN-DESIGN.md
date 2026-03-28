# Domain-Driven Design (DDD)

## Conceito

Domain-Driven Design e uma abordagem de desenvolvimento que coloca o **dominio do negocio** no centro de todas as decisoes arquiteturais. O codigo reflete diretamente os conceitos, regras e processos do negocio.

---

## Building Blocks do DDD

### 1. Entity (Entidade)

Uma entidade e um objeto com **identidade unica** que persiste ao longo do tempo. Duas entidades com os mesmos atributos mas IDs diferentes sao entidades diferentes.

**Padrao de definicao**:
```typescript
// Interface base - toda entidade tem id
interface Entity {
  id: string;
}

// Entidade concreta via composicao
interface User extends Entity {
  name: string;
  displayName: string;
  active: boolean;
  roles: Roles;              // Value Object
  contact: UserContact;      // Value Object
  profile?: UserProfile;     // Value Object opcional
  skills?: UserSkill[];      // Colecao de Value Objects
}
```

**Principios**:
- Entidades sao **interfaces**, nao classes (imutabilidade estrutural)
- Identidade via `id: string`
- Composicao com Value Objects para dados complexos
- Relacoes via referencia de ID (`owner: string`) ou referencia tipada (`owner: UserRef`)

### 2. Value Object (Objeto de Valor)

Value Objects nao tem identidade propria - sao definidos apenas por seus atributos. Dois Value Objects com os mesmos valores sao iguais.

```typescript
// Value Objects como interfaces
interface UserCode {
  value: string;
  timestamp: Date;
}

interface UserContact {
  email: string;
  phone: string;
}

interface UserProfile {
  minibio?: string;
  birthday?: Date;
  gender?: Gender;
  photo?: string;
}

// Value Object com enum
type Gender = 'male' | 'female' | 'other';

// Value Object composto
interface Range {
  min: number;
  max: number;
}
```

**Principios**:
- Sem `id` - identidade vem dos valores
- Sempre embutidos dentro de entidades
- Imutaveis por convencao (interfaces)
- Podem ser substituidos inteiramente, nunca mutados

### 3. Aggregate Root (Raiz de Agregado)

O Aggregate Root e a entidade principal de um grupo de objetos relacionados. Todo acesso externo ao agregado passa pela raiz.

```typescript
// Album e a raiz do agregado
interface Album extends Entity {
  title: string;
  owner: UserRef;              // Referencia externa
  contributors: UserRef[];     // Referencia externa
  photos: Photo[];             // Entidade filha do agregado
}

// Photo so existe dentro de Album
interface Photo extends Entity {
  url: string;
  tags: PhotoTag[];
}
```

**Principios**:
- Apenas o Aggregate Root tem repositorio/service
- Entidades filhas sao acessadas via raiz
- Operacoes no agregado sao atomicas

### 4. Repository (Repositorio)

Abstrai o acesso a persistencia. O dominio define a interface; a infraestrutura implementa.

```typescript
// Dominio define o contrato
abstract class AlbumsService extends EntityService<Album> {
  abstract addPhoto(albumId: string, photo: Photo): Promise<Album>;
  abstract removePhoto(albumId: string, photoId: string): Promise<Album>;
}

// Infraestrutura implementa
class AlbumsMongoServiceImpl extends AlbumsService {
  // Implementacao com Mongoose
}
```

---

## Bounded Context (Contexto Delimitado)

Cada dominio tem seu proprio **contexto delimitado** - um limite claro onde termos e conceitos tem significados especificos.

```
┌─────────────┐  ┌──────────────┐  ┌────────────────┐
│   Account    │  │    Event     │  │   Presentation │
│             │  │              │  │                │
│  User       │  │  Event       │  │  Presentation  │
│  Roles      │  │  RSVP        │  │  Comment       │
│  Auth       │  │  Leaders     │  │  Reaction      │
│  Profile    │  │  City        │  │  Speaker       │
└─────────────┘  └──────────────┘  └────────────────┘

┌─────────────┐  ┌──────────────┐  ┌────────────────┐
│   Career    │  │   Academy    │  │     Album      │
│             │  │              │  │                │
│  JobOpening │  │  Course      │  │  Album         │
│  JobSkill   │  │  Institution │  │  Photo         │
│  Salary     │  │  Subject     │  │  Contributor   │
└─────────────┘  └──────────────┘  └────────────────┘
```

**Comunicacao entre contextos**: Atraves de **referencias de ID** e **tipos compartilhados** (UserRef, CityRef) - nunca importando diretamente de outro dominio.

```typescript
// Referencia cruzada entre contextos
interface UserRef {
  id: string;
  name: string;
  displayName: string;
}

// Usado em Event (outro contexto)
interface Event extends Entity {
  leaders?: UserRef[];  // Referencia ao contexto Account
}
```

---

## Ubiquitous Language (Linguagem Ubiqua)

Todos os termos usados no codigo devem refletir os termos do negocio:

| Termo do Dominio | Significado | Onde aparece |
|-----------------|-------------|-------------|
| `RSVP` | Confirmacao de presenca em evento | Event context |
| `JobOpening` | Vaga de emprego | Career context |
| `Presentation` | Palestra/talk | Presentation context |
| `Course` | Curso de capacitacao | Academy context |
| `Skill` | Habilidade tecnica | Learn context |
| `Place` | Local fisico | Location context |

---

## Editable Entity Pattern

Para separar dados que podem ser editados dos metadados do sistema:

```typescript
// Remove id, createdAt, updatedAt automaticamente
type EditableEntity<T> = Omit<T, 'id' | 'createdAt' | 'updatedAt'>;

// Uso: Create recebe EditableEntity, nao Entity completa
class CreateCourseUseCase implements UseCase<EditableCourse, Course> {
  execute(data: EditableCourse) {
    // data nao tem id, createdAt, updatedAt
    return this.service.create(data);
  }
}
```

---

## Reference Pattern (Referencia entre Contextos)

Quando um contexto precisa referenciar entidades de outro, usa tipos de referencia reduzidos:

```typescript
// Entity completa (dentro do seu contexto)
interface User {
  id: string;
  name: string;
  displayName: string;
  active: boolean;
  roles: Roles;
  contact: UserContact;
  profile?: UserProfile;
  // ... muitos campos
}

// Referencia (usado por outros contextos)
interface UserRef {
  id: string;
  name: string;
  displayName: string;
  // Apenas o minimo necessario
}
```

**Tipo utilitario para conversao automatica**:
```typescript
type ConvertRelationsToID<T> = {
  [K in keyof T]: T[K] extends Array<{ id: infer U }> | undefined
    ? U[]
    : T[K] extends { id: infer U } | undefined
    ? U
    : T[K];
};

// ConvertRelationsToID<Event> transforma:
//   leaders: UserRef[]  →  leaders: string[]
//   owner: UserRef      →  owner: string
```

---

## Como Aplicar em Qualquer Projeto

1. **Identifique os contextos delimitados** do seu negocio
2. **Mapeie entidades e value objects** de cada contexto
3. **Defina a linguagem ubiqua** e use-a consistentemente no codigo
4. **Crie interfaces para entidades** (nao classes com metodos de persistencia)
5. **Use referencia por ID** entre contextos (nunca importe entidades de outro dominio)
6. **Crie tipos de referencia reduzidos** (UserRef, CityRef) para dados cruzados
7. **Mantenha agregados pequenos** - cada um com seu repositorio
