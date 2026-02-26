# Templates de Prompt para IA

> **Copie, preencha e cole no Claude Code ou outro assistente de IA**

---

## 🤖 Contexto Rápido (Adicione a TODO prompt)

```yaml
project:
  name: "@base/source"
  type: Nx Monorepo
  package_manager: bun

tech_stack:
  frontend: Angular 19+ (Standalone Components, Signals)
  api: GraphQL
  ui_library: PrimeNG 21+
  styling: Tailwind CSS 4+
  testing: Jest 30+

critical_rules:
  typescript:
    - "Max 5 statements per function"
    - "Max 3 parameters per function"
    - "Self-documenting names"
  angular:
    - "ALWAYS standalone components (NO NgModules)"
    - "ALWAYS use signals for state"
    - "ALWAYS use @if/@for (NOT *ngIf/*ngFor)"
    - "ALWAYS use input()/output() (NOT decorators)"
    - "ALWAYS use inject() (NOT constructor injection)"
  primeng:
    - "USE p-button, p-select, p-inputtext (components)"
    - "NEVER use pButton, pDropdown (directives)"
    - "USE #templateName (NOT pTemplate='name')"
  styling:
    - "USE surface-0 to surface-950 for colors"
    - "USE dark: prefix for dark mode"
    - "NEVER use Tailwind gray-* colors"
```

---

## 📚 Referência de Documentos

| Preciso saber sobre... | Leia este documento |
|------------------------|---------------------|
| Estrutura do projeto | `.agent/README.md` |
| Padrões de código limpo | `.agent/Agents/typescript_clean_code.md` |
| Estrutura de libs Nx | `.agent/System/libs_architecture_pattern.md` |
| Dependências entre libs | `.agent/System/nx_architecture_rules.md` |
| Padrões Angular | `.agent/System/angular_full.md` |
| Componentes PrimeNG | `.agent/System/primeng_best_practices.md` |
| Testes unitários | `.agent/System/angular_unit_testing_guide.md` |
| Dark mode | `.agent/System/dark_mode_reference.md` |
| Padrões DTO/Interface | `.agent/System/interface-dto-architecture.md` |
| Exports em libs | `.agent/System/barrel_best_practices.md` |
| Formato de commits | `.agent/SOPs/git_commit_instructions.md` |
| Template de PRD | `.agent/Tasks/README.md` |
| Exemplo de PRD completa | `.agent/Tasks/PRD-2026-01-001_user_management.md` |

---

## 🐛 Template 1: Corrigir Bug Simples

**Quando usar**: Bug em um único arquivo, causa clara

```markdown
Preciso corrigir um bug no projeto.

## Contexto do Projeto
- Leia `.agent/README.md` para estrutura e padrões críticos
- Siga `.agent/System/angular_full.md` para padrões Angular
- Siga `.agent/System/angular_unit_testing_guide.md` para testes

## Bug
- **Arquivo**: [CAMINHO_DO_ARQUIVO]
- **Problema**: [DESCREVA_O_PROBLEMA]
- **Esperado**: [COMPORTAMENTO_ESPERADO]
- **Atual**: [COMPORTAMENTO_ATUAL]

## Passos para Reproduzir
1. [PASSO_1]
2. [PASSO_2]
3. [PASSO_3]

## Tarefa
1. Analise o código em [CAMINHO]
2. Identifique a causa raiz
3. Proponha correção seguindo padrões `.agent/`
4. Forneça casos de teste
5. Mostre código antes/depois

## Requisitos Obrigatórios
- ✅ Max 5 statements por função
- ✅ Use signals (não BehaviorSubject)
- ✅ Componentes standalone
- ✅ Use @if/@for (não *ngIf/*ngFor)
- ✅ Use input()/output() (não decoradores)
- ✅ Inclua testes unitários com data-testid
- ✅ Sem erros no console
```

### Exemplo Preenchido:
```markdown
Preciso corrigir um bug no projeto.

## Contexto do Projeto
- Leia `.agent/README.md` para estrutura e padrões críticos
- Siga `.agent/System/angular_full.md` para padrões Angular
- Siga `.agent/System/angular_unit_testing_guide.md` para testes

## Bug
- **Arquivo**: libs/admin/feature-users/src/lib/pages/users-list-page/users-list-page.component.ts
- **Problema**: Botão "Adicionar Usuário" desabilitado mesmo com permissão
- **Esperado**: Botão habilitado quando usuário tem role "admin"
- **Atual**: Botão sempre desabilitado

## Passos para Reproduzir
1. Login como admin
2. Navegar para /admin/users
3. Verificar botão "Adicionar Usuário" - está desabilitado

## Tarefa
1. Analise o código nas linhas 45-60 (computed signal de permissão)
2. Identifique por que a verificação de role está falhando
3. Proponha correção seguindo padrões `.agent/`
4. Forneça casos de teste
5. Mostre código antes/depois

## Requisitos Obrigatórios
- ✅ Max 5 statements por função
- ✅ Use signals (não BehaviorSubject)
- ✅ Componentes standalone
- ✅ Use @if/@for (não *ngIf/*ngFor)
- ✅ Use input()/output() (não decoradores)
- ✅ Inclua testes unitários com data-testid
- ✅ Sem erros no console
```

---

## 🐛 Template 2: Investigar Bug Complexo (Paralelo)

**Quando usar**: Bug em múltiplos arquivos, causa desconhecida

```markdown
Preciso investigar e corrigir um bug complexo.

## Contexto do Projeto
- Leia `.agent/README.md`
- Siga `.agent/System/nx_architecture_rules.md` para boundaries
- Siga `.agent/System/angular_full.md` para padrões
- Siga `.agent/System/angular_unit_testing_guide.md` para testes

## Bug
- **Scope/Feature**: [NOME_SCOPE]
- **Arquivos Afetados**: [ARQUIVO_1], [ARQUIVO_2]
- **Problema**: [DESCRICAO_DETALHADA]
- **Impacto**: [COMO_AFETA_USUARIOS]

## Execute Estes Agentes EM PARALELO:

### Agente 1 - Investigação de Código
Tarefa: Analise [ARQUIVO_1] e [ARQUIVO_2] para identificar a causa raiz.
Verifique:
- Signals não propagando corretamente
- Problemas de subscription RxJS
- Condições de corrida
- State não atualizado

### Agente 2 - Análise de Testes
Tarefa: Revise testes em [ARQUIVO_SPEC].
Verifique:
- Cobertura atual do código afetado
- Cenários de teste faltantes
- Mocks estão corretos?
- Schemas configurados?

### Agente 3 - Revisão de Arquitetura
Tarefa: Valide contra `.agent/System/nx_architecture_rules.md`.
Verifique:
- Padrão facade correto?
- Lógica no lugar certo?
- Dependências permitidas?

## Após Execução Paralela, Forneça:
1. Causa raiz identificada
2. Código antes/depois da correção
3. Testes novos/atualizados
4. Recomendações arquiteturais
```

---

## ✨ Template 3: Nova Feature Simples

**Quando usar**: Feature em componente existente, sem nova lib

```markdown
Preciso implementar uma nova feature.

## Contexto do Projeto
- Leia `.agent/README.md` para padrões críticos
- Siga `.agent/System/angular_full.md` para componentes
- Siga `.agent/System/primeng_best_practices.md` para UI
- Siga `.agent/System/angular_unit_testing_guide.md` para testes

## Feature
- **Nome**: [NOME_FEATURE]
- **Scope**: [NOME_SCOPE]
- **User Story**: Como [USUARIO], quero [ACAO], para que [BENEFICIO]

## Requisitos Funcionais
1. [REQUISITO_1]
2. [REQUISITO_2]
3. [REQUISITO_3]

## Arquivos a Modificar
- Componente: [CAMINHO]
- Service/Facade: [CAMINHO]
- Testes: [CAMINHO]

## Tarefa
1. Projete implementação seguindo `.agent/`
2. Implemente usando signals e standalone components
3. Use padrão facade para lógica de negócio
4. Escreva testes com cobertura > 80%
5. Forneça código completo

## Requisitos de Código
```typescript
// ✅ FAÇA (patterns obrigatórios)
@Component({ imports: [...] })
name = input.required<string>();
clicked = output<void>();
private readonly facade = inject(MyFacade);
readonly items = this.facade.items;  // Signal

@if (loading()) { ... }
@for (item of items(); track item.id) { ... }

<p-button label="Save" />
<p-table [value]="data()">
  <ng-template #header>...</ng-template>
  <ng-template #body let-item>...</ng-template>
</p-table>

// ❌ NUNCA (proibido)
@NgModule({})
@Input() name: string;
@Output() clicked = new EventEmitter();
constructor(private service: MyService) {}
*ngIf="condition"
*ngFor="let x of items"
<button pButton>
<p-dropdown [options]="x">
```
```

---

## ✨ Template 4: Nova Feature com Libs (PRD)

**Quando usar**: Feature complexa que precisa de novas libs

```markdown
Preciso implementar uma feature complexa com novas libs Nx.

## Contexto do Projeto
- Leia `.agent/README.md` para estrutura
- Siga `.agent/System/nx_architecture_rules.md` para boundaries
- Siga `.agent/System/libs_architecture_pattern.md` para estrutura
- Veja exemplo: `.agent/Tasks/PRD-2026-01-001_user_management.md`

## Feature
- **Nome**: [NOME_FEATURE]
- **Scope**: [NOME_SCOPE] (novo ou existente)
- **User Story**: Como [USUARIO], quero [ACAO], para que [BENEFICIO]

## Requisitos Funcionais
1. [REQUISITO_1]
2. [REQUISITO_2]
3. [REQUISITO_3]

## Libs a Criar

```yaml
libs_to_create:
  - path: "libs/[scope]/domain"
    type: domain
    generator: "nx g @nx/js:lib domain --directory=[scope] --tags=type:domain,scope:[scope]"
    
  - path: "libs/[scope]/data-access"
    type: data-access
    generator: "nx g @nx/angular:lib data-access --directory=[scope] --standalone --tags=type:data-access,scope:[scope]"
    
  - path: "libs/[scope]/feature-[name]"
    type: feature
    generator: "nx g @nx/angular:lib feature-[name] --directory=[scope] --standalone --tags=type:feature,scope:[scope]"

dependency_graph:
  - from: "apps/web"
    to: ["[scope]/feature-[name]"]
    
  - from: "[scope]/feature-[name]"
    allowed: ["[scope]/data-access", "[scope]/domain", "shared/ui", "shared/utils"]
    forbidden: ["*/feature-*", "*/api"]
    
  - from: "[scope]/data-access"
    allowed: ["[scope]/domain", "shared/utils"]
    forbidden: ["*/feature-*", "*/ui-*"]
```

## Estrutura de Arquivos

```
libs/[scope]/
├── domain/
│   └── src/lib/
│       ├── [name].interface.ts
│       └── [name].enum.ts
├── data-access/
│   └── src/lib/
│       ├── facades/[name].facade.ts
│       └── services/[name].service.ts
└── feature-[name]/
    └── src/lib/
        ├── pages/[name]-page/
        ├── components/
        └── [name].routes.ts
```

## Tarefa
1. Execute comandos de geração
2. Crie interfaces no domain
3. Implemente facade com signals
4. Crie componentes standalone
5. Configure rotas lazy-loaded
6. Escreva testes (cobertura > 80%)
7. Adicione exports em index.ts

## API Contracts (se backend)

```yaml
endpoints:
  - method: GET
    path: "/api/v1/[resource]"
    response: "[Resource][]"
    
  - method: POST
    path: "/api/v1/[resource]"
    body: "Create[Resource]Dto"
    response: "[Resource]"
```
```

---

## 🧪 Template 5: Adicionar Testes

**Quando usar**: Código existente precisa de testes

```markdown
Preciso adicionar testes a código existente.

## Contexto
- Siga `.agent/System/angular_unit_testing_guide.md` (OBRIGATÓRIO)
- Siga `.agent/System/angular_full.md` para entender o código

## Código a Testar
- **Arquivo**: [CAMINHO_ARQUIVO]
- **Tipo**: [Componente | Facade | Service]
- **Cobertura Atual**: [%] (execute `nx test [project] --coverage`)
- **Meta**: > 80%

## Tarefa
1. Analise o código
2. Identifique métodos/comportamentos públicos
3. Verifique testes existentes
4. Escreva testes faltantes

## Requisitos de Teste (CRÍTICO)

```typescript
// ✅ FAÇA (obrigatório)
describe('MyComponent', () => {
  let mockFacade: Partial<MyFacade>;
  
  beforeEach(() => {
    // Mock TODAS as dependências
    mockFacade = {
      items: signal([]),
      loading: signal(false),
      loadItems: jest.fn(),
    };
    
    TestBed.configureTestingModule({
      imports: [MyComponent],
      providers: [
        { provide: MyFacade, useValue: mockFacade }
      ],
      schemas: [NO_ERRORS_SCHEMA]  // Para componentes PrimeNG
    });
  });
  
  it('should render items', () => {
    const fixture = TestBed.createComponent(MyComponent);
    (mockFacade.items as any).set([{ id: '1', name: 'Test' }]);
    fixture.detectChanges();
    
    // Use data-testid
    const element = fixture.debugElement.query(
      By.css('[data-testid="item-list"]')
    );
    expect(element).toBeTruthy();
  });
  
  it('should handle click', () => {
    const fixture = TestBed.createComponent(MyComponent);
    const button = fixture.debugElement.query(
      By.css('[data-testid="submit-btn"]')
    );
    
    // Use triggerEventHandler
    button.triggerEventHandler('click', null);
    
    expect(mockFacade.loadItems).toHaveBeenCalled();
  });
});

// ❌ NUNCA (proibido)
fixture.componentInstance.privateMethod();  // Não acesse internos
element.nativeElement.querySelector();       // Use debugElement.query
component.ngOnInit();                        // Não chame lifecycle
```

## Forneça
1. Lista de cenários de teste necessários
2. Arquivo de teste completo
3. Interpretação da cobertura
```

---

## 🔄 Template 6: Refatorar para Padrões Atuais

**Quando usar**: Código funciona mas não segue padrões

```markdown
Preciso refatorar código para seguir padrões do projeto.

## Contexto
- Leia `.agent/README.md` para padrões críticos
- Siga `.agent/System/angular_full.md`
- Siga `.agent/Agents/typescript_clean_code.md`

## Código a Refatorar
- **Arquivo**: [CAMINHO_ARQUIVO]
- **Problemas**:
  [ ] Usa NgModules (deve ser standalone)
  [ ] Usa @Input/@Output (deve usar input()/output())
  [ ] Usa BehaviorSubject (deve usar signals)
  [ ] Lógica no componente (deve usar facade)
  [ ] Usa *ngIf/*ngFor (deve usar @if/@for)
  [ ] Funções > 5 statements
  [ ] Funções > 3 parâmetros

## Tarefa
1. Analise código atual
2. Crie plano de refatoração
3. Mostre antes/depois
4. Mantenha testes passando
5. Zero breaking changes

## Transformações Necessárias

```typescript
// ANTES ❌
@Component({
  selector: 'app-old',
  templateUrl: './old.component.html'
})
export class OldComponent implements OnInit {
  @Input() userId: string;
  @Output() userSelected = new EventEmitter<User>();
  
  users$ = new BehaviorSubject<User[]>([]);
  loading$ = new BehaviorSubject<boolean>(false);
  
  constructor(private userService: UserService) {}
  
  ngOnInit() {
    this.loadUsers();
  }
  
  loadUsers() {
    this.loading$.next(true);
    this.userService.getUsers().subscribe(users => {
      this.users$.next(users);
      this.loading$.next(false);
    });
  }
}

// DEPOIS ✅
@Component({
  selector: 'app-new',
  standalone: true,
  imports: [CommonModule, TableModule],
  template: `
    @if (loading()) {
      <p-progressSpinner />
    } @else {
      @for (user of users(); track user.id) {
        <div (click)="selectUser(user)">{{ user.name }}</div>
      }
    }
  `
})
export class NewComponent {
  // Inputs/Outputs funcionais
  userId = input.required<string>();
  userSelected = output<User>();
  
  // Inject ao invés de constructor
  private readonly facade = inject(UsersFacade);
  
  // Signals do facade (não cria próprios)
  readonly users = this.facade.users;
  readonly loading = this.facade.loading;
  
  // Max 5 statements
  selectUser(user: User): void {
    this.userSelected.emit(user);
  }
}
```
```

---

## 🌙 Template 7: Implementar Dark Mode

**Quando usar**: Adicionar dark mode a componente existente

```markdown
Preciso adicionar suporte a dark mode.

## Contexto
- Siga `.agent/System/dark_mode_reference.md`
- Siga `.agent/System/primeng_best_practices.md`

## Componente
- **Arquivo**: [CAMINHO_DO_ARQUIVO]
- **Elementos**: [LISTE_ELEMENTOS_QUE_PRECISAM_DARK_MODE]

## Tarefa
Aplique classes de dark mode seguindo este padrão:

```html
<!-- Backgrounds -->
<div class="bg-surface-0 dark:bg-surface-900">        <!-- Fundo principal -->
<div class="bg-surface-50 dark:bg-surface-800">       <!-- Card/Container -->
<div class="bg-surface-100 dark:bg-surface-700">      <!-- Nested container -->

<!-- Textos -->
<h1 class="text-surface-900 dark:text-surface-0">     <!-- Título -->
<p class="text-surface-700 dark:text-surface-200">    <!-- Parágrafo -->
<span class="text-surface-500 dark:text-surface-400"> <!-- Secundário -->

<!-- Bordas -->
<div class="border-surface-200 dark:border-surface-700">

<!-- Hover states -->
<div class="hover:bg-surface-100 dark:hover:bg-surface-700">

<!-- Transição suave -->
<div class="transition-colors duration-150">
```

## Regras (CRÍTICO)
- ✅ USE cores surface do PrimeNG (surface-0 a surface-950)
- ✅ SEMPRE adicione prefixo dark:
- ✅ Adicione transition-colors para transições suaves
- ❌ NUNCA use gray-*, slate-* do Tailwind
- ❌ NUNCA use cores hardcoded (#ffffff, rgb())
- ❌ NUNCA modifique componentes PrimeNG (já têm dark mode)
```

---

## 📚 Template 8: Code Review

**Quando usar**: Revisar código antes de PR

```markdown
Por favor revise este código.

## Contexto
- Siga `.agent/README.md` para padrões críticos
- Siga `.agent/Agents/typescript_clean_code.md`
- Siga `.agent/System/nx_architecture_rules.md`

## Código
- **Arquivos**: [ARQUIVO_1], [ARQUIVO_2]
- **Tipo**: [Bug Fix | Feature | Refactor]
- **Descrição**: [O_QUE_MUDOU]

## Checklist de Revisão

### TypeScript
- [ ] Funções ≤ 5 statements
- [ ] Funções ≤ 3 parâmetros
- [ ] Nomes auto-documentados
- [ ] Sem comentários óbvios

### Angular
- [ ] Standalone components (sem NgModules)
- [ ] Signals (sem BehaviorSubject)
- [ ] input()/output() (sem decoradores)
- [ ] @if/@for (sem *ngIf/*ngFor)
- [ ] inject() (sem constructor injection)

### PrimeNG
- [ ] p-button, p-select (componentes)
- [ ] #templateName (não pTemplate)

### Arquitetura
- [ ] Facade pattern para lógica
- [ ] Dependências entre libs corretas
- [ ] Exports em index.ts

### Testes
- [ ] Todas dependências mockadas
- [ ] Schemas configurados
- [ ] data-testid para queries
- [ ] Cobertura > 80%

## Forneça
1. Relatório pass/fail por item
2. Problemas encontrados
3. Sugestões de melhoria
```

---

## 🎨 Template 9: Design Handoff (para UX)

**Quando usar**: UX criando especificacao e PRD para handoff ao dev

```markdown
Preciso criar uma PRD com especificacao completa para handoff ao time de desenvolvimento.

## Contexto do Projeto
- Siga `.agent/SOPs/design_to_dev_workflow.md` para o fluxo
- Use `.agent/Tasks/TEMPLATE_design_prd.md` como base da PRD
- Siga `.agent/System/primeng_best_practices.md` para componentes
- Siga `.agent/System/dark_mode_reference.md` para cores

## Feature
- **Nome**: [NOME_DA_FEATURE]
- **Scope**: [SCOPE] (verificar scopes existentes em libs/)
- **Descricao**: [O_QUE_A_TELA_FAZ]
- **Figma**: [LINK_FIGMA]

## Telas/Componentes
1. [TELA_1]: [DESCRICAO] - [COMPONENTES: tabela, formulario, cards]
2. [TELA_2]: [DESCRICAO] - [COMPONENTES]

## Dados
- **Campos principais**: [CAMPO_1, CAMPO_2, CAMPO_3]
- **Tipos**: [STRING, NUMBER, DATE, ENUM]
- **Relacoes**: [ENTIDADE_RELACIONADA]
- **Acoes do usuario**: [LISTAR, FILTRAR, CRIAR, EDITAR, EXCLUIR]
- **Estados**: [LOADING, EMPTY, ERROR, SUCCESS]

## Metricas (Datadog)
- [EVENTO_1]: [QUANDO_DISPARA]
- [EVENTO_2]: [QUANDO_DISPARA]

## Tarefa
1. Analise o scope e mapeie libs existentes em libs/[SCOPE]/
2. Identifique quais libs precisam ser criadas (domain, data-access, feature)
3. Documente a especificacao visual completa (componentes PrimeNG, estados, responsividade)
4. Mapeie dados necessarios (campos, tipos, relacoes)
5. Identifique dependencias entre libs
6. Gere PRD usando template de design
7. Inclua checklist de implementacao ordenado por prioridade

## Especificacao Visual
- Componentes PrimeNG necessarios (p-button, p-table, p-select) com configuracoes
- Estados visuais para cada tela (loading, empty, error, success)
- Layout responsivo (mobile, tablet, desktop)
- Dark mode com surface colors
- Comportamentos de interacao
- data-testid em elementos interativos
```

---

## ⚡ Snippets Rápidos

### Snippet: Contexto Básico
```markdown
## Contexto
- Leia `.agent/README.md` para padrões críticos
- Siga `.agent/System/angular_full.md` para Angular
- Siga `.agent/System/angular_unit_testing_guide.md` para testes
```

### Snippet: Requisitos Angular
```markdown
## Requisitos Angular
- ✅ Max 5 statements por função
- ✅ Standalone components (sem NgModules)
- ✅ Signals (sem BehaviorSubject)
- ✅ input()/output() (sem decoradores)
- ✅ @if/@for (sem *ngIf/*ngFor)
- ✅ inject() (sem constructor injection)
- ✅ PrimeNG components (p-button, p-select)
- ✅ Surface colors para dark mode
```

### Snippet: Requisitos de Testes
```markdown
## Requisitos de Teste
- ✅ Mock TODAS as dependências
- ✅ Use schemas: [NO_ERRORS_SCHEMA]
- ✅ Use data-testid para queries DOM
- ✅ Use debugElement.query(By.css())
- ✅ Use triggerEventHandler() para eventos
- ❌ NUNCA acesse componentInstance internos
- ❌ NUNCA use querySelector()
- ❌ NUNCA chame lifecycle manualmente
```

### Snippet: Comandos Nx
```bash
# Gerar libs
nx g @nx/js:lib domain --directory=[scope] --tags=type:domain,scope:[scope]
nx g @nx/angular:lib data-access --directory=[scope] --standalone --tags=type:data-access,scope:[scope]
nx g @nx/angular:lib feature-[name] --directory=[scope] --standalone --tags=type:feature,scope:[scope]

# Verificar
nx affected:lint --base=main
nx affected:test --base=main
nx affected:build --base=main

# Servir
npm start  # web + api
nx serve web
nx serve api
```

---

## 💡 Boas Práticas

### ✅ FAÇA
- Seja específico com caminhos de arquivo
- Inclua contexto (referências `.agent/`)
- Defina requisitos claros
- Peça código antes/depois
- Peça testes junto com implementação
- Use execução paralela para bugs complexos

### ❌ NÃO FAÇA
- Seja vago ("conserte isso")
- Pule contexto do projeto
- Esqueça requisitos de teste
- Assuma que IA conhece a arquitetura
- Peça múltiplas coisas não relacionadas

---

**Última atualização**: 2026-01-14
**Versão**: 2.0.0
