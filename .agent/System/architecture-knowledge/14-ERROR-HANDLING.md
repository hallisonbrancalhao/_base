# Error Handling (Tratamento de Erros)

## Conceito

O sistema de erros segue uma abordagem de **erros tipados com hierarquia**, onde erros de dominio sao classes tipadas com codigo HTTP e nome, e a camada de infraestrutura traduz esses erros para exceptions HTTP do framework.

---

## 1. Hierarquia de Erros

```
                    Error (nativo JS)
                       │
                ┌──────▼──────┐
                │   RawError   │  (codigo + nome generico)
                └──────┬──────┘
           ┌───────────┼───────────┐
     ┌─────▼─────┐          ┌─────▼──────┐
     │ClientError │          │ServerError  │
     │  (4xx)     │          │  (5xx)      │
     └─────┬─────┘          └─────┬──────┘
           │                      │
     ┌─────┼────────┐       ┌────▼────────┐
     │     │        │       │             │
  NotFound Auth  Conflict  Persistence  ...
   (404)  (401)   (409)     (500)
```

### Base: RawError

```typescript
abstract class RawError<K extends keyof ErrorMap> extends Error {
  constructor(
    override message: string,
    public code: K,            // Tipo literal (404, 401, etc.)
    override name: ErrorMap[K] // Nome do mapa ('Not Found', etc.)
  ) {
    super(message);
  }
}
```

### Error Maps (Tipagem por Codigo)

```typescript
type ClientErrorMap = {
  400: 'Bad Request';
  401: 'Unauthorized';
  403: 'Forbidden';
  404: 'Not Found';
  409: 'Conflict';
  422: 'Unprocessable Entity';
};

type ServerErrorMap = {
  500: 'Internal Server Error';
  502: 'Bad Gateway';
  503: 'Service Unavailable';
};

type ErrorMap = ClientErrorMap & ServerErrorMap;
```

### Erros Concretos

```typescript
// Client errors (4xx)
class AuthenticationError extends ClientError<401> {
  constructor(message = 'Nao autorizado') {
    super(message, 401, 'Unauthorized');
  }
}

class AccessDeniedError extends ClientError<403> {
  constructor(message = 'Acesso negado') {
    super(message, 403, 'Forbidden');
  }
}

class NotFoundError extends ClientError<404> {
  constructor(message = 'Recurso nao encontrado') {
    super(message, 404, 'Not Found');
  }
}

class ConflictError extends ClientError<409> {
  constructor(message = 'Conflito') {
    super(message, 409, 'Conflict');
  }
}

class RequestError extends ClientError<400> {
  constructor(message = 'Requisicao invalida') {
    super(message, 400, 'Bad Request');
  }
}

// Server errors (5xx)
class PersistenceError extends ServerError<500> {
  constructor(message = 'Erro ao persistir dados') {
    super(message, 500, 'Internal Server Error');
  }
}
```

---

## 2. Uso em Use Cases (Dominio)

Erros sao lancados nos Use Cases quando regras de negocio sao violadas:

```typescript
class CopyEventUseCase implements UseCase<CopyEvent, Event> {
  async execute({ id, title }: CopyEvent) {
    const event = await this.eventsService.findOne(id);

    if (!event) {
      throw new NotFoundError('Evento nao encontrado');
    }

    const copied = await this.eventsService.create({ ...event, title });

    if (!copied) {
      throw new PersistenceError('Algo deu errado ao persistir');
    }

    return copied;
  }
}

class AuthenticationUseCase {
  async execute(data: ValidateUserCode) {
    const user = await this.usersService.findByName(data.name);

    if (!user) throw new AuthenticationError();

    if (user.code.value !== data.code) {
      throw new AuthenticationError('Codigo invalido');
    }

    if (Date.now() > user.code.timestamp + this.env.auth.codeLifeTime) {
      throw new AuthenticationError('Codigo expirado');
    }
  }
}
```

---

## 3. Traducao para HTTP (Resource Layer)

A funcao `exceptionByError()` traduz erros de dominio para exceptions HTTP do NestJS:

```typescript
function exceptionByError(error: unknown) {
  const isError = error && typeof error === 'object'
    && 'code' in error && 'message' in error;

  if (error instanceof RawError || isError) {
    switch (error.code) {
      case 400: return new BadRequestException(error.message);
      case 401: return new UnauthorizedException(error.message);
      case 403: return new ForbiddenException(error.message);
      case 404: return new NotFoundException(error.message);
      case 409: return new ConflictException(error.message);
      case 422: return new UnprocessableEntityException(error.message);
      default:  return new BadRequestException(error.message);
    }
  }

  return new BadRequestException();
}
```

### Uso nos Controllers

```typescript
@Get(':id')
async findOne(@Param('id') id: string) {
  try {
    return await this.facade.findOne(id);
  } catch (err) {
    throw exceptionByError(err);
    // NotFoundError(404) → NotFoundException (NestJS)
    // AuthenticationError(401) → UnauthorizedException (NestJS)
  }
}
```

---

## 4. Frontend Error Handling

### HttpErrorResponse Handler

```typescript
class AuthErrorHandler implements ErrorHandler {
  router = inject(Router);

  handleError(error: Error) {
    if (error instanceof HttpErrorResponse) {
      if (error.status === 401) {
        localStorage.removeItem('accessToken');
        this.router.navigate(['/', 'conta', 'autenticacao']);
      }
    }
  }
}
```

### Observable Error Handling

```typescript
// Via RxJS pipe
this.facade.create(data).pipe(
  take(1),
  catchError(err => {
    console.error(err);
    return EMPTY;
  }),
).subscribe(result => { ... });
```

---

## 5. Fluxo Completo de um Erro

```
1. Use Case: throw new NotFoundError('Evento nao encontrado')
   ↓
2. Controller catch: exceptionByError(err)
   ↓
3. exceptionByError: switch(404) → new NotFoundException(message)
   ↓
4. NestJS: HTTP 404 { message: 'Evento nao encontrado', statusCode: 404 }
   ↓
5. Frontend: HttpErrorResponse { status: 404, error: { message: '...' } }
   ↓
6. ErrorHandler: Redireciona ou exibe mensagem
```

---

## 6. Validation Errors (ValidationPipe)

```typescript
// Global validation pipe
app.useGlobalPipes(new ValidationPipe({ transform: true }));

// DTO com decorators class-validator
class CreateEventDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsDateString()
  date: string;

  @IsOptional()
  @IsString()
  description?: string;
}

// Se validacao falha: 400 Bad Request automatico
// { message: ['title should not be empty'], error: 'Bad Request', statusCode: 400 }
```

---

## 7. Permission Errors (Inline)

```typescript
// Verificacao direta no controller
if (entity.owner.id !== auth.id && !authIsAdmin(auth.roles)) {
  throw exceptionByError({ code: 403, message: 'Sem permissao' });
}

// Ou via objeto literal
throw exceptionByError({ code: 404, message: 'Not found' });
```

---

## Principios do Error Handling

| Principio | Implementacao |
|-----------|---------------|
| **Erros tipados** | Classes com codigo literal (404, nao number) |
| **Dominio lanca** | Use Cases lancam erros de dominio |
| **Infra traduz** | exceptionByError() converte para HTTP |
| **Controller nao decide** | Apenas re-lanca via exceptionByError() |
| **Frontend reage** | ErrorHandler global + catchError local |
| **Validacao automatica** | ValidationPipe + class-validator |

---

## Como Aplicar em Qualquer Projeto

1. **Crie uma hierarquia de erros** com ErrorMap tipado
2. **Erros de dominio com codigos** (NotFound=404, Auth=401, etc.)
3. **Use Cases lancam erros de dominio** - nunca exceptions de framework
4. **Funcao tradutora** (exceptionByError) na camada de infra
5. **Controllers usam try/catch + traducao** em todo endpoint
6. **ValidationPipe global** para validacao de DTOs automatica
7. **ErrorHandler global** no frontend para 401/403
8. **Mensagens em portugues** nos erros de dominio (ou no idioma do negocio)
