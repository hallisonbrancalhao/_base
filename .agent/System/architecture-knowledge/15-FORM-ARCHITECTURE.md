# Form Architecture (Arquitetura de Formularios)

## Conceito

A arquitetura de formularios usa **Typed Reactive Forms** com classes customizadas que estendem `FormGroup<TypedForm<T>>`. Cada formulario e uma classe com logica de validacao, metodos de conveniencia e composicao hierarquica.

---

## 1. TypedForm<T> - O Tipo Base

```typescript
// Mapeia uma interface para controles tipados
type TypedForm<T> = {
  [K in keyof T]: T[K] extends object
    ? FormGroup<TypedForm<T[K]>>  // Campo objeto → FormGroup aninhado
    : FormControl<T[K]>;          // Campo escalar → FormControl
};

// Exemplo: TypedForm<UpdateUser>
// {
//   id: FormControl<string>;
//   profile: FormGroup<TypedForm<UserProfile>>;
//   contact: FormGroup<TypedForm<UserContact>>;
//   roles: FormGroup<TypedForm<Roles>>;
// }
```

---

## 2. Form Class Pattern

### Formulario Raiz

```typescript
export class UserForm extends FormGroup<TypedForm<UpdateUser>> {
  constructor() {
    super({
      id: new FormControl('', {
        nonNullable: true,
        validators: [Validators.required],
      }),
      profile: new UserProfileForm(),     // Sub-form
      contact: new UserContactForm(),     // Sub-form
      social: new UserSocialForm(),       // Sub-form
      roles: new UserRolesForm(),         // Sub-form
      skills: new UserSkillsForm(),       // Sub-form
      visibility: new UserVisibilityForm(), // Sub-form
    });
  }

  // Typed getters para sub-forms
  get profile() { return this.controls.profile as UserProfileForm; }
  get contact() { return this.controls.contact as UserContactForm; }
  get social() { return this.controls.social as UserSocialForm; }

  // Metodo customizado de patch
  patch(value: Partial<UpdateUser>) {
    this.patchValue(value);
    if (value.social?.length) {
      this.social.patchValue(value.social);
    }
  }
}
```

### Sub-Formularios

```typescript
export class UserProfileForm extends FormGroup<TypedForm<UserProfile>> {
  // Opcoes para selects
  genders: FormOption<Gender>[] = [
    { value: 'female', viewValue: 'Feminino' },
    { value: 'male', viewValue: 'Masculino' },
  ];

  constructor() {
    super({
      minibio: new FormControl('', {
        nonNullable: true,
        validators: [Validators.maxLength(102400)],
      }),
      birthday: new FormControl(),
      gender: new FormControl(),
      photo: new FormControl(),
    });
  }
}
```

---

## 3. FormArray Pattern

### FormArray Tipada

```typescript
class ContributorsForm extends FormArray<UserRefForm> {
  constructor() {
    super([]);
  }

  add(value?: UserRef) {
    this.push(new UserRefForm(value));
  }
}

class UserRefForm extends FormGroup<TypedForm<UserRef>> {
  constructor(value?: UserRef) {
    super({
      id: new FormControl(value?.id ?? '', { nonNullable: true }),
      name: new FormControl(value?.name ?? '', { nonNullable: true }),
      displayName: new FormControl(value?.displayName ?? '', { nonNullable: true }),
    });
  }
}
```

### Uso no Form Pai

```typescript
export class AlbumForm extends FormGroup<TypedForm<EditableAlbum>> {
  constructor() {
    super({
      title: new FormControl('', {
        nonNullable: true,
        validators: [Validators.required],
      }),
      contributors: new ContributorsForm(),
      photos: new PhotosForm(),
    });
  }

  get contributors() {
    return this.controls.contributors as ContributorsForm;
  }

  // Adicionar/remover contribuidores
  addContributor(user: UserRef) {
    this.contributors.add(user);
  }

  removeContributor(index: number) {
    this.contributors.removeAt(index);
  }
}
```

---

## 4. Validacao Dinamica

Validacoes que mudam com base em outros campos:

```typescript
export class EventForm extends FormGroup<TypedForm<EditableEvent>> {
  formats: FormOption<EventFormat>[] = [
    { value: 'online', viewValue: 'Online' },
    { value: 'in-person', viewValue: 'Presencial' },
    { value: 'hybrid', viewValue: 'Hibrido' },
  ];

  constructor() {
    super({
      format: new FormControl('online', { nonNullable: true }),
      address: new FormControl(),
      link: new FormControl(),
      // ...
    });
  }

  onFormatChange(format: EventFormat) {
    if (format === 'in-person') {
      this.controls.address.enable();
      this.controls.address.addValidators(Validators.required);
      this.controls.link.disable();
      this.controls.link.removeValidators(Validators.required);
    } else if (format === 'online') {
      this.controls.link.enable();
      this.controls.link.addValidators(Validators.required);
      this.controls.address.disable();
      this.controls.address.removeValidators(Validators.required);
    }
    this.updateValueAndValidity({ onlySelf: true });
  }
}
```

---

## 5. Custom Validators

```typescript
// Validator composto: username OU email
function usernameOrEmailValidator(control: FormControl) {
  const value = control.value;
  if (!value) return null;

  const isEmail = value.includes('@');
  if (isEmail) {
    const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return emailPattern.test(value) ? null : { invalidEmailOrUsername: true };
  } else {
    const usernamePattern = /^[a-z0-9]+$/;
    return usernamePattern.test(value) ? null : { invalidEmailOrUsername: true };
  }
}

// Uso
new FormControl('', {
  nonNullable: true,
  validators: [Validators.required, usernameOrEmailValidator],
})
```

---

## 6. Auto-Save Pattern

```typescript
class AccountContainer {
  form = new UserForm();

  constructor() {
    this.form.valueChanges.pipe(
      takeUntilDestroyed(),     // Cleanup automatico
      debounceTime(4000),       // Espera 4 segundos de inatividade
      skip(1),                  // Ignora valor inicial do form
    ).subscribe(() => this.onSubmit());
  }

  onSubmit() {
    if (this.form.valid) {
      this.saving.set(true);
      this.facade.update(this.form.getRawValue())
        .pipe(take(1))
        .subscribe(() => this.saving.set(false));
    }
  }
}
```

### Auto-Save Button Component

```typescript
@Component({
  selector: 'devmx-auto-save-button',
  viewProviders: [{
    provide: ControlContainer,
    useFactory: () => inject(ControlContainer, { skipSelf: true }),
  }],
})
export class AutoSaveButtonComponent<T> implements AfterViewInit {
  form = this.container.control as FormGroup<TypedForm<T>>;
  saving = input.required<boolean>();
  autoSave = output<T>();

  ngAfterViewInit() {
    this.form.valueChanges.pipe(
      takeUntilDestroyed(this.destroying$),
      debounceTime(4000),
      skip(1),
    ).subscribe(() => this.autoSave.emit(this.form.getRawValue() as T));
  }
}
```

---

## 7. Form Inheritance via ControlContainer

Componentes filhos acessam o formulario do pai:

```typescript
// Componente filho
@Component({
  selector: 'devmx-user-profile',
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

```html
<!-- Template do pai -->
<form [formGroup]="form">
  <!-- Componente filho acessa o form do pai -->
  <devmx-user-profile />
</form>
```

---

## 8. Form em Dialog/Sheet

```typescript
export class CreateAlbumSheet extends SheetComponent<EditableAlbum> {
  form = new AlbumForm();

  ngOnInit() {
    if (this.data) {
      this.form.patch(this.data);  // Popula se editando
    }
  }

  onSubmit() {
    if (this.form.valid) {
      this.close(this.form.getRawValue());  // Retorna dados ao caller
    } else {
      this.form.markAllAsTouched();  // Exibe erros
    }
  }
}
```

---

## 9. Template de Formulario

```html
<form [formGroup]="form" (submit)="onSubmit()">
  <!-- Campo texto -->
  <mat-form-field>
    <mat-label>Titulo</mat-label>
    <input matInput formControlName="title" />
    <mat-error>Obrigatorio</mat-error>
  </mat-form-field>

  <!-- Select com opcoes tipadas -->
  <mat-form-field>
    <mat-label>Formato</mat-label>
    <mat-select formControlName="format" (selectionChange)="form.onFormatChange($event.value)">
      @for (option of form.formats; track option.value) {
        <mat-option [value]="option.value">{{ option.viewValue }}</mat-option>
      }
    </mat-select>
  </mat-form-field>

  <!-- FormArray -->
  <mat-list formArrayName="contributors">
    @for (ctrl of form.contributors.controls; track ctrl.value; let i = $index) {
      <mat-list-item>
        <span>{{ ctrl.value.displayName }}</span>
        <button mat-icon-button (click)="form.contributors.removeAt(i)">
          <devmx-icon name="trash" />
        </button>
      </mat-list-item>
    }
  </mat-list>

  <!-- Markdown editor com form binding -->
  <devmx-markdown-toolbar>
    <devmx-markdown-editor
      label="Bio"
      formControlName="minibio"
      [maxRows]="64"
    />
  </devmx-markdown-toolbar>

  <!-- Submit -->
  <devmx-auto-save-button [saving]="saving()" (autoSave)="onSubmit()" />
</form>
```

---

## Principios da Form Architecture

| Principio | Implementacao |
|-----------|---------------|
| **Type safety** | FormGroup<TypedForm<T>> |
| **Composicao** | Sub-forms como classes separadas |
| **Reutilizacao** | FormArray com metodo add() |
| **Validacao contextual** | Dinamica via onFormatChange() |
| **Auto-save** | debounceTime + skip(1) |
| **Heranca de form** | ControlContainer + viewProviders |
| **Opcoes tipadas** | FormOption<T>[] para selects |

---

## Como Aplicar em Qualquer Projeto

1. **Crie `TypedForm<T>`** que mapeia interfaces para controles
2. **Uma classe por formulario** estendendo FormGroup<TypedForm<T>>
3. **Sub-forms como classes** para composicao modular
4. **FormArray com `add()`** para colecoes dinamicas
5. **Validacao dinamica** via metodos no form class
6. **Auto-save com debounce** para UX fluida
7. **ControlContainer** para heranca pai-filho sem prop drilling
8. **Opcoes no form class** (nao no template) para reutilizacao
