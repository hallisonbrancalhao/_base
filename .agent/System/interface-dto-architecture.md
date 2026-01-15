# Interface/DTO Architecture Guide

## Overview

This document describes the standard structure for organizing interfaces, DTOs, enums, and types in domain modules. Following this architecture ensures consistency, maintainability, and proper separation of concerns across the monorepo.

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
