# State Management (Gerenciamento de Estado)

## Conceito

O gerenciamento de estado nesta arquitetura usa o **Facade Pattern** sobre uma classe base `State<T>` que encapsula um `BehaviorSubject` do RxJS. Nao depende de bibliotecas externas como NgRx ou Akita - e uma solucao leve e customizada.

---

## State Base Class

A fundacao de todo gerenciamento de estado:

```typescript
export class State<T> {
  private state$: BehaviorSubject<T>;

  constructor(initialState: T) {
    this.state$ = new BehaviorSubject<T>(initialState);
  }

  // Getter do estado atual (sincrono)
  protected get state(): T {
    return this.state$.getValue();
  }

  // Selector: extrai uma fatia do estado como Observable
  protected select<R>(selector: (state: T) => R): Observable<R> {
    return this.state$.pipe(
      map(selector),
      distinctUntilChanged()  // So emite quando o valor muda
    );
  }

  // Atualiza o estado (merge parcial + freeze)
  protected setState(newState: Partial<T>): void {
    const merged = { ...this.state, ...newState };
    this.state$.next(Object.freeze(merged));
  }
}
```

**Principios**:
- Estado imutavel (`Object.freeze`)
- Atualizacao parcial (spread merge)
- Selectors com `distinctUntilChanged` evitam re-renders desnecessarios
- Metodos `protected` - apenas subclasses acessam

---

## Entity Facade Pattern

A Facade estende `State<T>` e orquestra Use Cases:

```typescript
interface EntityState<T> {
  response: Page<T>;       // Dados paginados
  selected: T | null;      // Item selecionado
  params: QueryParams<T>;  // Parametros de busca atuais
}

class EntityFacade<T extends Entity> extends State<EntityState<T>> {
  // SELECTORS PUBLICOS (Observable)
  response$ = this.select(state => state.response);
  selected$ = this.select(state => state.selected);
  params$ = this.select(state => state.params);

  constructor(
    private findUseCase: UseCase<QueryParams<T>, Page<T>>,
    private findOneUseCase: UseCase<string, T>,
    private createUseCase: UseCase<EditableEntity<T>, T>,
    private updateUseCase: UseCase<{ id: string; data: EditableEntity<T> }, T>,
    private deleteUseCase: UseCase<string, T>,
    initialState: EntityState<T>
  ) {
    super(initialState);
  }

  // COMMANDS: Mutam estado via use cases

  load() {
    const request$ = this.findUseCase.execute(this.state.params);
    this.onLoad(request$);
  }

  loadOne(id: string) {
    const request$ = this.findOneUseCase.execute(id);
    this.onLoadOne(request$);
  }

  create(data: EditableEntity<T>) {
    const request$ = this.createUseCase.execute(data);
    this.onCreate(request$);
    return request$;
  }

  // PARAMETROS: Mudam estado e recarregam
  setParams(params: Partial<QueryParams<T>>) {
    this.setState({ params: { ...this.state.params, ...params } });
  }

  setPage(page: number, size = 10) {
    this.setParams({ page, size });
  }

  setFilter(filter: QueryFilter<T>) {
    this.setParams({ filter, page: 0 });  // Reseta pagina ao filtrar
  }

  setSort(sort: QuerySort<T>) {
    this.setParams({ sort });
  }

  // LIFECYCLE HOOKS (protegidos)
  protected onLoad(request$: Observable<Page<T>>) {
    request$.pipe(take(1)).subscribe(response => {
      this.setState({ response });
    });
  }

  protected onLoadOne(request$: Observable<T>) {
    request$.pipe(take(1)).subscribe(selected => {
      this.setState({ selected });
    });
  }

  protected onCreate(request$: Observable<T>) {
    request$.pipe(take(1)).subscribe(() => {
      this.load();  // Recarrega lista apos criar
    });
  }
}
```

---

## Facades Especializadas

### Authentication Facade

```typescript
interface AuthenticationState {
  auth: Authentication | null;
  message: string | null;
  loading: boolean;
  sended: boolean;
}

class AuthenticationFacade extends State<AuthenticationState> {
  // Selectors
  auth$ = this.select(state => state.auth);
  message$ = this.select(state => state.message);
  loading$ = this.select(state => state.loading);
  connected$ = this.select(() => !!this.accessToken);

  constructor(
    private createUserUseCase: CreateUserUseCase,
    private sendUserCodeUseCase: SendUserCodeUseCase,
    private validateUserCodeUseCase: ValidateUserCodeUseCase,
    private loadAuthenticationUseCase: LoadAuthenticationUseCase
  ) {
    super({ auth: null, message: null, loading: false, sended: false });
  }

  load() {
    this.loadAuthenticationUseCase.execute()
      .pipe(take(1))
      .subscribe(auth => this.setState({ auth }));
  }

  sendUserCode(data: SendUserCode) {
    this.setState({ loading: true });
    this.sendUserCodeUseCase.execute(data)
      .pipe(take(1))
      .subscribe(({ message }) => {
        this.setState({ sended: true, loading: false, message });
      });
  }

  signOut() {
    this.setState({ auth: null, message: null, loading: false, sended: false });
    localStorage.removeItem('accessToken');
  }
}
```

### Layout Facade (UI State)

```typescript
interface LayoutState {
  loader: boolean;
  mobile: boolean;
  sidenav: { opened: boolean };
  sections: SectionHeaderOptions[];
}

class LayoutFacade extends State<LayoutState> {
  loader$ = this.select(state => state.loader);
  mobile$ = this.select(state => state.mobile);
  sidenav$ = this.select(state => state.sidenav);
  sections$ = this.select(state => state.sections);

  constructor(media: MediaMatcher, sections: SectionHeaderOptions[]) {
    super(initialState);

    // Reativo a media queries
    const mql = media.matchMedia('(max-width: 600px)');
    mql.addEventListener('change', (e) => {
      this.setState({ mobile: e.matches });
    });
  }

  loadNavLinks(roles: AccountRole) {
    const filtered = navLinksValidator(this.sections, roles);
    this.setState({ sections: filtered });
  }

  toggleSidenav() {
    const opened = !this.state.sidenav.opened;
    this.setState({ sidenav: { opened } });
  }
}
```

---

## Server-Side Facade (Simples)

No backend, a Facade e mais simples - apenas traduz entre Use Case e DTO:

```typescript
class CoursesFacade {
  constructor(
    private createUseCase: CreateCourseUseCase,
    private findUseCase: FindCoursesUseCase,
    private updateUseCase: UpdateCourseUseCase,
    private deleteUseCase: DeleteCourseUseCase
  ) {}

  async create(data: EditableCourse) {
    const course = await this.createUseCase.execute(data);
    return plainToInstance(CourseDto, course);  // Entity → DTO
  }

  async find(params: QueryParamsDto<Course>) {
    const { data, items, pages } = await this.findUseCase.execute(params);
    const courses = plainToInstance(CourseDto, data);
    return new PageDto(courses, items, pages);
  }
}
```

---

## Fluxo de Dados Completo (Frontend)

```
Component           Facade              Use Case           Service
    │                  │                    │                  │
    │── setFilter() ──→│                    │                  │
    │                  │── setState() ──→   │                  │
    │                  │                    │                  │
    │── load() ───────→│                    │                  │
    │                  │── execute() ──────→│                  │
    │                  │                    │── find() ───────→│
    │                  │                    │                  │── HTTP GET
    │                  │                    │←── Observable ───│
    │                  │←── Page<T> ───────│                  │
    │                  │── setState() ──→   │                  │
    │                  │                    │                  │
    │←── response$ ────│  (via select)      │                  │
    │    async pipe    │                    │                  │
```

---

## Consumo no Template

```html
<!-- Async pipe subscreve ao Observable -->
@if (facade.response$ | async; as response) {
  <!-- Lista com tracking -->
  @for (item of response.data; track item.id) {
    <app-card [data]="item" />
  }

  <!-- Paginacao -->
  <mat-paginator
    [length]="response.items"
    [pageSize]="10"
    (page)="facade.setPage($event.pageIndex, $event.pageSize)"
  />
}
```

---

## Principios do State Management

| Principio | Implementacao |
|-----------|---------------|
| **Single Source of Truth** | BehaviorSubject no State base |
| **Imutabilidade** | Object.freeze em cada setState |
| **Selectors** | `select()` com `distinctUntilChanged` |
| **Unidirectional Data Flow** | Component → Command → State → Selector → Template |
| **Separation of Concerns** | Facade = orquestrador, State = container, UseCase = logica |

---

## Como Aplicar em Qualquer Projeto

1. **Crie uma classe `State<T>` base** com BehaviorSubject, select() e setState()
2. **Crie Facades por feature** estendendo State com estado especifico
3. **Exponha selectors como Observables publicos** (response$, loading$, etc.)
4. **Exponha commands como metodos publicos** (load, create, setFilter)
5. **Use `take(1)`** em subscriptions de commands (evita memory leaks)
6. **Resete pagina ao filtrar** (UX: evita pagina vazia)
7. **Recarregue apos mutacoes** (create/update/delete → load)
