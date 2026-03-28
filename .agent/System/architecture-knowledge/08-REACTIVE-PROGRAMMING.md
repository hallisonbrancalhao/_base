# Reactive Programming (Programacao Reativa)

## Conceito

Programacao reativa trata dados como **streams** (fluxos) que emitem valores ao longo do tempo. Em vez de pedir dados imperativamente, voce **declara transformacoes** e o sistema reage automaticamente a mudancas.

---

## RxJS: Fundamentos Usados

### Operadores Essenciais

```typescript
// take(1) - Pega apenas o primeiro valor e completa
request$.pipe(take(1)).subscribe(data => { ... });

// filter - Filtra valores que nao atendem condicao
auth$.pipe(filter(auth => !!auth))

// switchMap - Cancela observable anterior e troca para novo
auth$.pipe(
  switchMap(auth => userService.findOne(auth.id))
)

// map - Transforma o valor
state$.pipe(map(state => state.response))

// distinctUntilChanged - So emite quando valor muda
state$.pipe(map(s => s.count), distinctUntilChanged())

// debounceTime - Espera N ms de inatividade antes de emitir
form.valueChanges.pipe(debounceTime(4000))

// skip(N) - Ignora os primeiros N valores
form.valueChanges.pipe(skip(1))  // Ignora valor inicial

// combineLatest - Combina ultimos valores de multiplos observables
combineLatest([user$, params$]).pipe(...)

// takeUntilDestroyed - Auto-unsubscribe quando componente e destruido
route.queryParams.pipe(takeUntilDestroyed())
```

### Patterns Comuns

#### 1. Auto-Save com Debounce

```typescript
this.form.valueChanges.pipe(
  takeUntilDestroyed(),  // Cleanup automatico
  debounceTime(4000),    // Espera 4s de inatividade
  skip(1),               // Ignora emissao inicial
).subscribe(() => this.onSubmit());
```

#### 2. Route → Facade Sync

```typescript
constructor() {
  this.route.queryParams
    .pipe(takeUntilDestroyed())
    .subscribe(params => {
      const { page = 0, size = 10, title } = params;
      this.facade.setParams({ page, size, filter: { title } });
      this.facade.load();
    });
}
```

#### 3. Multi-Source Combination

```typescript
const user$ = this.authFacade.auth$.pipe(filter(a => !!a));
const params$ = this.route.queryParams;

combineLatest([user$, params$])
  .pipe(takeUntilDestroyed())
  .subscribe(([user, params]) => {
    this.facade.setParams({ ...params, owner: user.id });
    this.facade.load();
  });
```

#### 4. Resolver com Chain

```typescript
const accountResolver: ResolveFn<User> = () => {
  const authFacade = inject(AuthenticationFacade);
  const userFacade = inject(UserFacade);

  return authFacade.auth$.pipe(
    filter(auth => !!auth),         // Espera auth existir
    take(1),                         // Pega primeiro valor valido
    switchMap(auth =>                // Troca para busca do usuario
      userFacade.findOne(auth.id)
    ),
  );
};
```

#### 5. Request → Reload Pattern

```typescript
create(data: EditableEntity<T>): Observable<T> {
  const request$ = this.createUseCase.execute(data);

  request$.pipe(take(1)).subscribe(() => {
    this.load();  // Recarrega lista apos criar
  });

  return request$;  // Retorna para o chamador tambem
}
```

---

## Signals: O Novo Paradigma

Angular 17+ introduziu Signals como alternativa ao RxJS para estado local de componentes.

### Signal Basico

```typescript
class MyComponent {
  // Estado reativo local
  photo = signal('');
  saving = signal(false);
  count = signal(0);

  // Atualizar
  updatePhoto(url: string) {
    this.photo.set(url);
  }

  increment() {
    this.count.update(c => c + 1);
  }
}
```

### Computed (Derivado)

```typescript
class UploadComponent {
  queue = signal<UploadItem[]>([]);

  // Automaticamente recalculado quando queue muda
  total = computed(() => this.queue().length);
  completed = computed(() =>
    this.queue().filter(item => item.progress() >= 100).length
  );
  progress = computed(() =>
    this.total() > 0 ? (this.completed() / this.total()) * 100 : 0
  );
}
```

### Effect (Efeito Colateral)

```typescript
class UploadComponent {
  queue = signal<UploadItem[]>([]);
  completed = signal(0);

  constructor() {
    // Executa quando qualquer signal referenciado muda
    effect(() => {
      const done = this.queue().filter(i => i.progress() >= 90).length;
      this.completed.set(done);
    });
  }
}
```

### input() Signal (Angular 17.2+)

```typescript
class CardComponent {
  // Substitui @Input() decorator
  data = input<Album>();                  // Opcional
  title = input.required<string>();       // Obrigatorio
  size = input<number>(10);               // Com default
}
```

### output() Signal (Angular 17.2+)

```typescript
class AutoSaveButton {
  saving = input.required<boolean>();
  autoSave = output<FormData>();  // Substitui @Output() + EventEmitter
}
```

---

## Signals vs RxJS: Quando Usar Cada

| Cenario | Signals | RxJS |
|---------|---------|------|
| Estado local de componente | signal(), computed() | - |
| Inputs/Outputs | input(), output() | - |
| Estado global/compartilhado | - | BehaviorSubject + Facade |
| HTTP requests | - | Observable |
| Combinacao de streams | - | combineLatest, switchMap |
| Debounce, throttle | - | debounceTime, throttleTime |
| Route params | - | ActivatedRoute.queryParams |
| Cleanup automatico | - | takeUntilDestroyed() |

**Regra pratica**: Signals para estado **local e sincrono**, RxJS para **fluxos assincronos e composicao**.

---

## Lifecycle Management

### takeUntilDestroyed()

O pattern mais importante para evitar memory leaks:

```typescript
class MyComponent {
  constructor() {
    // Auto-unsubscribe quando componente e destruido
    this.observable$.pipe(
      takeUntilDestroyed()  // Detecta DestroyRef automaticamente
    ).subscribe(data => { ... });
  }
}
```

### take(1) para Requests

```typescript
// Para requests unicos (HTTP calls)
this.facade.create(data)
  .pipe(take(1))
  .subscribe(result => {
    this.router.navigate([result.id]);
  });
```

### DestroyRef Manual

```typescript
class CropDirective implements AfterViewInit {
  destroy = inject(DestroyRef);

  ngAfterViewInit() {
    this.el.addEventListener('mousemove', this.handler);

    // Cleanup manual
    this.destroy.onDestroy(() => {
      this.el.removeEventListener('mousemove', this.handler);
    });
  }
}
```

---

## Async Pipe no Template

O `async` pipe subscreve/unsubscreve automaticamente:

```html
<!-- Subscreve e exibe -->
@if (facade.response$ | async; as response) {
  <span>{{ response.items }} resultados</span>

  @for (item of response.data; track item.id) {
    <app-card [data]="item" />
  }
}

<!-- Loading state -->
@if (facade.loading$ | async) {
  <mat-spinner />
}
```

---

## Como Aplicar em Qualquer Projeto

1. **Signals para estado local** de componentes (counters, flags, UI state)
2. **RxJS para fluxos assincronos** (HTTP, WebSocket, route params)
3. **`takeUntilDestroyed()`** em TODO subscription manual
4. **`take(1)`** para requests HTTP (evita subscriptions pendentes)
5. **`debounceTime`** para auto-save e busca (evita chamadas excessivas)
6. **`combineLatest`** quando precisa de multiplas fontes simultaneas
7. **`async` pipe** no template sempre que possivel (auto-cleanup)
8. **`distinctUntilChanged`** em selectors (evita re-renders)
