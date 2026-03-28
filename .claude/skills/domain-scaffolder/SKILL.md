---
name: domain-scaffolder
description: |
  Full Domain Structure Generator - Creates complete vertical slices: domain + data-access + data-source + feature.
  Generates all boilerplate with correct tags, paths, barrel exports, and test stubs.
  TRIGGERS: scaffold domain, create domain, new entity, new domain, scaffold, criar dominio, nova entidade, vertical slice
---

# @domain-scaffolder - Full Domain Structure Generator

Creates a complete domain vertical slice with all libraries, boilerplate, tags, and path aliases.

## Required Reading

- `.agent/System/architecture-knowledge/11-MONOREPO-ARCHITECTURE.md`
- `.agent/System/architecture-knowledge/02-DOMAIN-DRIVEN-DESIGN.md`
- `.agent/System/architecture-knowledge/04-PORTS-AND-ADAPTERS.md`
- `.agent/System/architecture-knowledge/10-MODULE-BOUNDARIES.md`
- `.agent/System/libs_architecture_pattern.md`
- `.agent/System/nx_architecture_rules.md`

## Invocation Pattern

```
@domain-scaffolder
  entity: [entity-name]  (e.g., payment, order, notification)
  scope: [scope-name]    (e.g., admin, public, shared - defaults to entity name)
  layers: [all | frontend | backend]
  features: [feature-names, comma separated]
```

## Generated Structure

### Full (layers: all)

```
libs/[entity]/
├── domain/                          # type:domain, scope:[entity]
│   ├── project.json
│   ├── tsconfig.json
│   ├── src/
│   │   ├── index.ts                 # Barrel exports
│   │   └── lib/
│   │       ├── dtos/
│   │       │   ├── [entity].dto.ts
│   │       │   ├── create-[entity].dto.ts
│   │       │   └── update-[entity].dto.ts
│   │       ├── interfaces/
│   │       │   ├── [entity].interface.ts
│   │       │   └── [entity]-repository.interface.ts
│   │       └── enums/
│   │           └── [entity]-status.enum.ts
│   └── jest.config.ts
│
├── data-access/                     # type:data-access, scope:[entity]
│   ├── project.json
│   ├── tsconfig.json
│   ├── src/
│   │   ├── index.ts
│   │   └── lib/
│   │       ├── application/
│   │       │   └── [entity].facade.ts
│   │       └── infrastructure/
│   │           └── [entity].repository.ts
│   └── jest.config.ts
│
├── data-source/                     # type:data-source, scope:[entity]
│   ├── project.json
│   ├── tsconfig.json
│   ├── src/
│   │   ├── index.ts
│   │   └── lib/
│   │       ├── controllers/
│   │       │   └── [entity].controller.ts
│   │       ├── services/
│   │       │   └── [entity].service.ts
│   │       ├── entities/
│   │       │   └── [entity].entity.ts
│   │       └── [entity].module.ts
│   └── jest.config.ts
│
└── feature-[name]/                  # type:feature, scope:[entity]
    ├── project.json
    ├── tsconfig.json
    ├── src/
    │   ├── index.ts
    │   └── lib/
    │       ├── [name].component.ts
    │       ├── [name].component.html
    │       ├── [name].component.spec.ts
    │       └── routes.ts
    └── jest.config.ts
```

## Generation Steps

### 1. Validate Input

```bash
# Check entity name is valid (kebab-case, no special chars)
# Check scope doesn't already exist
ls libs/[entity]/ 2>/dev/null && echo "Scope already exists!"
```

### 2. Generate Domain Library

```bash
nx g @nx/js:library \
  --directory=libs/[entity]/domain \
  --bundler=none \
  --linter=eslint \
  --name=domain \
  --unitTestRunner=jest \
  --minimal=true \
  --tags="type:domain,scope:[entity]"
```

**Create files:**

```typescript
// dtos/[entity].dto.ts
export interface [Entity]Dto {
  id: string;
  // TODO: Add entity fields
  createdAt: Date;
  updatedAt: Date;
}

// dtos/create-[entity].dto.ts
import { [Entity]Dto } from './[entity].dto';
export type Create[Entity]Dto = Omit<[Entity]Dto, 'id' | 'createdAt' | 'updatedAt'>;

// dtos/update-[entity].dto.ts
import { Create[Entity]Dto } from './create-[entity].dto';
export type Update[Entity]Dto = Partial<Create[Entity]Dto>;

// interfaces/[entity].interface.ts
import { [Entity]Dto } from '../dtos/[entity].dto';
export type [Entity] = [Entity]Dto;

// interfaces/[entity]-repository.interface.ts
import { [Entity]Dto } from '../dtos/[entity].dto';
import { Create[Entity]Dto } from '../dtos/create-[entity].dto';
import { Update[Entity]Dto } from '../dtos/update-[entity].dto';

export abstract class I[Entity]Repository {
  abstract findAll(): Promise<[Entity]Dto[]>;
  abstract findById(id: string): Promise<[Entity]Dto | null>;
  abstract create(dto: Create[Entity]Dto): Promise<[Entity]Dto>;
  abstract update(id: string, dto: Update[Entity]Dto): Promise<[Entity]Dto>;
  abstract delete(id: string): Promise<void>;
}

// enums/[entity]-status.enum.ts
export enum [Entity]Status {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
}
```

### 3. Generate Data-Access Library

```bash
nx g @nx/js:library \
  --directory=libs/[entity]/data-access \
  --bundler=none \
  --linter=eslint \
  --name=data-access \
  --unitTestRunner=jest \
  --minimal=true \
  --tags="type:data-access,scope:[entity]"
```

**Create files:**

```typescript
// application/[entity].facade.ts
import { Injectable, inject, signal, computed } from '@angular/core';

import { [Entity]Dto } from '@project/[entity]/domain/dtos/[entity].dto';
import { [Entity]Repository } from '../infrastructure/[entity].repository';

@Injectable({ providedIn: 'root' })
export class [Entity]Facade {
  private readonly repository = inject([Entity]Repository);

  private readonly _items = signal<[Entity]Dto[]>([]);
  private readonly _loading = signal(false);
  private readonly _selected = signal<[Entity]Dto | null>(null);

  readonly items = this._items.asReadonly();
  readonly loading = this._loading.asReadonly();
  readonly selected = this._selected.asReadonly();
  readonly isEmpty = computed(() => this._items().length === 0);

  async loadAll(): Promise<void> {
    this._loading.set(true);
    const items = await this.repository.findAll();
    this._items.set(items);
    this._loading.set(false);
  }

  async select(id: string): Promise<void> {
    const item = await this.repository.findById(id);
    this._selected.set(item);
  }
}

// infrastructure/[entity].repository.ts
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';

import { [Entity]Dto } from '@project/[entity]/domain/dtos/[entity].dto';
import { Create[Entity]Dto } from '@project/[entity]/domain/dtos/create-[entity].dto';
import { Update[Entity]Dto } from '@project/[entity]/domain/dtos/update-[entity].dto';

@Injectable({ providedIn: 'root' })
export class [Entity]Repository {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = '/api/[entity-plural]';

  async findAll(): Promise<[Entity]Dto[]> {
    return firstValueFrom(this.http.get<[Entity]Dto[]>(this.baseUrl));
  }

  async findById(id: string): Promise<[Entity]Dto | null> {
    return firstValueFrom(this.http.get<[Entity]Dto>(`${this.baseUrl}/${id}`));
  }

  async create(dto: Create[Entity]Dto): Promise<[Entity]Dto> {
    return firstValueFrom(this.http.post<[Entity]Dto>(this.baseUrl, dto));
  }

  async update(id: string, dto: Update[Entity]Dto): Promise<[Entity]Dto> {
    return firstValueFrom(this.http.patch<[Entity]Dto>(`${this.baseUrl}/${id}`, dto));
  }

  async delete(id: string): Promise<void> {
    return firstValueFrom(this.http.delete<void>(`${this.baseUrl}/${id}`));
  }
}
```

### 4. Generate Data-Source Library (Backend)

```bash
nx g @nx/js:library \
  --directory=libs/[entity]/data-source \
  --bundler=none \
  --linter=eslint \
  --name=data-source \
  --unitTestRunner=jest \
  --minimal=true \
  --tags="type:data-source,scope:[entity]"
```

### 5. Generate Feature Library (if requested)

```bash
nx g @nx/angular:library feature-[name] \
  --directory=libs/[entity] \
  --standalone \
  --tags="type:feature,scope:[entity]" \
  --style=scss
```

### 6. Update tsconfig.base.json

Add path aliases:
```json
{
  "@project/[entity]/domain": ["libs/[entity]/domain/src/index.ts"],
  "@project/[entity]/domain/*": ["libs/[entity]/domain/src/lib/*"],
  "@project/[entity]/data-access": ["libs/[entity]/data-access/src/index.ts"],
  "@project/[entity]/data-access/*": ["libs/[entity]/data-access/src/lib/*"],
  "@project/[entity]/data-source": ["libs/[entity]/data-source/src/index.ts"],
  "@project/[entity]/data-source/*": ["libs/[entity]/data-source/src/lib/*"],
  "@project/[entity]/feature-[name]": ["libs/[entity]/feature-[name]/src/index.ts"]
}
```

### 7. Update Barrel Exports (index.ts)

Each lib's `src/index.ts` must export public API only.

### 8. Validation

```bash
nx lint [entity]-domain
nx lint [entity]-data-access
nx lint [entity]-data-source
nx graph --focus=[entity]-domain
```

## Output

```markdown
## Domain Scaffold Complete: [entity]

### Libraries Created
| Library | Tags | Path Alias |
|---------|------|------------|
| [entity]-domain | type:domain, scope:[entity] | @project/[entity]/domain |
| [entity]-data-access | type:data-access, scope:[entity] | @project/[entity]/data-access |
| [entity]-data-source | type:data-source, scope:[entity] | @project/[entity]/data-source |
| [entity]-feature-[name] | type:feature, scope:[entity] | @project/[entity]/feature-[name] |

### Files Created
- [list of all generated files]

### Next Steps
1. Define entity fields in `[entity].dto.ts`
2. Add business logic to facade
3. Implement backend service/controller
4. Create feature component UI
5. Add routes to shell
```
