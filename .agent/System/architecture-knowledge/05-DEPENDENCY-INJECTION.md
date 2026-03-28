# Dependency Injection (Injecao de Dependencia)

## Conceito

Dependency Injection (DI) e um padrao onde as dependencias de uma classe sao **fornecidas externamente** em vez de criadas internamente. Isso inverte o controle: quem cria e configura e o container de DI, nao a classe consumidora.

---

## Tipos de Tokens de Injecao

### 1. Abstract Class Token
A classe abstrata serve simultaneamente como **contrato** e **token de injecao**:

```typescript
// A propria classe abstrata e o token
abstract class CoursesService {
  abstract create(data): Promise<Course>;
  abstract find(params): Promise<Page<Course>>;
}

// Registro: provide = a classe abstrata
{ provide: CoursesService, useClass: CoursesMongoServiceImpl }

// Consumo: injeta pela classe abstrata
class CreateCourseUseCase {
  constructor(private coursesService: CoursesService) {}
}
```

### 2. String Token
Para quando nao existe uma classe abstrata:

```typescript
// Token como string
{ provide: 'MONGO_URI', useFactory: (env) => buildMongoUri(env), inject: [Env] }

// Consumo com @Inject
constructor(@Inject('MONGO_URI') private mongoUri: string) {}
```

### 3. Class Token (Concreta)
Quando a propria classe concreta e o token (singletons, config):

```typescript
// Classe como token
{ provide: Env, useValue: envConfig }

// Consumo direto
constructor(private env: Env) {}
```

### 4. Custom Token
Tokens tipados para valores especificos:

```typescript
// Criacao do token
const LAYOUT_SECTIONS = new InjectionToken<SectionOptions[]>('layout-sections');

// Registro
{ provide: LAYOUT_SECTIONS, useValue: sectionConfigs }

// Consumo
constructor(@Inject(LAYOUT_SECTIONS) private sections: SectionOptions[]) {}
```

---

## Provider Factory Functions

O padrao central de DI nesta arquitetura: **funcoes factory** que retornam descritores de provider.

### Service Provider (Port → Adapter)

```typescript
function createServiceProvider<A extends Abstract, T extends Type>(
  abstraction: A,       // Token = classe abstrata (Port)
  implementation: T,    // Classe concreta (Adapter)
  dependencies: any[]   // O que o Adapter precisa
) {
  return {
    provide: abstraction,
    useFactory(...params: any[]) {
      return new implementation(...params);
    },
    inject: dependencies,
  };
}

// Uso
function provideCoursesMongoService() {
  return createServiceProvider(
    CoursesService,
    CoursesMongoServiceImpl,
    [getModelToken('CourseCollection')]
  );
}
```

### Use Case Provider

```typescript
function createUseCaseProvider<T extends Type<UseCase>>(
  useCase: T,
  dependencies: any[]
) {
  return {
    provide: useCase,
    useFactory(...params: any[]) {
      return new useCase(...params);
    },
    inject: dependencies,
  };
}

// Uso
function provideCreateCourseUseCase() {
  return createUseCaseProvider(CreateCourseUseCase, [CoursesService]);
}
```

### Facade Provider (Client)

```typescript
function createClientProvider<T extends Type>(
  constructor: T,
  dependencies: any[]
) {
  return {
    provide: constructor,
    useFactory(...params: any[]) {
      return new constructor(...params);
    },
    deps: dependencies,  // 'deps' para Angular
  };
}

// Uso
function provideCourseFacade() {
  return createClientProvider(CourseFacade, [
    CreateCourseUseCase,
    FindCoursesUseCase,
    UpdateCourseUseCase,
    DeleteCourseUseCase,
  ]);
}
```

### Server Provider

```typescript
function createServerProvider<T extends Type>(
  constructor: T,
  dependencies: any[]
) {
  return {
    provide: constructor,
    useFactory(...params: any[]) {
      return new constructor(...params);
    },
    inject: dependencies,  // 'inject' para NestJS
  };
}
```

---

## Composicao de Providers

Providers sao agrupados em funcoes que retornam arrays, permitindo composicao modular:

```typescript
// Nivel 1: Providers individuais
function provideCoursesMongoService() { return createServiceProvider(...); }
function provideCreateCourseUseCase() { return createUseCaseProvider(...); }
function provideCourseFacade() { return createServerProvider(...); }

// Nivel 2: Agrupamento por tipo
function provideServices() {
  return [provideCoursesMongoService(), provideInstitutionsMongoService()];
}

function provideUseCases() {
  return [
    provideCreateCourseUseCase(),
    provideFindCoursesUseCase(),
    provideUpdateCourseUseCase(),
    provideDeleteCourseUseCase(),
  ];
}

function provideFacades() {
  return [provideCourseFacade(), provideInstitutionFacade()];
}

// Nivel 3: Agregacao total do dominio
function provideAcademy() {
  return [...provideServices(), ...provideUseCases(), ...provideFacades()];
}
```

### Uso na Aplicacao

```typescript
// NestJS Module
@Module({
  providers: [...provideAcademy()],
  exports: [...provideAcademy()],
})
export class AcademyDatabaseModule {}

// Angular App Config
export const appConfig: ApplicationConfig = {
  providers: [
    ...provideAccount(),
    ...provideCareer(),
    ...provideEvent(),
    ...provideAlbum(),
  ],
};

// Angular Route-level providers
const routes: Route[] = [{
  path: '',
  providers: accountFeatureShellProviders,
  component: ShellComponent,
}];
```

---

## Modulos Globais (NestJS)

O decorator `@Global()` torna um modulo acessivel em toda a aplicacao sem necessidade de re-importacao:

```typescript
@Global()
@Module({
  imports: [
    MongooseModule.forFeature([
      { name: SkillCollection.name, schema: SkillSchema },
    ]),
  ],
  providers: [...provideLearns()],
  exports: [...provideLearns()],
})
export class LearnDatabaseModule {}
```

---

## Dynamic Module Pattern (forRoot)

Configuracao que varia por ambiente usa o padrao `forRoot()`:

```typescript
@Module({})
export class SharedResourceModule {
  static forRoot(env: EnvConfig): DynamicModule {
    return {
      module: SharedResourceModule,
      global: true,
      providers: [
        provideEnv(env),
        provideMongoURI(),
      ],
      exports: [Env],
    };
  }
}

// Uso
@Module({
  imports: [SharedResourceModule.forRoot(env)],
})
export class AppModule {}
```

---

## APP_GUARD Pattern (Guards Globais)

Guards registrados como providers globais sao aplicados a TODAS as rotas:

```typescript
@Module({
  providers: [
    { provide: APP_GUARD, useClass: AuthGuard },
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
  ],
})
export class AccountResourceModule {}
```

Ordem de execucao: AuthGuard → JwtAuthGuard → RolesGuard

---

## Angular inject() Function

No frontend Angular, o `inject()` substitui constructor injection:

```typescript
// Antes (constructor injection)
class MyComponent {
  constructor(
    private facade: CourseFacade,
    private route: ActivatedRoute
  ) {}
}

// Agora (inject function)
class MyComponent {
  facade = inject(CourseFacade);
  route = inject(ActivatedRoute);
}
```

**Vantagens**: Mais conciso, funciona em funcoes standalone, permite uso em campos.

---

## ControlContainer Pattern (Formularios)

Injecao de contexto de formulario pai em componentes filhos:

```typescript
@Component({
  viewProviders: [{
    provide: ControlContainer,
    useFactory: () => inject(ControlContainer, { skipSelf: true }),
  }],
})
export class UserProfileComponent {
  container = inject(ControlContainer);

  get form() {
    return this.container.control as UserProfileForm;
  }
}
```

---

## Principios da DI nesta Arquitetura

1. **Ports como tokens**: Classes abstratas servem como token E contrato
2. **Factory functions**: Toda criacao de provider via funcao factory
3. **Composicao aditiva**: Spread operator para compor arrays de providers
4. **Hierarquia de escopos**: Global → Module → Route → Component
5. **Framework-agnostico**: Factories funcionam com Angular (`deps`) e NestJS (`inject`)
6. **Zero `new` no codigo de consumo**: Tudo instanciado pelo container

---

## Como Aplicar em Qualquer Projeto

1. **Crie factory helpers** (`createServiceProvider`, `createUseCaseProvider`)
2. **Agrupe providers por dominio** (`provideAccount()`, `provideCareer()`)
3. **Use classes abstratas como tokens** - dispensa strings magicas
4. **Componha providers com spread** - `[...provideServices(), ...provideUseCases()]`
5. **Escope providers ao nivel correto** - Global para infra, Route para features
6. **Nunca use `new` diretamente** - sempre injete via construtor ou `inject()`
