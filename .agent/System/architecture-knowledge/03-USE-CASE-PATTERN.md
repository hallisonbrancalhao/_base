# Use Case Pattern (Padrao de Caso de Uso)

## Conceito

O Use Case Pattern encapsula **uma unica operacao de negocio** em uma classe dedicada, seguindo o Single Responsibility Principle. Cada Use Case tem um unico metodo `execute()` que recebe um input tipado e retorna um output tipado.

---

## Interface Base

```typescript
export interface UseCase<I, O> {
  execute(input: I): Promise<O> | Observable<O>;
}
```

**Generics**:
- `I` (Input): Tipo do dado de entrada (DTO, ID, parametros de busca)
- `O` (Output): Tipo do dado de saida (entidade, lista paginada, mensagem)

**Retorno dual**: Suporta tanto `Promise<O>` (backend/server) quanto `Observable<O>` (frontend/client), tornando o contrato framework-agnostico.

---

## Anatomia de um Use Case

### Use Case Simples (CRUD)

```typescript
export class CreateCourseUseCase implements UseCase<EditableCourse, Course> {
  constructor(private coursesService: CoursesService) {}

  execute(data: EditableCourse) {
    return this.coursesService.create(data);
  }
}
```

**Caracteristicas**:
- Uma unica dependencia (o service/port)
- Delegacao direta ao service
- Zero logica adicional
- Input: DTO editavel | Output: entidade criada

### Use Case com Logica de Negocio

```typescript
export class CopyEventUseCase implements UseCase<CopyEvent, Event> {
  constructor(private eventsService: EventsService) {}

  async execute({ id, title }: CopyEvent) {
    // 1. Buscar entidade original
    const event = await this.eventsService.findOne(id);

    // 2. Validar existencia
    if (!event) {
      throw new NotFoundError('Evento nao encontrado');
    }

    // 3. Transformar dados
    const { id: _, ...data } = event;
    const copied = { ...data, title } as Event;

    // 4. Persistir copia
    const updated = await this.eventsService.create(copied);

    // 5. Validar resultado
    if (!updated) {
      throw new PersistenceError('Algo deu errado ao persistir');
    }

    return updated;
  }
}
```

### Use Case com Multiplas Dependencias

```typescript
export class SendUserCodeUseCase implements UseCase<string, ResponseMessage> {
  constructor(
    private usersService: UsersService,
    private mailerService: MailerService,
    private env: Env
  ) {}

  async execute(name: string) {
    // 1. Determinar tipo de busca
    const user = name.includes('@')
      ? await this.usersService.findByEmail(name)
      : await this.usersService.findByName(name);

    // 2. Validar usuario
    if (!user) throw new AuthenticationError();

    // 3. Gerar codigo
    const code = { value: createCode(), timestamp: new Date() };
    await this.usersService.updateCode(user.id, code);

    // 4. Enviar por email (ou dev mode)
    const mail = createMail(user.contact.email, code.value);

    if (this.env.production) {
      await this.mailerService.send(mail);
      return { message: `Enviado para ${hideEmail(user.contact.email)}` };
    }

    return { message: `Dev mode - codigo: ${code.value}` };
  }
}
```

### Use Case de Validacao (Authentication)

```typescript
export class AuthenticationUseCase implements UseCase<ValidateUserCode, AccessToken> {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
    private env: Env
  ) {}

  async execute(data: ValidateUserCode) {
    // 1. Buscar usuario
    const user = data.name.includes('@')
      ? await this.usersService.findByEmail(data.name)
      : await this.usersService.findByName(data.name);

    if (!user || !user.code) throw new AuthenticationError();

    // 2. Validar codigo
    if (user.code.value !== data.code) throw new AuthenticationError();

    // 3. Validar expiracao
    const expired = Date.now() > user.code.timestamp + this.env.auth.codeLifeTime;
    if (expired) throw new AuthenticationError();

    // 4. Gerar token
    const payload = { id: user.id, roles: user.roles };
    const accessToken = await this.jwtService.signAsync(payload);

    return { accessToken };
  }
}
```

---

## Provider Pattern para DI

Cada Use Case exporta uma funcao provider que descreve suas dependencias:

```typescript
// Junto ao arquivo do use case
export function provideCreateCourseUseCase() {
  return createUseCaseProvider(CreateCourseUseCase, [CoursesService]);
}

export function provideSendUserCodeUseCase() {
  return createUseCaseProvider(SendUserCodeUseCase, [
    UsersService,
    MailerService,
    Env,
  ]);
}
```

**Factory helper** (framework-agnostico):
```typescript
function createUseCaseProvider<T extends Type<UseCase>>(
  useCase: T,
  dependencies: (Type | Abstract)[]
) {
  return {
    provide: useCase,
    useFactory(...params: any[]) {
      return new useCase(...params);
    },
    inject: dependencies,
  };
}
```

---

## Organizacao de Use Cases

### Estrutura de Diretorios

```
domain/src/
├── client/                    # Use Cases do frontend
│   ├── use-cases/
│   │   ├── create-course.ts
│   │   ├── find-courses.ts
│   │   ├── find-course-by-id.ts
│   │   ├── update-course.ts
│   │   ├── delete-course.ts
│   │   └── index.ts          # Barrel export
│   └── services/
│       ├── course.ts          # Port abstrato
│       └── index.ts
│
├── server/                    # Use Cases do backend
│   ├── use-cases/
│   │   ├── create-course.ts
│   │   ├── find-courses.ts
│   │   ├── copy-event.ts     # Logica mais complexa
│   │   └── index.ts
│   └── services/
│       ├── courses.ts
│       └── index.ts
│
└── lib/                       # DTOs compartilhados
    └── dtos/
        ├── create-course.ts
        └── index.ts
```

### Convencoes de Nomenclatura

| Operacao | Classe | Arquivo |
|----------|--------|---------|
| Criar | `CreateCourseUseCase` | `create-course.ts` |
| Listar | `FindCoursesUseCase` | `find-courses.ts` |
| Buscar por ID | `FindCourseByIdUseCase` | `find-course-by-id.ts` |
| Atualizar | `UpdateCourseUseCase` | `update-course.ts` |
| Deletar | `DeleteCourseUseCase` | `delete-course.ts` |
| Copiar | `CopyEventUseCase` | `copy-event.ts` |
| Validar | `AuthenticationUseCase` | `authentication.ts` |

---

## Client vs Server Use Cases

| Aspecto | Client (Frontend) | Server (Backend) |
|---------|-------------------|------------------|
| **Retorno** | `Observable<T>` | `Promise<T>` |
| **Dependencias** | Service que retorna Observable | Service que retorna Promise |
| **Complexidade** | Geralmente simples (delega ao service) | Pode ter logica complexa |
| **Validacao** | Minima (UI valida antes) | Completa (ultima linha de defesa) |
| **Erros** | Propagados via Observable | Throw de custom errors |

---

## Principios e Regras

1. **Um Use Case = Uma Operacao**: Nunca misture responsabilidades
2. **Nomeie com verbo + substantivo**: `CreateCourse`, `FindEvents`, `ValidateCode`
3. **Dependencias via construtor**: Sempre injetadas, nunca instanciadas
4. **Sem dependencia de framework**: Use Cases nao importam Angular/NestJS
5. **Input e Output tipados**: Sempre use generics do `UseCase<I, O>`
6. **Erros sao excecoes**: Valide e lance erros de dominio tipados
7. **Provider junto ao Use Case**: Cada Use Case exporta sua funcao provider
8. **Separacao client/server**: Mesmo conceito, implementacoes independentes

---

## Como Aplicar em Qualquer Projeto

1. **Crie a interface `UseCase<I, O>`** com metodo `execute()`
2. **Um arquivo por Use Case** - classes pequenas e focadas
3. **Injete dependencias via construtor** - apenas portas abstratas
4. **Exporte provider functions** junto ao Use Case
5. **Separe client e server** quando as implementacoes divergem
6. **Barrel exports** (`index.ts`) em cada diretorio de use cases
7. **Teste isoladamente** - mock das portas, teste a logica
