# Backend Patterns (Padroes de Backend - NestJS)

## Conceito

O backend segue uma arquitetura de **modulos compostos** onde cada dominio registra seus controllers, providers e database modules como um bloco independente. O NestJS atua como o framework de composicao, mas a logica de negocio e framework-agnostic.

---

## 1. Composicao de Modulos

### App Module (Raiz)

```typescript
@Module({
  imports: [
    // Infraestrutura compartilhada
    ServeStaticModule.forRoot(env.static),
    SharedResourceModule.forRoot(env),
    SharedDatabaseModule,
    SharedMailerModule,
    SharedGithubModule,

    // Modulos de dominio
    AccountResourceModule,
    AcademyResourceModule,
    CareerResourceModule,
    EventResourceModule,
    LearnResourceModule,
    LocationResourceModule,
    PresentationResourceModule,
    AlbumResourceModule,
  ],
})
export class AppModule {}
```

### Resource Module (Dominio)

```typescript
@Module({
  imports: [EventDatabaseModule],
  controllers: [EventsController, RSVPsController],
})
export class EventResourceModule {}
```

### Database Module (Global)

```typescript
@Global()  // Disponivel em toda a aplicacao
@Module({
  imports: [
    MongooseModule.forFeature([
      { name: EventCollection.name, schema: EventSchema },
      { name: RSVPCollection.name, schema: RSVPSchema },
    ]),
  ],
  providers: [...provideEvents()],
  exports: [...provideEvents()],
})
export class EventDatabaseModule {}
```

**Hierarquia**:
```
AppModule
└── EventResourceModule (controllers)
    └── EventDatabaseModule (@Global - providers/schemas)
```

---

## 2. Controller Pattern

```typescript
@ApiTags('Eventos')
@Controller('events')
export class EventsController {
  constructor(
    private eventsFacade: EventsFacade,
    private rsvpsFacade: RSVPsFacade
  ) {}

  // GET /api/events
  @Get()
  @Allowed()                    // Endpoint publico
  @ApiPage(EventDto)            // Documentacao Swagger
  async findAll(@Query() params: QueryParamsDto<Event>) {
    try {
      return await this.eventsFacade.find(params);
    } catch (err) {
      throw exceptionByError(err);
    }
  }

  // POST /api/events
  @Post()
  @ApiBearerAuth()              // Requer autenticacao
  @ApiOkResponse({ type: EventDto })
  async create(
    @User('id') owner: string,  // Extrai id do usuario autenticado
    @Body() data: CreateEventDto
  ) {
    try {
      return await this.eventsFacade.create({ ...data, owner });
    } catch (err) {
      throw exceptionByError(err);
    }
  }

  // PATCH /api/events/:id
  @Patch(':id')
  @ApiBearerAuth()
  @Roles(['director', 'manager'])  // Apenas diretores e managers
  async update(
    @Param('id') id: string,
    @Body() data: UpdateEventDto
  ) {
    try {
      return await this.eventsFacade.update(id, data);
    } catch (err) {
      throw exceptionByError(err);
    }
  }

  // DELETE /api/events/:id
  @Delete(':id')
  @ApiBearerAuth()
  async delete(@User() auth: AuthUser, @Param('id') id: string) {
    const event = await this.eventsFacade.findOne(id);
    if (event.owner.id !== auth.id && !authIsAdmin(auth.roles)) {
      throw exceptionByError({ code: 403, message: 'Sem permissao' });
    }
    try {
      return await this.eventsFacade.delete(id);
    } catch (err) {
      throw exceptionByError(err);
    }
  }
}
```

**Principios do Controller**:
- Delega TUDO para a Facade
- Trata apenas HTTP concerns (status, auth, params)
- Try/catch com `exceptionByError()` em todo endpoint
- Swagger decorators em todo endpoint

---

## 3. Guard System (Autenticacao/Autorizacao)

### AuthGuard (JWT Bearer)

```typescript
@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    private jwtService: JwtService,
    private reflector: Reflector,
    private env: Env
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    // Verifica @Allowed() - endpoints publicos
    if (this.isAllowed(context)) return true;

    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);

    if (!token) throw new UnauthorizedException();

    try {
      request['user'] = await this.jwtService.verifyAsync(token);
    } catch {
      throw new UnauthorizedException();
    }
    return true;
  }

  private extractTokenFromHeader(request: Request) {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }

  private isAllowed(context: ExecutionContext) {
    return this.reflector.getAllAndOverride<boolean>(
      IS_ALLOWED_KEY,
      [context.getHandler(), context.getClass()]
    );
  }
}
```

### RolesGuard (RBAC)

```typescript
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.get(Roles, context.getHandler());
    if (!requiredRoles) return true;

    const { user } = context.switchToHttp().getRequest<AuthRequest>();
    return requiredRoles.some(role => user.roles[role]);
  }
}
```

### Guards como Providers Globais

```typescript
providers: [
  { provide: APP_GUARD, useClass: AuthGuard },
  { provide: APP_GUARD, useClass: RolesGuard },
]
```

**Fluxo**: Request → AuthGuard (JWT) → RolesGuard (RBAC) → Controller

---

## 4. Custom Decorators

```typescript
// @Allowed() - marca endpoint como publico
export const IS_ALLOWED_KEY = 'isAllowed';
export const Allowed = () => SetMetadata(IS_ALLOWED_KEY, true);

// @Roles() - define roles necessarias
export const Roles = Reflector.createDecorator<string[]>();

// @User() - extrai usuario do request
export const User = createParamDecorator(
  (data: string | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest<AuthRequest>();
    return data ? request.user?.[data] : request.user;
  }
);

// @ApiPage() - documenta resposta paginada
export const ApiPage = (type: Type) => {
  return applyDecorators(
    ApiOkResponse({
      schema: {
        properties: {
          data: { type: 'array', items: { $ref: getSchemaPath(type) } },
          items: { type: 'number' },
          pages: { type: 'number' },
        },
      },
    })
  );
};
```

---

## 5. Exception Handling

### Centralized Error Mapping

```typescript
export function exceptionByError(error: unknown) {
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

**Uso**: Todo controller usa `throw exceptionByError(err)` no catch.

---

## 6. Server Bootstrap

```typescript
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // 1. Prefixo global
  app.setGlobalPrefix('api');

  // 2. CORS
  app.enableCors();

  // 3. Validacao global
  app.useGlobalPipes(new ValidationPipe({ transform: true }));

  // 4. Swagger
  const config = new DocumentBuilder()
    .setTitle('API')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document);

  // 5. Listen
  const port = +process.env.PORT || 3000;
  await app.listen(port);
}
```

---

## 7. File Upload Pattern

```typescript
@Post(':id/upload')
@UseInterceptors(FileInterceptor('file'))
@ApiBearerAuth()
async upload(
  @User() auth: Authentication,
  @Param('id') id: string,
  @UploadedFile() file: Express.Multer.File
) {
  const content = file.buffer;
  const photo = await this.photosFacade.create({ content, owner: auth.id });
  return await this.albumsFacade.addPhoto(id, photo);
}
```

### Multer Configuration

```typescript
@Module({
  imports: [
    MulterModule.registerAsync({
      useFactory(env: Env) { return env.multer.events.covers; },
      inject: [Env],
    }),
  ],
})
export class EventResourceModule {}
```

---

## 8. Environment Configuration

```typescript
// Tipagem forte para env
declare namespace NodeJS {
  interface ProcessEnv {
    PORT: string;
    DB_HOST: string;
    DB_PORT: string;
    DB_NAME: string;
    JWT_SECRET: string;
    SMTP_HOST: string;
    NODE_ENV: 'production' | 'development';
  }
}

// Dynamic module para injecao
static forRoot(env: EnvConfig): DynamicModule {
  return {
    module: SharedResourceModule,
    global: true,
    providers: [
      { provide: Env, useValue: env },
      {
        provide: 'MONGO_URI',
        useFactory: (env: Env) => buildMongoUri(env),
        inject: [Env],
      },
    ],
  };
}
```

---

## 9. Permission Patterns

```typescript
// Owner check
if (entity.owner.id !== auth.id) {
  throw exceptionByError({ code: 403, message: 'Sem permissao' });
}

// Admin bypass
if (entity.owner.id !== auth.id && !authIsAdmin(auth.roles)) {
  throw exceptionByError({ code: 403, message: 'Sem permissao' });
}

// Contributor check
const isContributor = entity.contributors?.some(c => c.id === auth.id);
if (!isContributor && entity.owner.id !== auth.id) {
  throw exceptionByError({ code: 403, message: 'Sem permissao' });
}
```

---

## 10. Data Flow (Request → Response)

```
HTTP Request
    ↓
Global Prefix (/api)
    ↓
ValidationPipe (transform DTOs)
    ↓
AuthGuard (extract & verify JWT)
    ↓
RolesGuard (check @Roles)
    ↓
Controller Method
    ↓
Facade (orchestrate use cases)
    ↓
Use Case (business logic)
    ↓
Service/Repository (data access)
    ↓
MongoDB
    ↓
Entity → DTO (plainToInstance)
    ↓
PageDto (if paginated)
    ↓
HTTP Response (JSON)
```

---

## Como Aplicar em Qualquer Projeto

1. **Resource Module + Database Module** por dominio
2. **@Global()** em database modules
3. **Controllers so delegam** - zero logica de negocio
4. **Guards globais** (APP_GUARD) para auth/RBAC
5. **Custom decorators** (@Allowed, @Roles, @User) simplificam controllers
6. **exceptionByError()** centraliza mapeamento de erros
7. **ValidationPipe com transform** - DTOs validados automaticamente
8. **Swagger em todo endpoint** - documentacao automatica
9. **Environment tipado** - ProcessEnv com interface
10. **forRoot() pattern** para configuracao dinamica
