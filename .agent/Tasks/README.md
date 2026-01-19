# Tasks - Product Requirements Documents (PRDs)

This folder contains all Product Requirements Documents (PRDs) and implementation plans for the Guia Monorepo project.

---

## 🤖 AI Agent Context

> **IMPORTANT**: This folder is designed to provide maximum context for AI agents working on this project. Each PRD contains structured metadata that allows agents to understand scope, dependencies, and implementation patterns without needing to search the entire codebase.

### Quick Reference for AI Agents

```yaml
project_context:
  name: "@base/source"
  type: Nx Monorepo
  frontend: Angular 21+ (Standalone Components, Signals)
  backend: NestJS 11+
  ui_library: PrimeNG 21+
  styling: Tailwind CSS 4+
  testing: Jest 30+
  package_manager: bun

key_docs:
  - ".agent/System/angular_full.md"           # Angular patterns
  - ".agent/System/nx_architecture_rules.md"  # Lib dependencies
  - ".agent/System/libs_architecture_pattern.md" # Scope/Lib structure
  - ".agent/System/primeng_best_practices.md" # UI components
  - ".agent/System/dark_mode_reference.md"    # Theme system
```

---

## 📋 What are PRDs?

PRDs (Product Requirements Documents) are documents that describe:
- **What** will be implemented (functionality)
- **Why** it will be implemented (business justification)
- **How** it will be implemented (technical architecture)
- **When** it will be implemented (timeline)
- **Who** are the stakeholders

## 🎯 When to Create a PRD?

Create a PRD when:
- ✅ Significant new feature (more than 1 day of development)
- ✅ Important architectural change
- ✅ New integration with external systems
- ✅ Feature that impacts multiple libs/apps
- ✅ Feature requested by stakeholders
- ✅ New scope or domain creation

Don't create PRD for:
- ❌ Simple bug fixes (use lightweight issue template)
- ❌ Internal code refactoring (unless architectural)
- ❌ Minor style/UI changes
- ❌ Dependency updates

---

## 🔄 Automatic PRD Generation (Plan Mode Integration)

PRDs can be automatically generated from Claude Code's Plan Mode workflow.

### How It Works

```
User Request → EnterPlanMode → Write Plan → ExitPlanMode
                                                  ↓
                                      ┌──────────────────────┐
                                      │  Automatic Hooks:    │
                                      │  1. plan-review.sh   │
                                      │  2. plan-to-prd.sh   │ ← Generates PRD
                                      │  3. archive-plan.sh  │
                                      └──────────────────────┘
                                                  ↓
                              PRD created in .agent/Tasks/PRD-YYYY-MM-###_name.md
```

### Plan Structure for Best Results

When using Plan Mode, structure your plan for optimal PRD generation:

```markdown
# Feature: [Clear Feature Name]

## Scope
- Scope: [scope-name]
- Type: feature

## Implementation Plan
1. [Step 1]
2. [Step 2]

## Files to Create/Modify
- libs/[scope]/feature-[name]/src/...
- libs/[scope]/data-access/src/...

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
```

### Generated PRD Contents

The auto-generated PRD includes:
- **AI Context Block** - YAML metadata for AI agents
- **Original Plan** - Preserved in collapsible section
- **Definition of Done** - Standard checklist from project rules
- **Test Plan Template** - Coverage targets

### After Generation

1. Review the generated PRD in `.agent/Tasks/`
2. Fill in missing details (API contracts, specific files)
3. Update `nx_impact` section with actual libs
4. Begin implementation following the PRD

> **See also**: `.agent/Plans/README.md` for full workflow documentation

---

## 📝 PRD Template v2.0 (AI-Optimized)

```markdown
# [Feature Name] - PRD

**ID**: PRD-YYYY-MM-###
**Status**: 🔜 Planned | 🚧 In Development | ✅ Completed | ❌ Cancelled
**Priority**: P0 (Critical) | P1 (High) | P2 (Medium) | P3 (Low)
**Created**: YYYY-MM-DD
**Updated**: YYYY-MM-DD
**Owner**: @github-username

---

## 🤖 AI Context Block

<!-- 
  STRUCTURED METADATA FOR AI AGENTS
  This YAML block provides machine-readable context for AI assistants.
  DO NOT REMOVE - Update this block as implementation progresses.
-->

​```yaml
# ============================================
# FEATURE IDENTIFICATION
# ============================================
feature:
  name: "feature-name"
  type: feature | bugfix | refactor | migration | integration
  scope: frontend | backend | fullstack | mobile
  complexity: S | M | L | XL
  estimated_hours: 8

# ============================================
# NX MONOREPO IMPACT ANALYSIS
# ============================================
nx_impact:
  # Existing apps that will be modified
  apps_affected:
    - name: "web"
      path: "apps/web"
      changes:
        - type: routes
          files: ["src/app/app.routes.ts"]
        - type: config
          files: ["src/app/app.config.ts"]
    - name: "api"
      path: "apps/api"
      changes:
        - type: module
          files: ["src/app/app.module.ts"]

  # Existing libs that will be modified
  libs_affected:
    - path: "libs/shared/models"
      type: domain
      changes: ["Add new interface"]
    - path: "libs/shared/utils"
      type: util
      changes: ["Add helper function"]

  # New libs to be created
  libs_to_create:
    - path: "libs/[scope]/feature-[name]"
      type: feature
      generator: "@nx/angular:lib"
      options:
        directory: "[scope]"
        tags: "type:feature,scope:[scope]"
        standalone: true
        flat: false
      tags: ["type:feature", "scope:[scope]"]
      
    - path: "libs/[scope]/data-access"
      type: data-access
      generator: "@nx/angular:lib"
      options:
        directory: "[scope]"
        tags: "type:data-access,scope:[scope]"
      tags: ["type:data-access", "scope:[scope]"]
      
    - path: "libs/[scope]/domain"
      type: domain
      generator: "@nx/js:lib"
      options:
        directory: "[scope]"
        tags: "type:domain,scope:[scope]"
      tags: ["type:domain", "scope:[scope]"]

# ============================================
# DEPENDENCY GRAPH (ARCHITECTURAL)
# ============================================
# Reference: .agent/System/nx_architecture_rules.md
dependency_graph:
  # Format: "from" can only import "to"
  - from: "apps/web"
    to:
      - "[scope]/feature-[name]"
      - "shared/ui"
  
  - from: "[scope]/feature-[name]"
    allowed:
      - "[scope]/data-access"
      - "[scope]/domain"
      - "shared/ui"
      - "shared/utils"
    forbidden:
      - "*/feature-*"  # NO cross-feature imports
      - "*/api"        # NO direct API access
      
  - from: "[scope]/data-access"
    allowed:
      - "[scope]/domain"
      - "[scope]/data-source"
      - "shared/utils"
    forbidden:
      - "*/feature-*"
      - "*/ui-*"

# ============================================
# TSCONFIG PATH ALIASES TO ADD
# ============================================
tsconfig_paths:
  - alias: "@[scope]/feature-[name]"
    path: "libs/[scope]/feature-[name]/src/index.ts"
  - alias: "@[scope]/data-access"
    path: "libs/[scope]/data-access/src/index.ts"
  - alias: "@[scope]/domain"
    path: "libs/[scope]/domain/src/index.ts"

# ============================================
# NX COMMANDS TO EXECUTE
# ============================================
commands:
  # Step 1: Generate libraries
  generate:
    - cmd: "nx g @nx/angular:lib feature-[name] --directory=[scope] --standalone --tags=type:feature,scope:[scope]"
      description: "Create feature library"
    - cmd: "nx g @nx/angular:lib data-access --directory=[scope] --standalone --tags=type:data-access,scope:[scope]"
      description: "Create data-access library"
    - cmd: "nx g @nx/js:lib domain --directory=[scope] --tags=type:domain,scope:[scope]"
      description: "Create domain library"
  
  # Step 2: Generate components/services
  scaffold:
    - cmd: "nx g @nx/angular:component [name]-page --project=[scope]-feature-[name] --standalone --path=libs/[scope]/feature-[name]/src/lib/pages"
      description: "Create main page component"
    - cmd: "nx g @nx/angular:service [name] --project=[scope]-data-access --path=libs/[scope]/data-access/src/lib/services"
      description: "Create service"
  
  # Step 3: Build & Test
  verify:
    - cmd: "nx affected:lint --base=main"
      description: "Lint affected projects"
    - cmd: "nx affected:test --base=main"
      description: "Test affected projects"
    - cmd: "nx affected:build --base=main"
      description: "Build affected projects"
  
  # Step 4: Run locally
  serve:
    - cmd: "nx serve web"
      description: "Start frontend"
    - cmd: "nx serve api"
      description: "Start backend"

# ============================================
# API CONTRACTS (IF BACKEND INVOLVED)
# ============================================
api_contracts:
  base_path: "/api/v1/[resource]"
  endpoints:
    - method: GET
      path: "/api/v1/[resource]"
      description: "List all resources"
      request:
        query_params:
          - name: page
            type: number
            required: false
          - name: limit
            type: number
            required: false
      response:
        type: "[Resource][]"
        status: 200
        
    - method: GET
      path: "/api/v1/[resource]/:id"
      description: "Get single resource"
      request:
        path_params:
          - name: id
            type: string
            required: true
      response:
        type: "[Resource]"
        status: 200
        
    - method: POST
      path: "/api/v1/[resource]"
      description: "Create new resource"
      request:
        body: "Create[Resource]Dto"
      response:
        type: "[Resource]"
        status: 201
        
    - method: PATCH
      path: "/api/v1/[resource]/:id"
      description: "Update resource"
      request:
        path_params:
          - name: id
            type: string
            required: true
        body: "Update[Resource]Dto"
      response:
        type: "[Resource]"
        status: 200
        
    - method: DELETE
      path: "/api/v1/[resource]/:id"
      description: "Delete resource"
      response:
        status: 204

# ============================================
# CODE PATTERNS TO FOLLOW
# ============================================
code_patterns:
  angular:
    components: standalone  # ALWAYS standalone
    control_flow: "@if/@for"  # NOT *ngIf/*ngFor
    signals: true  # Use signals for state
    inputs: "input()"  # NOT @Input()
    outputs: "output()"  # NOT @Output()
    inject: "inject()"  # NOT constructor injection
    
  primeng:
    use_components: true  # p-button, p-select, p-inputtext
    avoid_directives: true  # NOT pButton, pDropdown
    templates: "#name"  # NOT pTemplate="name"
    
  styling:
    framework: "tailwind"
    theme: "primeng-surface"  # surface-0 to surface-950
    dark_mode: "dark: prefix"
    responsive: "mobile-first"  # sm: md: lg: xl:
    
  testing:
    framework: "jest"
    selectors: "data-testid"
    coverage_target: 80
    mock_strategy: "always-mock-dependencies"

# ============================================
# FILES TO CREATE (EXPLICIT LIST)
# ============================================
files_to_create:
  # Domain layer
  - path: "libs/[scope]/domain/src/lib/[name].interface.ts"
    type: interface
    exports_to: "libs/[scope]/domain/src/index.ts"
    
  - path: "libs/[scope]/domain/src/lib/[name].enum.ts"
    type: enum
    exports_to: "libs/[scope]/domain/src/index.ts"
    
  # Data-access layer
  - path: "libs/[scope]/data-access/src/lib/services/[name].service.ts"
    type: service
    exports_to: "libs/[scope]/data-access/src/index.ts"
    
  - path: "libs/[scope]/data-access/src/lib/facades/[name].facade.ts"
    type: facade
    exports_to: "libs/[scope]/data-access/src/index.ts"
    
  # Feature layer
  - path: "libs/[scope]/feature-[name]/src/lib/pages/[name]-page/[name]-page.component.ts"
    type: component
    exports_to: "libs/[scope]/feature-[name]/src/index.ts"
    
  - path: "libs/[scope]/feature-[name]/src/lib/[name].routes.ts"
    type: routes
    exports_to: "libs/[scope]/feature-[name]/src/index.ts"

# ============================================
# IMPORTS REQUIRED
# ============================================
imports:
  angular:
    - from: "@angular/core"
      items: [Component, inject, signal, computed, input, output]
    - from: "@angular/common"
      items: [CommonModule]
    - from: "@angular/router"
      items: [RouterModule, Routes]
    - from: "@angular/forms"
      items: [ReactiveFormsModule, FormsModule]
      
  primeng:
    - from: "primeng/button"
      items: [ButtonModule]
    - from: "primeng/inputtext"
      items: [InputTextModule]
    - from: "primeng/card"
      items: [CardModule]
    - from: "primeng/table"
      items: [TableModule]
      
  internal:
    - from: "@[scope]/domain"
      items: ["[Name]Interface", "[Name]Enum"]
    - from: "@[scope]/data-access"
      items: ["[Name]Facade", "[Name]Service"]
    - from: "@shared/utils"
      items: [SITE_URL]
​```

<!-- End AI Context Block -->

---

## 📌 Executive Summary

**One-liner**: [Single sentence describing what this feature does]

**Business Context**: 
[2-3 sentences explaining WHY this feature is needed NOW. What problem does it solve? What opportunity does it create?]

**Success Criteria**:
- [ ] Criterion 1 (measurable)
- [ ] Criterion 2 (measurable)
- [ ] Criterion 3 (measurable)

---

## 🎯 Problem Statement

### Current State
​```
[Describe the current behavior, limitation, or pain point]
- What happens today?
- Who is affected?
- What's the frequency of this problem?
​```

### Desired State
​```
[Describe the expected behavior after implementation]
- What should happen?
- How will users benefit?
- What metrics will improve?
​```

### Impact Assessment

| Dimension | If NOT Implemented | If Implemented |
|-----------|-------------------|----------------|
| User Experience | [negative impact] | [positive impact] |
| Business Value | [lost opportunity] | [gained value] |
| Technical Debt | [accumulation] | [reduction/neutral] |
| Team Velocity | [slowdown reason] | [improvement reason] |

---

## 👥 Stakeholders

| Role | Name | Responsibility |
|------|------|---------------|
| **Product Owner** | @name | Final approval, priority |
| **Tech Lead** | @name | Architecture decisions |
| **Developer(s)** | @name | Implementation |
| **UX/UI** | @name | Design specs (if applicable) |
| **QA** | @name | Test validation (if applicable) |

---

## 📐 Functional Requirements

### FR-01: [Requirement Name]

| Attribute | Value |
|-----------|-------|
| **Priority** | Must Have / Should Have / Nice to Have |
| **Complexity** | S / M / L / XL |
| **Scope** | [scope-name] |
| **Libs Affected** | `libs/[scope]/...` |

**User Story**:
> As a [user type], I want [action], so that [benefit].

**Acceptance Criteria** (Gherkin format):
​```gherkin
Feature: [Feature Name]

  Scenario: [Happy Path Scenario]
    Given [precondition]
    And [additional precondition]
    When [user action]
    Then [expected result]
    And [additional expected result]

  Scenario: [Edge Case Scenario]
    Given [edge case precondition]
    When [user action]
    Then [expected handling]

  Scenario: [Error Scenario]
    Given [error condition]
    When [user action]
    Then [error message displayed]
    And [system remains stable]
​```

**Technical Implementation Notes**:
​```typescript
// Interface signature (to be created in domain lib)
export interface [Name] {
  id: string;
  // ... properties
}

// Service method signature (to be created in data-access lib)
export class [Name]Service {
  // Max 5 instructions per method
  getData(): Signal<[Name][]>;
  createItem(dto: Create[Name]Dto): Observable<[Name]>;
}
​```

---

### FR-02: [Next Requirement]
[Repeat structure above]

---

## 🔧 Technical Architecture

### Nx Project Graph Impact

​```
┌─────────────────────────────────────────────────────────────────┐
│                         apps/web                                 │
│                            │                                     │
│           ┌────────────────┼────────────────┐                   │
│           ▼                ▼                ▼                   │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│   │   [scope]/   │  │   shared/    │  │   shared/    │         │
│   │ feature-[x]  │  │     ui       │  │    utils     │         │
│   └──────┬───────┘  └──────────────┘  └──────────────┘         │
│          │                                                       │
│          ▼                                                       │
│   ┌──────────────┐                                              │
│   │   [scope]/   │                                              │
│   │ data-access  │ ◄── Facade Pattern                          │
│   └──────┬───────┘                                              │
│          │                                                       │
│    ┌─────┼─────┐                                                │
│    ▼           ▼                                                │
│ ┌──────┐  ┌──────────┐                                         │
│ │domain│  │data-source│                                         │
│ └──────┘  └──────────┘                                          │
└─────────────────────────────────────────────────────────────────┘
​```

### File Structure (New Libs)

​```
libs/
└── [scope]/                          # ← NEW SCOPE (if applicable)
    ├── domain/                       # ← Domain lib (interfaces, enums)
    │   ├── src/
    │   │   ├── lib/
    │   │   │   ├── [name].interface.ts
    │   │   │   ├── [name].enum.ts
    │   │   │   └── [name].type.ts
    │   │   └── index.ts              # ← Public API exports
    │   ├── project.json
    │   └── tsconfig.json
    │
    ├── data-access/                  # ← Data-access lib (facades, services)
    │   ├── src/
    │   │   ├── lib/
    │   │   │   ├── facades/
    │   │   │   │   └── [name].facade.ts
    │   │   │   ├── services/
    │   │   │   │   └── [name].service.ts
    │   │   │   └── state/
    │   │   │       └── [name].store.ts  # ← Signals-based state
    │   │   └── index.ts
    │   ├── project.json
    │   └── tsconfig.json
    │
    └── feature-[name]/               # ← Feature lib (pages, components)
        ├── src/
        │   ├── lib/
        │   │   ├── pages/
        │   │   │   └── [name]-page/
        │   │   │       ├── [name]-page.component.ts
        │   │   │       ├── [name]-page.component.html
        │   │   │       ├── [name]-page.component.spec.ts
        │   │   │       └── [name]-page.component.css
        │   │   ├── components/        # ← Feature-specific components
        │   │   │   └── [name]-card/
        │   │   └── [name].routes.ts
        │   └── index.ts
        ├── project.json
        └── tsconfig.json
​```

### Code Examples (Following Project Patterns)

**1. Interface (Domain Layer)**:
​```typescript
// libs/[scope]/domain/src/lib/[name].interface.ts

/**
 * Represents a [Name] entity in the system.
 * @see API endpoint: GET /api/v1/[name]
 */
export interface [Name] {
  readonly id: string;
  readonly name: string;
  readonly createdAt: Date;
  readonly updatedAt: Date;
}

export interface Create[Name]Dto {
  name: string;
}

export interface Update[Name]Dto {
  name?: string;
}
​```

**2. Facade with Signals (Data-Access Layer)**:
​```typescript
// libs/[scope]/data-access/src/lib/facades/[name].facade.ts
import { Injectable, inject, signal, computed } from '@angular/core';
import { [Name] } from '@[scope]/domain';
import { [Name]Service } from '../services/[name].service';

@Injectable({ providedIn: 'root' })
export class [Name]Facade {
  private readonly service = inject([Name]Service);

  // Private mutable signals
  private readonly _items = signal<[Name][]>([]);
  private readonly _loading = signal(false);
  private readonly _error = signal<string | null>(null);

  // Public readonly signals (exposed to components)
  readonly items = this._items.asReadonly();
  readonly loading = this._loading.asReadonly();
  readonly error = this._error.asReadonly();

  // Computed signals
  readonly itemCount = computed(() => this._items().length);
  readonly hasItems = computed(() => this._items().length > 0);

  // Methods (max 5 instructions each per project rules)
  loadItems(): void {
    this._loading.set(true);
    this._error.set(null);
    this.service.getAll().subscribe({
      next: (items) => this._items.set(items),
      error: (err) => this._error.set(err.message),
      complete: () => this._loading.set(false),
    });
  }

  createItem(dto: Create[Name]Dto): void {
    this.service.create(dto).subscribe({
      next: (item) => this._items.update((items) => [...items, item]),
      error: (err) => this._error.set(err.message),
    });
  }
}
​```

**3. Standalone Component (Feature Layer)**:
​```typescript
// libs/[scope]/feature-[name]/src/lib/pages/[name]-page/[name]-page.component.ts
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { [Name]Facade } from '@[scope]/data-access';

// PrimeNG imports (using components, NOT directives)
import { ButtonModule } from 'primeng/button';
import { CardModule } from 'primeng/card';
import { TableModule } from 'primeng/table';

@Component({
  selector: 'app-[name]-page',
  standalone: true,
  imports: [
    CommonModule,
    ButtonModule,
    CardModule,
    TableModule,
  ],
  template: `
    <!-- Using @if/@for control flow (NOT *ngIf/*ngFor) -->
    @if (facade.loading()) {
      <div class="flex justify-center p-4">
        <i class="pi pi-spin pi-spinner text-2xl"></i>
      </div>
    } @else {
      @if (facade.hasItems()) {
        <p-table [value]="facade.items()" data-testid="[name]-table">
          <ng-template #header>
            <tr>
              <th>Name</th>
              <th>Actions</th>
            </tr>
          </ng-template>
          <ng-template #body let-item>
            <tr>
              <td>{{ item.name }}</td>
              <td>
                <p-button 
                  icon="pi pi-pencil" 
                  [rounded]="true" 
                  [text]="true"
                  data-testid="edit-[name]-{{ item.id }}"
                />
              </td>
            </tr>
          </ng-template>
        </p-table>
      } @else {
        <p-card data-testid="empty-state">
          <p class="text-surface-500 dark:text-surface-400">
            No items found.
          </p>
        </p-card>
      }
    }
  `,
  styles: [`
    :host {
      @apply block p-4;
    }
  `]
})
export class [Name]PageComponent {
  protected readonly facade = inject([Name]Facade);
}
​```

**4. Routes Configuration**:
​```typescript
// libs/[scope]/feature-[name]/src/lib/[name].routes.ts
import { Routes } from '@angular/router';

export const [NAME]_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () =>
      import('./pages/[name]-page/[name]-page.component').then(
        (m) => m.[Name]PageComponent
      ),
  },
];
​```

**5. Unit Test Example**:
​```typescript
// libs/[scope]/feature-[name]/src/lib/pages/[name]-page/[name]-page.component.spec.ts
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { [Name]PageComponent } from './[name]-page.component';
import { [Name]Facade } from '@[scope]/data-access';
import { signal } from '@angular/core';
import { NO_ERRORS_SCHEMA } from '@angular/core';

describe('[Name]PageComponent', () => {
  let component: [Name]PageComponent;
  let fixture: ComponentFixture<[Name]PageComponent>;
  let mockFacade: Partial<[Name]Facade>;

  beforeEach(async () => {
    // Mock all dependencies (project rule)
    mockFacade = {
      items: signal([]),
      loading: signal(false),
      error: signal(null),
      hasItems: signal(false),
      loadItems: jest.fn(),
    };

    await TestBed.configureTestingModule({
      imports: [[Name]PageComponent],
      providers: [
        { provide: [Name]Facade, useValue: mockFacade },
      ],
      schemas: [NO_ERRORS_SCHEMA], // Required for PrimeNG components
    }).compileComponents();

    fixture = TestBed.createComponent([Name]PageComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should show loading spinner when loading', () => {
    (mockFacade.loading as any).set(true);
    fixture.detectChanges();
    
    const spinner = fixture.nativeElement.querySelector('[data-testid="loading-spinner"]');
    expect(spinner).toBeTruthy();
  });

  it('should show empty state when no items', () => {
    (mockFacade.loading as any).set(false);
    (mockFacade.hasItems as any).set(false);
    fixture.detectChanges();
    
    const emptyState = fixture.nativeElement.querySelector('[data-testid="empty-state"]');
    expect(emptyState).toBeTruthy();
  });

  it('should render table when items exist', () => {
    (mockFacade.loading as any).set(false);
    (mockFacade.hasItems as any).set(true);
    (mockFacade.items as any).set([{ id: '1', name: 'Test' }]);
    fixture.detectChanges();
    
    const table = fixture.nativeElement.querySelector('[data-testid="[name]-table"]');
    expect(table).toBeTruthy();
  });
});
​```

---

## 🎨 Design/UX Specifications

### Wireframes/Mockups
[Links to Figma, screenshots, or embedded images]

### Responsive Breakpoints
| Breakpoint | Width | Layout Changes |
|------------|-------|----------------|
| **Mobile** (default) | < 640px | Single column, stacked elements |
| **sm:** | ≥ 640px | Two columns where applicable |
| **md:** | ≥ 768px | Side navigation visible |
| **lg:** | ≥ 1024px | Full desktop layout |
| **xl:** | ≥ 1280px | Maximum content width |

### Dark Mode Considerations
​```css
/* Use PrimeNG surface colors (NOT Tailwind gray-*) */
.container {
  @apply bg-surface-0 dark:bg-surface-950;
  @apply text-surface-900 dark:text-surface-0;
  @apply border-surface-200 dark:border-surface-700;
}
​```

### User Flow
​```
1. User navigates to /[route]
   ↓
2. App loads [Name]PageComponent (lazy loaded)
   ↓
3. Component calls facade.loadItems() on init
   ↓
4. Loading spinner shown while fetching
   ↓
5. Data displayed in table/list
   ↓
6. User can [action] → [result]
​```

---

## 🧪 Test Plan

### Unit Tests (Jest)

| Target | Test Cases | Priority | Coverage Target |
|--------|-----------|----------|-----------------|
| `[Name]Facade` | load, create, update, delete, error handling | Must | 90% |
| `[Name]Service` | HTTP calls, error mapping | Must | 85% |
| `[Name]PageComponent` | render states, user interactions | Must | 80% |
| `[Name]CardComponent` | input/output, display | Should | 75% |

**Test Commands**:
​```bash
# Run tests for affected projects only
nx affected:test --base=main

# Run specific lib tests with coverage
nx test [scope]-feature-[name] --coverage
nx test [scope]-data-access --coverage

# Run all tests in CI mode
nx run-many --target=test --configuration=ci
​```

### Manual Test Checklist
- [ ] Feature works on Chrome, Firefox, Safari
- [ ] Responsive layout correct on mobile/tablet/desktop
- [ ] Dark mode displays correctly
- [ ] Loading states appear and disappear correctly
- [ ] Error messages are user-friendly
- [ ] Keyboard navigation works
- [ ] Screen reader announces content properly

---

## 📅 Implementation Timeline

| Phase | Description | Estimated | Due Date | Status |
|-------|-------------|-----------|----------|--------|
| **1** | Setup libs, domain models | 2h | MM/DD | 🔜 |
| **2** | Data-access layer (facade, service) | 4h | MM/DD | 🔜 |
| **3** | Feature components | 4h | MM/DD | 🔜 |
| **4** | Routing integration | 1h | MM/DD | 🔜 |
| **5** | Unit tests (80%+ coverage) | 3h | MM/DD | 🔜 |
| **6** | Code review | 2h | MM/DD | 🔜 |
| **7** | Bug fixes & polish | 2h | MM/DD | 🔜 |
| **8** | Deploy to staging | 1h | MM/DD | 🔜 |
| **Total** | | **19h** | | |

---

## 🚧 Risks and Mitigations

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| API not ready | Medium | High | Create mock service, use JSON Server |
| Design changes during dev | Medium | Medium | Get sign-off before Phase 3 |
| Cross-feature dependency needed | Low | High | Escalate to Tech Lead, may need refactor |
| Performance issues with large data | Medium | Medium | Implement pagination early |
| Breaking existing functionality | Low | High | Run `nx affected:test` before every commit |

### Dependencies & Blockers
- [ ] **External**: API endpoint `/api/v1/[resource]` deployed
- [ ] **External**: UX designs finalized in Figma
- [ ] **Internal**: Shared UI component `X` needs update
- [ ] **Internal**: Database migration completed

---

## ✅ Definition of Done

### Code Quality
- [ ] All code follows `.agent/System/` guidelines
- [ ] Standalone components (NO NgModules)
- [ ] Signals used for state (NO BehaviorSubject in new code)
- [ ] `@if`/`@for` used (NO `*ngIf`/`*ngFor`)
- [ ] PrimeNG components used (NO directives like `pButton`)
- [ ] Tailwind CSS with surface colors for dark mode
- [ ] Methods have max 5 instructions

### Testing
- [ ] Unit test coverage > 80%
- [ ] All tests pass: `nx affected:test --base=main`
- [ ] No lint errors: `nx affected:lint --base=main`

### Documentation
- [ ] Public API exported in `index.ts`
- [ ] Complex functions have JSDoc comments
- [ ] PRD status updated to ✅ Completed
- [ ] `.agent/System/features_overview.md` updated (if applicable)

### Deployment
- [ ] Builds successfully: `nx affected:build --base=main`
- [ ] Deployed to staging environment
- [ ] Acceptance testing passed
- [ ] Deployed to production

---

## 📚 References

- **Design**: [Figma Link]
- **API Docs**: [Swagger/OpenAPI Link]
- **Related PRDs**: PRD-YYYY-MM-###
- **Tech Docs**: `.agent/System/[relevant-doc].md`

---

## 📝 Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | YYYY-MM-DD | @username | Initial draft |
| 1.0.1 | YYYY-MM-DD | @username | Added API contracts |
| 1.1.0 | YYYY-MM-DD | @username | Updated after technical review |
```

---

## 📂 Available PRDs

### 📚 Examples & Templates
- **PRD-2026-01-001_user_management.md** - **COMPLETE EXAMPLE** of a fullstack feature PRD with all sections filled. Use as primary reference for new PRDs.
- **PRD_CHECKLIST.md** - Quick validation checklist for AI agents to verify PRD completeness.
- **EXAMPLE_fix_process_form_validation_bug.md** - Example of bug fix PRD with detailed investigation.

### ✅ Completed
_(No PRDs completed yet)_

### 🚧 In Development
_(No PRDs in development)_

### 🔜 Planned (Backlog)
- **PRD-2026-01-001_user_management.md** - User management feature for admin panel

---

## 🔄 PRD Workflow

```
1. Identify Feature Need
   ↓
2. Create PRD using template above
   • Fill AI Context Block YAML completely
   • Define all libs to create/modify
   • List specific files to create
   ↓
3. Review with Tech Lead
   • Validate architecture decisions
   • Confirm lib boundaries
   ↓
4. Approval (status → 🚧 In Development)
   ↓
5. Implementation
   • Run generate commands from YAML
   • Follow code patterns in template
   • Update PRD as you progress
   ↓
6. Testing + Code Review
   • nx affected:test
   • nx affected:lint
   • Coverage > 80%
   ↓
7. Deploy to Staging
   ↓
8. Acceptance Testing
   ↓
9. Deploy to Production
   ↓
10. Update PRD Status (→ ✅ Completed)
    ↓
11. Update .agent/System/ docs if needed
```

---

## 📊 Statistics

- **Total PRDs**: 1
- **Completed**: 0
- **In Development**: 0
- **Planned**: 1
- **Cancelled**: 0

---

## 🤝 Contributing

1. Copy the PRD template above
2. Create new file: `PRD-YYYY-MM-###_feature_name.md`
3. Fill **ALL** sections (especially AI Context Block)
4. Commit: `docs: add PRD for [feature name]`
5. Update this README with link to new PRD
6. Request review from Tech Lead

---

## 🔑 Quick Commands Reference

```bash
# Generate new scope structure
nx g @nx/angular:lib data-access --directory=[scope] --standalone --tags=type:data-access,scope:[scope]
nx g @nx/angular:lib feature-[name] --directory=[scope] --standalone --tags=type:feature,scope:[scope]
nx g @nx/js:lib domain --directory=[scope] --tags=type:domain,scope:[scope]

# Generate components/services
nx g @nx/angular:component [name] --project=[scope]-feature-[name] --standalone
nx g @nx/angular:service [name] --project=[scope]-data-access

# Verify changes
nx affected:lint --base=main
nx affected:test --base=main
nx affected:build --base=main

# Serve applications
nx serve web
nx serve api
npm start  # Both simultaneously
```
