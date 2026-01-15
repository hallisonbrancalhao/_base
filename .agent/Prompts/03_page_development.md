# Page Development - Angular 20+ • PrimeNG 20+ • Design System Integration

## Contexto Técnico (Obrigatório)

Você é especialista em desenvolvimento de páginas Angular usando:
- Angular 20+ standalone (signals, input/output, @if/@for/@switch)
- PrimeNG 20+ via **MCP Server** (consulta direta à documentação oficial)
- Tailwind 4 + plugin **tailwindcss-primeui**
- Design System definido no prompt 01 (tokens, tema, paleta)
- Componentes criados no prompt 02 (wrappers, showcases)

## Input

**[SCREENSHOT OU FIGMA URL]**

---

## Workflow Obrigatório

### 1. Analisar o Design Visualmente

Olhe para a imagem e identifique:

**→ Estrutura de Layout**
- Quantas seções/colunas principais?
- Há sidebar? Header? Footer?
- Qual a estrutura do grid? (1-coluna, 2-colunas, 3-colunas)
- Containers, widths e padrões de spacing

**→ UI Sections**
- Quebre a página em seções lógicas (topo para baixo, esquerda para direita)
- Nomeie cada seção por seu propósito (ex.: "Sidebar", "NavigationBar", "TaskList", "ChatPanel")

**→ Hierarquia de Conteúdo**
- Quais são os headings principais?
- Qual o conteúdo principal vs. conteúdo de suporte?
- Quais são os call-to-action elements?

---

### 2. Mapear Elementos Visuais para Componentes shadcn

Para cada elemento UI identificado, mapeie para um componente:

| Visual Element | shadcn Component | Notes |
|----------------|------------------|-------|
| Navigation sidebar | Sidebar | Use sidebar components |
| Tabs/segmented control | Tabs | For section switching |
| Cards with content | Card | CardHeader, CardContent, etc. |
| Form inputs | Input, Select, etc. | With proper labels |
| Action buttons | Button | Primary/secondary variants |
| Data lists | Table or custom list | Based on complexity |
| Modals/dialogs | Dialog | For overlays |
| Dropdown menus | DropdownMenu | For action menus |
| Tooltips | Tooltip | For hints |
| Progress indicators | Progress | For loading/status |

---

### 3. Definir Estrutura de Componentes

```
page-[name]/
├── page-[name].component.ts      # Smart component (container)
├── page-[name].component.html    # Template principal
├── components/
│   ├── [name]-header/            # Header section
│   ├── [name]-sidebar/           # Sidebar (se houver)
│   ├── [name]-content/           # Main content area
│   └── [name]-[section]/         # Outras seções identificadas
└── models/
    └── [name].models.ts          # Interfaces locais
```

---

### 4. Criar Componente de Página

```typescript
// page-[name].component.ts
@Component({
  selector: 'app-page-[name]',
  standalone: true,
  imports: [
    // PrimeNG components
    // Design system components (ds-*)
    // Local section components
  ],
  template: `
    <div class="min-h-screen bg-surface-50 dark:bg-surface-950">
      <!-- Layout structure based on analysis -->

      @if (showSidebar()) {
        <aside class="...">
          <app-[name]-sidebar />
        </aside>
      }

      <main class="...">
        <app-[name]-header />
        <app-[name]-content [data]="data()" />
      </main>
    </div>
  `
})
export class Page[Name]Component {
  // Inject facade
  private readonly facade = inject([Name]Facade);

  // Signals from facade
  protected readonly data = this.facade.data;
  protected readonly isLoading = this.facade.isLoading;
  protected readonly showSidebar = signal(true);
}
```

---

### 5. Implementar Seções como Componentes Filhos

Para cada seção identificada, criar componente presentational:

```typescript
// components/[name]-header/[name]-header.component.ts
@Component({
  selector: 'app-[name]-header',
  standalone: true,
  imports: [/* PrimeNG, DS components */],
  template: `
    <header class="flex items-center justify-between p-4 border-b border-surface-200 dark:border-surface-700">
      <div class="flex items-center gap-4">
        <h1 class="text-2xl font-semibold text-surface-900 dark:text-surface-0">
          {{ title() }}
        </h1>
      </div>

      <div class="flex items-center gap-2">
        <!-- Action buttons -->
        <p-button
          label="Action"
          icon="pi pi-plus"
          (onClick)="onAction.emit()" />
      </div>
    </header>
  `
})
export class [Name]HeaderComponent {
  title = input.required<string>();
  onAction = output<void>();
}
```

---

### 6. Consultas MCP PrimeNG

Antes de implementar, consultar documentação:

```
# Para layouts
mcp__primeng__suggest_component { use_case: "sidebar navigation" }
mcp__primeng__get_component { component: "Drawer" }

# Para grids de dados
mcp__primeng__get_component { component: "Table" }
mcp__primeng__get_component_sections { component: "Table" }

# Para formulários
mcp__primeng__get_form_components
mcp__primeng__get_component { component: "Select" }

# Para overlays
mcp__primeng__get_overlay_components
mcp__primeng__get_component { component: "Dialog" }
```

---

### 7. Responsividade Mobile-First

```typescript
// Layout responsivo padrão
template: `
  <div class="flex flex-col lg:flex-row min-h-screen">
    <!-- Sidebar: hidden mobile, visible desktop -->
    <aside class="hidden lg:block lg:w-64 xl:w-72
                  bg-surface-0 dark:bg-surface-900
                  border-r border-surface-200 dark:border-surface-700">
      <!-- sidebar content -->
    </aside>

    <!-- Mobile header with menu toggle -->
    <header class="lg:hidden flex items-center justify-between p-4
                   bg-surface-0 dark:bg-surface-900
                   border-b border-surface-200 dark:border-surface-700">
      <p-button
        icon="pi pi-bars"
        styleClass="p-button-text"
        (onClick)="toggleMobileSidebar()" />
      <h1 class="text-lg font-semibold">{{ title }}</h1>
    </header>

    <!-- Main content -->
    <main class="flex-1 p-4 md:p-6 lg:p-8">
      <!-- content -->
    </main>
  </div>
`
```

---

### 8. State Management via Facade

```typescript
// [name].facade.ts (em data-access)
@Injectable({ providedIn: 'root' })
export class [Name]Facade {
  private readonly repository = inject([Name]Repository);

  // State signals
  private readonly _data = signal<[Name]Data | null>(null);
  private readonly _isLoading = signal(false);
  private readonly _error = signal<string | null>(null);

  // Public readonly signals
  readonly data = this._data.asReadonly();
  readonly isLoading = this._isLoading.asReadonly();
  readonly error = this._error.asReadonly();

  // Computed signals
  readonly hasData = computed(() => this._data() !== null);

  // Actions
  async loadData(): Promise<void> {
    this._isLoading.set(true);
    try {
      const result = await firstValueFrom(this.repository.getData());
      this._data.set(result);
    } catch (err) {
      this._error.set('Erro ao carregar dados');
    } finally {
      this._isLoading.set(false);
    }
  }
}
```

---

## Output Esperado

### 1. Análise do Design (breve)

```markdown
**Layout identificado**: [sidebar + main content / single column / etc.]
**Seções principais**:
1. [Nome] - [descrição]
2. [Nome] - [descrição]
3. ...

**Componentes PrimeNG sugeridos**:
- p-sidebar / p-drawer para navegação lateral
- p-table para listagem de dados
- p-dialog para modais
- ...

**Breakpoints necessários**:
- Mobile: [comportamento]
- Tablet: [comportamento]
- Desktop: [comportamento]
```

### 2. Estrutura de Arquivos

```
libs/[escopo]/feature-[name]/
├── src/lib/
│   ├── page-[name]/
│   │   ├── page-[name].component.ts
│   │   └── components/
│   │       ├── [name]-header.component.ts
│   │       ├── [name]-sidebar.component.ts
│   │       └── [name]-content.component.ts
│   └── index.ts
└── src/index.ts
```

### 3. Código dos Componentes

```typescript
// Código completo de cada componente
// Seguindo padrões Angular 20+ e PrimeNG 20+
```

### 4. Rotas

```typescript
// Configuração de rotas lazy-loaded
export const PAGE_ROUTES: Routes = [
  {
    path: '',
    component: Page[Name]Component,
  }
];
```

### 5. Facade (se necessário)

```typescript
// Facade para gerenciamento de estado da página
```

---

## Validação Final (Checklist)

Antes de entregar, verificar:

### Estrutura
- [ ] Layout responsivo mobile-first
- [ ] Seções quebradas em componentes filhos
- [ ] Smart component (page) + Dumb components (sections)
- [ ] Facade pattern para state management

### PrimeNG 20+
- [ ] Componentes (não diretivas): `p-button`, `p-table`, `p-select`
- [ ] Templates com `#`: `#header`, `#body`, `#footer`
- [ ] `class=""` na maioria, `styleClass=""` só em `p-button`

### Angular 20+
- [ ] Standalone components
- [ ] Signals para estado: `signal()`, `computed()`
- [ ] `input()` / `output()` (não @Input/@Output)
- [ ] `@if` / `@for` / `@switch` (não *ngIf/*ngFor)

### Dark Mode & Tokens
- [ ] Cores usando tokens surface (`bg-surface-0 dark:bg-surface-950`)
- [ ] Sem gray/zinc hardcoded
- [ ] `dark:` prefix em todas as cores

### Responsividade
- [ ] Mobile-first (base → sm: → md: → lg:)
- [ ] Touch targets >= 44px (`min-h-11 min-w-11`)
- [ ] Texto base >= 16px (`text-base`)
- [ ] Sidebar comportamento mobile (drawer ou hidden)

### Acessibilidade
- [ ] Headings hierárquicos (h1 → h2 → h3)
- [ ] Labels em todos os inputs
- [ ] Focus states visíveis
- [ ] Contraste adequado

---

## Exemplos de Queries MCP

### Encontrar componente para layout:
```
mcp__primeng__suggest_component { use_case: "dashboard with sidebar and cards" }
```

### Ver todos os componentes de data:
```
mcp__primeng__get_data_components
```

### Comparar opções de navegação:
```
mcp__primeng__compare_components { component1: "Tabs", component2: "TabMenu" }
```

### Ver exemplo de tabela com filtros:
```
mcp__primeng__get_example { component: "Table", section: "filter" }
```

### Customização via Pass Through:
```
mcp__primeng__get_component_pt { component: "Drawer" }
```

---

## Referência Rápida: Layout Patterns

| Pattern | Estrutura | Uso |
|---------|-----------|-----|
| **Dashboard** | Sidebar + Header + Grid de Cards | Admin panels |
| **List-Detail** | Lista lateral + Detail pane | Email, chat |
| **Single Column** | Header + Content + Footer | Landing pages |
| **Split View** | 2 painéis lado a lado | Comparações |
| **Wizard** | Steps + Content + Navigation | Onboarding |

---

**Versão**: 1.0.0
**Compatível com**: Angular 20+, PrimeNG 20+, Tailwind 4+
