# Interface/DTO Architecture Guide

## Overview

This document describes the standard structure for organizing interfaces, DTOs, enums, and types in domain modules. Following this architecture ensures consistency, maintainability, and proper separation of concerns across the monorepo.

---

## 🚫 REGRA CRÍTICA — Não negociável

**DTOs com decorators de `class-validator` / `class-transformer` (`@Expose`, `@Type`, `@IsEmail`, `@IsEnum`, `@Transform`, `@ValidateBy`, etc.) são EXCLUSIVAMENTE backend.** O frontend (qualquer `data-access`, `feature-*`, `ui-*` ou `apps/web|mobile`) NUNCA importa um arquivo `*.dto.ts`.

**O que o frontend pode importar de `@<scope>/domain`:**
- ✅ `interfaces/*.interface.ts` — TypeScript puro, sem decorators
- ✅ `enums/*.enum.ts`
- ✅ `types/*.types.ts`
- ✅ `schemas/*.schema.ts` (Zod — seguro no FE)
- ❌ `dtos/*.dto.ts` — **PROIBIDO no FE**
- ❌ `dtos/*.decorator.ts` — **PROIBIDO no FE**

**Por que essa regra existe:** decorators de class-validator/class-transformer chamam `Reflect.getMetadata` em runtime. Quando o Vite/esbuild bundla o frontend, o pré-bundle envolve `reflect-metadata` num IIFE que escopa a global Reflect, resultando em `Uncaught TypeError: Reflect.getMetadata is not a function` no boot do app — bloqueando login e qualquer fluxo. Além disso, `class-validator` + `class-transformer` adicionam ~80 KB ao bundle FE sem benefício (FE não roda validação dessa forma).

### ESLint enforcement (obrigatório)

Configurar `@nx/enforce-module-boundaries` em `eslint.config.mjs` com `bannedExternalImports`:

```js
{ sourceTag: 'type:data-access', bannedExternalImports: ['class-validator', 'class-transformer'] },
{ sourceTag: 'type:feature',     bannedExternalImports: ['class-validator', 'class-transformer'] },
{ sourceTag: 'type:ui',          bannedExternalImports: ['class-validator', 'class-transformer'] },
{ sourceTag: 'type:app',         bannedExternalImports: ['class-validator', 'class-transformer'] },
```

### Como aplicar

#### 1. Toda classe DTO `implements` sua interface irmã

```typescript
// libs/auth/domain/src/lib/interfaces/identity.interface.ts
export interface IIdentity {
  readonly id: string;
  readonly email: string;
  readonly name: string;
  readonly status: IdentityStatus;
  readonly role: IdentityRole;
}

// libs/auth/domain/src/lib/dtos/identity.dto.ts
import { Expose } from 'class-transformer';
import { IIdentity } from '../interfaces/identity.interface';

export class IdentityDto implements IIdentity {
  @Expose() readonly id!: string;
  @Expose() readonly email!: string;
  @Expose() readonly name!: string;
  @Expose() readonly status!: IdentityStatus;
  @Expose() readonly role!: IdentityRole;
}
```

A cláusula `implements IIdentity` mantém **sincronia compile-time** entre BE e FE: se a interface mudar, o TypeScript recusa o DTO desalinhado.

#### 2. Entities (TypeORM) também `implements` a interface

```typescript
@Entity('identity')
export class IdentityEntity implements IIdentity {
  @PrimaryGeneratedColumn('uuid') id!: string;
  @Column({ name: 'email_normalized' }) email!: string;
}
```

#### 3. Repositories e Facades do FE consomem interfaces

```typescript
// libs/<scope>/data-access/src/lib/repositories/session.repository.ts
import { IIdentity } from '@<scope>/domain/interfaces/identity.interface';
import { ILoginRequest } from '@<scope>/domain/interfaces/login-request.interface';

@Injectable()
export class SessionRepository {
  login(payload: ILoginRequest): Observable<{ identity: IIdentity }> { ... }
}
```

#### 4. Controllers BE continuam usando DTOs classes

NestJS `ValidationPipe` exige a classe (decorators), e o `ClassSerializerInterceptor` aplica `@Expose()` via `class-transformer` na resposta.

### Re-export para `feature-*`

`feature-*` libs não podem importar `@<scope>/domain/*` (boundary `type:feature` → `type:domain` é bloqueado). `data-access` deve expor um módulo `interfaces.ts` que re-exporta as interfaces necessárias:

```typescript
// libs/<scope>/data-access/src/lib/interfaces.ts
export type { IIdentity } from '@<scope>/domain/interfaces/identity.interface';
export type { ILoginRequest } from '@<scope>/domain/interfaces/login-request.interface';
```

Features consomem via path `@<scope>/data-access/interfaces`.

### Bootstrap zoneless

`apps/web/src/app/app.config.ts` deve usar `provideZonelessChangeDetection()`. Não há `zone.js` no `tsconfig.app.json:types` nem `import 'zone.js'` em `main.ts`. Componentes signal-first dispensam `zone.js` e ficam compatíveis com o pipeline de bundle livre de `reflect-metadata`.

### Auditoria contínua

Antes de qualquer commit que toque `data-access`, `feature-*`, `ui-*` ou `apps/web`:

```bash
grep -rn "from '@<scope>/domain/dtos\|/dtos/.*\.dto'" libs/<scope>/data-access libs/<scope>/feature-* apps/web 2>/dev/null
# resultado deve ser VAZIO
```

Se aparecer match → migrar imediatamente para a interface antes de fazer review/merge.

---

## Standard Domain Module Structure

```
libs/[scope]/domain/src/
├── lib/
│   ├── dtos/           # Data Transfer Objects with class-validator decorators
│   │   ├── [name].dto.ts
│   │   └── index.ts
│   ├── interfaces/     # Pure TypeScript interfaces (no decorators)
│   │   ├── [name].interface.ts
│   │   ├── requests/   # Request-specific interfaces
│   │   │   └── index.ts
│   │   ├── responses/  # Response-specific interfaces
│   │   │   └── index.ts
│   │   └── index.ts
│   ├── enums/          # TypeScript enums
│   │   ├── [name].enum.ts
│   │   └── index.ts
│   ├── types/          # Type aliases
│   │   ├── [name].types.ts
│   │   └── index.ts
│   ├── models/         # Domain models (optional)
│   │   └── index.ts
│   └── exceptions/     # Domain-specific exceptions (optional)
│       └── index.ts
└── index.ts            # Public API exports
```

---

## When to Use Each Type

### Interfaces (`interfaces/`)

Use interfaces for:
- **Response shapes** from APIs
- **Request payloads** structure
- **Props** for React Native components
- **Pure contracts** without runtime validation

```typescript
// interfaces/responses/user-response.interface.ts
export interface UserResponse {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  createdAt: Date;
}
```

### DTOs (`dtos/`)

Use DTOs for:
- **API validation** with `class-validator`
- **Swagger documentation** with `@nestjs/swagger`
- **Request body validation** in controllers

```typescript
// dtos/create-user.dto.ts
import { IsEmail, IsNotEmpty, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateUserDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ minLength: 6 })
  @IsNotEmpty()
  @MinLength(6)
  password: string;
}
```

### Enums (`enums/`)

Use enums for:
- **Fixed sets of values** (status, roles, types)
- **Values shared** between frontend and backend

```typescript
// enums/subscription-status.enum.ts
export enum SubscriptionStatus {
  ACTIVE = 'active',
  PENDING = 'pending',
  CANCELLED = 'cancelled',
  EXPIRED = 'expired',
}
```

### Types (`types/`)

Use types for:
- **Union types** and type aliases
- **Complex type compositions**
- **Generic type utilities**

```typescript
// types/payment.types.ts
export type PaymentMethod = 'credit_card' | 'pix' | 'boleto';
export type PaymentStatus = 'pending' | 'approved' | 'rejected';
```

---

## Import Patterns

### Correct Imports

```typescript
// Import from domain module directly
import { UserResponse, CreateUserDto } from '@user/domain';

// Or from specific subfolders for better tree-shaking
import { UserResponse } from '@user/domain/interfaces';
import { CreateUserDto } from '@user/domain/dtos';
import { SubscriptionStatus } from '@subscription/domain/enums';
```

### Avoid These Patterns

```typescript
// DON'T import from internal paths
import { UserResponse } from '@user/domain/lib/interfaces/user-response.interface';

// DON'T import DTOs from interfaces folder
import { CreateUserDto } from '@user/domain/interfaces'; // Wrong!

// DON'T mix concerns - interfaces should be pure
export interface BadInterface {
  @IsEmail() // DON'T use decorators in interfaces
  email: string;
}
```

---

## Architecture Rules

### 1. Domain Layer Independence
- Domain modules should NOT import from `data-source` or `data-access`
- Domain is the innermost layer - no dependencies on infrastructure

```
✅ domain → (nothing)
✅ data-source → domain
✅ data-access → domain
✅ frontend → domain
❌ domain → data-source
```

### 2. Interface Purity
- Interfaces must be **pure TypeScript** (no decorators)
- No `class-validator`, `@nestjs/swagger`, or other runtime decorators

### 3. DTO Validation
- DTOs **must use** `class-validator` decorators for validation
- DTOs **should use** `@nestjs/swagger` decorators for documentation

### 4. Frontend Imports
- Frontend apps should import **only from domain** modules
- Never import from `data-source` (backend infrastructure)

---

## Reference Module: notification

The `notification` module demonstrates the ideal structure:

```
libs/notification/domain/src/
├── lib/
│   ├── dtos/
│   │   ├── create-notification.dto.ts
│   │   ├── notification.dto.ts
│   │   └── index.ts
│   ├── interfaces/
│   │   ├── notification.interface.ts
│   │   ├── requests/
│   │   │   └── index.ts
│   │   ├── responses/
│   │   │   ├── notification-response.interface.ts
│   │   │   └── index.ts
│   │   └── index.ts
│   ├── enums/
│   │   ├── notification-type.enum.ts
│   │   └── index.ts
│   └── types/
│       └── index.ts
└── index.ts
```

---

## Checklist for New Modules

When creating a new domain module:

- [ ] Create `interfaces/` folder with `index.ts`
- [ ] Create `interfaces/requests/` subfolder if needed
- [ ] Create `interfaces/responses/` subfolder if needed
- [ ] Create `dtos/` folder with `index.ts`
- [ ] Create `enums/` folder with `index.ts` if needed
- [ ] Create `types/` folder with `index.ts` if needed
- [ ] Export all public types from root `index.ts`
- [ ] Ensure interfaces are pure (no decorators)
- [ ] Ensure DTOs have proper validation decorators
- [ ] Run `nx lint [module]-domain` to verify

---

## Migration Guide

### Old Pattern → New Pattern

```typescript
// BEFORE (old pattern)
import { StoreResponse } from '@store/domain';
// Where StoreResponse was exported from a .dto.ts file

// AFTER (new pattern)
import { StoreResponse } from '@store/domain/interfaces';
// Or simply:
import { StoreResponse } from '@store/domain';
// With proper barrel exports
```

### Useful Migration Commands

```bash
# Find all imports of a specific module
grep -r "from '@store/domain'" --include="*.ts" libs/ apps/

# Find deprecated patterns
grep -r "@deprecated" --include="*.ts" libs/*/domain/

# Validate module structure
ls libs/*/domain/src/lib/interfaces/
```

---

## Summary

| Type | Location | Decorators | Use Case |
|------|----------|------------|----------|
| Interface | `interfaces/` | None | Pure contracts, response shapes |
| DTO | `dtos/` | class-validator, swagger | API validation |
| Enum | `enums/` | None | Fixed value sets |
| Type | `types/` | None | Type aliases, unions |

Following this architecture ensures:
- Clear separation of concerns
- Consistent module structure
- Proper validation layer
- Easy navigation and maintenance
