# Frontend Patterns (Padroes de Frontend)

## Conceito

Os padroes de frontend combinam **standalone components**, **OnPush change detection**, **signal-based reactivity**, **facade state management** e **lazy-loaded feature routing** para criar uma aplicacao modular, performatica e testavel.

---

## 1. Container/Presentational Pattern

### Container (Smart Component)

O Container orquestra dados e logica. Ele injeta facades, subscreve a observables e coordena interacoes.

```typescript
@Component({
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [provideUserPhoto()],
  imports: [ReactiveFormsModule, UserComponent, ProfileComponent, MatTabsModule],
  template: `...`,
})
export class AccountContainer {
  // Dependencias injetadas
  userFacade = inject(UserFacade);
  userPhoto = inject(UserPhoto);

  // Estado local
  form = new UserForm();
  photo = signal('');
  saving = signal(false);

  constructor() {
    // Subscreve a dados e popula form
    this.userFacade.selected$.pipe(
      filter(user => !!user),
      take(1),
    ).subscribe(user => {
      this.form.patch(user);
      if (user.profile?.photo) this.photo.set(user.profile.photo);
    });

    // Auto-save com debounce
    this.form.valueChanges.pipe(
      takeUntilDestroyed(),
      debounceTime(4000),
      skip(1),
    ).subscribe(() => this.onSubmit());
  }

  onSubmit() {
    this.saving.set(true);
    this.userFacade.update(this.form.getRawValue())
      .pipe(take(1))
      .subscribe(() => this.saving.set(false));
  }
}
```

### Presentational (Dumb Component)

O Presentational apenas recebe dados e exibe. Zero logica de negocio.

```typescript
@Component({
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [MatCardModule, MatListModule, IconComponent, DatePipe, RouterLink],
  selector: 'devmx-album-card-list',
  template: `
    @for (album of data(); track album.id) {
      <mat-card>
        <mat-card-title>{{ album.title }}</mat-card-title>
        <mat-card-subtitle>{{ album.createdAt | date }}</mat-card-subtitle>
      </mat-card>
    }
  `,
})
export class AlbumCardListComponent {
  data = input<Album[]>([]);  // Input via signal API
}
```

**Regras**:
- Container: injeta services, gerencia estado, orquestra
- Presentational: recebe `input()`, emite `output()`, exibe

---

## 2. Standalone Components

Todos os componentes sao standalone - sem NgModules:

```typescript
@Component({
  standalone: true,                        // Sem NgModule
  imports: [MatButtonModule, RouterLink],  // Imports explicitos
  changeDetection: ChangeDetectionStrategy.OnPush,
  selector: 'devmx-my-component',
  templateUrl: './my.component.html',
})
export class MyComponent {}
```

**Principios**:
- Cada componente declara seus imports
- Nenhum `NgModule` compartilhado
- Providers no nivel da rota ou componente

---

## 3. OnPush Change Detection

**TODOS** os componentes usam `ChangeDetectionStrategy.OnPush`:

```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
})
```

**Consequencias**:
- Angular so re-renderiza quando: input muda, evento ocorre, Observable emite (async pipe), signal muda
- Performance superior em aplicacoes grandes
- Obriga uso de immutabilidade

---

## 4. Feature Shell Pattern

Cada dominio tem um `feature-shell` que orquestra routing e layout:

```typescript
// Rotas do shell
export const accountFeatureShellRoutes: Route[] = [
  {
    path: 'autenticacao',
    // Lazy loading de sub-features
    loadChildren: () =>
      import('@devmx/account-feature-auth')
        .then(m => m.accountFeatureAuthRoutes),
  },
  {
    path: '',
    canActivate: [roleGuard('member')],       // Guard de autenticacao
    providers: accountFeatureShellProviders,    // Providers da feature
    component: AccountFeatureShellComponent,   // Shell wrapper
    children: [
      {
        path: 'administracao',
        canActivate: [rolesGuard('manager', 'director')],
        loadChildren: () =>
          import('@devmx/account-feature-admin')
            .then(m => m.accountFeatureAdminRoutes),
      },
      {
        path: 'configuracoes',
        component: AccountContainer,
        resolve: { user: accountResolver },
      },
      { path: '', component: HomeContainer },
    ],
  },
];

// Shell component
@Component({
  template: `<devmx-layout />`,
  imports: [RouterModule, LayoutComponent],
})
export class AccountFeatureShellComponent implements OnInit {
  authFacade = inject(AuthenticationFacade);
  layoutFacade = inject(LayoutFacade);

  ngOnInit() {
    this.authFacade.auth$.pipe(
      takeUntilDestroyed(this.destroyRef)
    ).subscribe(user => {
      if (user) this.layoutFacade.loadNavLinks(user.roles);
    });
  }
}
```

---

## 5. Route-Level Providers

Providers configurados no nivel da rota em vez de global:

```typescript
// Providers da feature
export const accountFeatureShellProviders: Provider[] = [
  provideHttpGithubService(),
  provideGithubFacade(),
  provideFormDialog(),
];

// Usados na rota
{
  path: '',
  providers: accountFeatureShellProviders,  // DI escopado
  component: ShellComponent,
}
```

**Beneficio**: Providers so existem quando a feature esta ativa (lazy loaded).

---

## 6. Resolvers Funcionais

```typescript
export const accountResolver: ResolveFn<User> = () => {
  const authFacade = inject(AuthenticationFacade);
  const userFacade = inject(UserFacade);

  return authFacade.auth$.pipe(
    filter(auth => !!auth),
    take(1),
    switchMap(auth => userFacade.findOne(auth.id)),
  );
};

// Uso na rota
{
  path: ':id',
  resolve: { user: accountResolver },
  component: UserDetailComponent,
}
```

---

## 7. Guards Funcionais

```typescript
// Guard de role unica
export const roleGuard = (role: string): CanActivateFn => {
  return () => {
    const auth = inject(AuthenticationFacade);
    return auth.auth$.pipe(
      map(user => user?.roles?.[role] ?? false),
      take(1),
    );
  };
};

// Guard de multiplas roles
export const rolesGuard = (...roles: string[]): CanActivateFn => {
  return () => {
    const auth = inject(AuthenticationFacade);
    return auth.auth$.pipe(
      map(user => roles.some(role => user?.roles?.[role])),
      take(1),
    );
  };
};
```

---

## 8. Template Syntax Moderno

### @defer (Lazy Rendering)

```html
@defer (on timer(500ms)) {
  @if (facade.response$ | async; as response) {
    @for (album of response.data; track album.id) {
      @defer (on viewport) {
        <devmx-album-card [data]="album" />
      } @placeholder {
        <devmx-skeleton [rows]="3" />
      }
    }
  }
} @placeholder {
  <devmx-skeleton [rows]="3" />
}
```

### @for com track

```html
@for (control of form.contributors.controls; track control.value; let i = $index) {
  <mat-list-item>
    <span>{{ control.value.displayName }}</span>
    <button (click)="form.contributors.removeAt(i)">Remove</button>
  </mat-list-item>
}
```

### @if com async pipe

```html
@if (facade.loading$ | async) {
  <mat-spinner />
}

@if (facade.response$ | async; as response) {
  <span>{{ response.items }} resultados</span>
}
```

---

## 9. HTTP Interceptors Funcionais

```typescript
// Auth interceptor - adiciona token a todas as requests
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const token = localStorage.getItem('accessToken');
  const clonedReq = token
    ? req.clone({ headers: req.headers.set('Authorization', `Bearer ${token}`) })
    : req;
  return next(clonedReq);
};

// Loader interceptor - mostra/esconde loading
export const loaderInterceptor: HttpInterceptorFn = (req, next) => {
  const layout = inject(LayoutFacade);
  layout.setLoader(true);
  return next(req).pipe(
    finalize(() => layout.setLoader(false))
  );
};

// Registro
provideHttpClient(withInterceptors([authInterceptor, loaderInterceptor]))
```

---

## 10. Error Handler Global

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

// Registro
{ provide: ErrorHandler, useClass: AuthErrorHandler }
```

---

## 11. App Configuration

```typescript
export const appConfig: ApplicationConfig = {
  providers: [
    // Rendering
    provideZoneChangeDetection({ eventCoalescing: true }),

    // Routing
    provideRouter(appRoutes, withViewTransitions(), withHashLocation()),

    // HTTP
    provideHttpClient(withInterceptors([authInterceptor, loaderInterceptor])),

    // Domain providers
    ...provideAccount(),
    ...provideCareer(),
    ...provideEvent(),
    ...provideAlbum(),
  ],
};
```

---

## Como Aplicar em Qualquer Projeto

1. **Standalone components** - sem NgModules
2. **OnPush em TUDO** - performance e previsibilidade
3. **Container/Presentational** - separe logica de apresentacao
4. **Feature Shell** - cada dominio tem seu routing raiz
5. **Route-level providers** - DI escopado por feature
6. **Functional guards/resolvers** - funcoes em vez de classes
7. **@defer para lazy rendering** - carregamento progressivo
8. **Interceptors funcionais** - auth token, loading, error handling
9. **Signals para estado local** - menos boilerplate que BehaviorSubject
10. **async pipe no template** - auto-subscribe/unsubscribe
