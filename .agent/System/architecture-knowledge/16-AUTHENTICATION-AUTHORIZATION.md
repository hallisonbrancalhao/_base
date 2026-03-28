# Authentication & Authorization (Autenticacao e Autorizacao)

## Conceito

O sistema implementa **autenticacao passwordless** (sem senha) via codigo por email + JWT, e **autorizacao RBAC** (Role-Based Access Control) com guards em cadeia.

---

## 1. Fluxo de Autenticacao Passwordless

### Etapa 1: Solicitar Codigo

```
Usuario digita email/username
         ↓
Frontend: POST /api/authentication { name: "user@email.com" }
         ↓
Backend: SendUserCodeUseCase
  1. Busca usuario por email ou username
  2. Gera codigo de 4 digitos (createCode())
  3. Salva codigo + timestamp no usuario
  4. Envia email com o codigo
  5. Retorna: { message: "Enviado para u***@email.com" }
```

### Etapa 2: Validar Codigo

```
Usuario digita codigo recebido
         ↓
Frontend: POST /api/authentication/validate { name, code }
         ↓
Backend: AuthenticationUseCase
  1. Busca usuario por email/username
  2. Compara codigo enviado com armazenado
  3. Verifica se codigo nao expirou (timestamp + codeLifeTime)
  4. Se valido: gera JWT com { id, roles }
  5. Retorna: { accessToken: "eyJ..." }
```

### Etapa 3: Requisicoes Autenticadas

```
Frontend: Armazena token em localStorage
         ↓
Auth Interceptor: Adiciona header Authorization: Bearer {token}
         ↓
Backend AuthGuard: Verifica e decodifica JWT
         ↓
Request.user = { id, roles }
```

---

## 2. Implementacao do Use Case de Autenticacao

```typescript
class SendUserCodeUseCase implements UseCase<string, ResponseMessage> {
  constructor(
    private usersService: UsersService,
    private mailerService: MailerService,
    private env: Env
  ) {}

  async execute(name: string) {
    // 1. Busca flexivel (email ou username)
    const user = name.includes('@')
      ? await this.usersService.findByEmail(name)
      : await this.usersService.findByName(name);

    if (!user) throw new AuthenticationError();

    // 2. Gera codigo temporario
    const code = { value: createCode(), timestamp: new Date() };
    await this.usersService.updateCode(user.id, code);

    // 3. Envia por email
    const mail = createMail(user.contact.email, code.value);

    if (this.env.production) {
      await this.mailerService.send(mail);
      return { message: `Enviado para ${hideEmail(user.contact.email)}` };
    }

    // Dev mode: retorna codigo direto
    return { message: `Dev mode - codigo: ${code.value}` };
  }
}
```

```typescript
class AuthenticationUseCase implements UseCase<ValidateUserCode, AccessToken> {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
    private env: Env
  ) {}

  async execute({ name, code }: ValidateUserCode) {
    const user = name.includes('@')
      ? await this.usersService.findByEmail(name)
      : await this.usersService.findByName(name);

    // Validacoes
    if (!user || !user.code) throw new AuthenticationError();
    if (user.code.value !== code) throw new AuthenticationError();
    if (Date.now() > user.code.timestamp.getTime() + this.env.auth.codeLifeTime) {
      throw new AuthenticationError('Codigo expirado');
    }

    // Gera JWT
    const payload = { id: user.id, roles: user.roles };
    const accessToken = await this.jwtService.signAsync(payload);

    return { accessToken };
  }
}
```

---

## 3. JWT Guard (Backend)

```typescript
@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    private jwtService: JwtService,
    private reflector: Reflector,
    private env: Env
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    // Endpoints marcados com @Allowed() sao publicos
    if (this.isAllowed(context)) return true;

    const request = context.switchToHttp().getRequest<AuthRequest>();
    const token = this.extractTokenFromHeader(request);

    if (!token) throw new UnauthorizedException();

    try {
      // Decodifica JWT e injeta no request
      request['user'] = await this.jwtService.verifyAsync(token, {
        secret: this.env.jwt.secret,
      });
    } catch {
      throw new UnauthorizedException();
    }

    return true;
  }

  private extractTokenFromHeader(request: Request): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }

  private isAllowed(context: ExecutionContext): boolean {
    return this.reflector.getAllAndOverride<boolean>(
      IS_ALLOWED_KEY,
      [context.getHandler(), context.getClass()]
    );
  }
}
```

---

## 4. RBAC - Role-Based Access Control

### Modelo de Roles

```typescript
// Todas as roles possiveis
type Role = 'director' | 'manager' | 'staff' | 'leader' | 'fellow' | 'donor' | 'neighbor';

// Interface de roles de um usuario
interface Roles {
  director: boolean;
  manager: boolean;
  staff: boolean;
  leader: boolean;
  fellow: boolean;
  donor: boolean;
  neighbor: boolean;
  member: boolean;
}

// Agrupamento de roles
type RoleKey = 'sponsor' | 'worthy' | 'board';

const roleKeys: Record<RoleKey, Role[]> = {
  sponsor: ['donor', 'neighbor'],
  worthy: ['leader', 'staff', 'fellow'],
  board: ['director', 'manager'],
};
```

### RolesGuard

```typescript
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.get(Roles, context.getHandler());

    // Se nenhuma role definida, permite
    if (!requiredRoles) return true;

    const { user } = context.switchToHttp().getRequest<AuthRequest>();

    // Verifica se o usuario tem alguma das roles necessarias
    return requiredRoles.some(role => user.roles[role]);
  }
}
```

### Uso nos Controllers

```typescript
// Endpoint aberto (sem autenticacao)
@Get()
@Allowed()
async findAll() { ... }

// Endpoint autenticado (qualquer usuario logado)
@Post()
@ApiBearerAuth()
async create(@User('id') owner: string) { ... }

// Endpoint restrito a roles especificas
@Patch(':id')
@ApiBearerAuth()
@Roles(['director', 'manager'])
async update() { ... }
```

---

## 5. Frontend Auth Interceptor

```typescript
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const token = localStorage.getItem('accessToken');

  const clonedReq = token
    ? req.clone({
        headers: req.headers.set('Authorization', `Bearer ${token}`)
      })
    : req;

  return next(clonedReq);
};
```

### Frontend Error Handler (401)

```typescript
class AuthErrorHandler implements ErrorHandler {
  router = inject(Router);

  handleError(error: Error) {
    if (error instanceof HttpErrorResponse && error.status === 401) {
      localStorage.removeItem('accessToken');
      this.router.navigate(['/', 'conta', 'autenticacao']);
    }
  }
}
```

---

## 6. Frontend Route Guards

```typescript
// Guard: requer role especifica
export const roleGuard = (role: string): CanActivateFn => {
  return () => {
    const auth = inject(AuthenticationFacade);
    return auth.auth$.pipe(
      map(user => user?.roles?.[role] ?? false),
      take(1),
    );
  };
};

// Guard: requer qualquer uma das roles
export const rolesGuard = (...roles: string[]): CanActivateFn => {
  return () => {
    const auth = inject(AuthenticationFacade);
    return auth.auth$.pipe(
      map(user => roles.some(role => user?.roles?.[role])),
      take(1),
    );
  };
};

// Uso nas rotas
{
  path: 'admin',
  canActivate: [rolesGuard('manager', 'director')],
  loadChildren: () => import('@devmx/account-feature-admin'),
}
```

---

## 7. Permission Checks no Controller

```typescript
// Verificacao de proprietario
if (entity.owner.id !== auth.id) {
  throw exceptionByError({ code: 403, message: 'Sem permissao' });
}

// Owner OU admin
if (entity.owner.id !== auth.id && !authIsAdmin(auth.roles)) {
  throw exceptionByError({ code: 403, message: 'Sem permissao' });
}

// Owner OU contribuidor
const isContributor = entity.contributors?.some(c => c.id === auth.id);
if (entity.owner.id !== auth.id && !isContributor) {
  throw exceptionByError({ code: 403, message: 'Sem permissao' });
}

// Helper de admin
function authIsAdmin(roles: Roles): boolean {
  return roles.director || roles.manager;
}
```

---

## 8. Cadeia de Guards

```
Request HTTP
    ↓
AuthGuard: Verifica JWT, extrai user
    ↓ (se @Allowed, pula)
RolesGuard: Verifica @Roles do endpoint
    ↓ (se sem @Roles, permite)
Controller: Verificacoes adicionais (owner, contributor)
    ↓
Facade/UseCase: Logica de negocio
```

---

## Como Aplicar em Qualquer Projeto

1. **Passwordless**: Use codigos temporarios por email em vez de senhas
2. **JWT com payload minimo**: Apenas { id, roles } no token
3. **Guard global**: APP_GUARD para AuthGuard (todas as rotas protegidas por padrao)
4. **@Allowed()**: Opt-in para endpoints publicos (mais seguro que opt-out)
5. **RBAC com guard separado**: RolesGuard verifica @Roles declarativo
6. **Interceptor no frontend**: Adiciona token automaticamente
7. **ErrorHandler global**: Redireciona para login em 401
8. **Route guards funcionais**: roleGuard() como funcao factory
9. **Permission checks inline**: Owner/admin/contributor no controller
10. **Code expiration**: Codigos temporarios com timestamp + TTL
