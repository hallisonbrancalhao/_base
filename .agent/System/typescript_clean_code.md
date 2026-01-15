# TypeScript Clean Code Standards

## Purpose

This document defines mandatory clean code standards for TypeScript development. Code must be self-documenting through naming, structure, and types—not through excessive comments.

---

## 1. Naming Conventions

### 1.1 General Rules

| Element | Convention | Example |
|---------|------------|---------|
| Classes | PascalCase | `UserService`, `PaymentGateway` |
| Interfaces | PascalCase (no prefix) | `User`, `ApiResponse` |
| Types | PascalCase | `UserId`, `PaymentStatus` |
| Functions/Methods | camelCase, verb-first | `getUserById`, `calculateTotal` |
| Variables | camelCase | `currentUser`, `totalAmount` |
| Constants | SCREAMING_SNAKE_CASE | `MAX_RETRY_COUNT`, `API_BASE_URL` |
| Enums | PascalCase (members too) | `UserRole.Admin` |
| Private members | camelCase (no underscore prefix) | `private userId` |
| Boolean | is/has/can/should prefix | `isActive`, `hasPermission` |

### 1.2 Self-Documenting Names

```typescript
// BAD - requires comment to understand
const d = 86400; // seconds in a day

// GOOD - name explains itself
const SECONDS_PER_DAY = 86400;
```

```typescript
// BAD - ambiguous
function process(data: unknown[]): void;

// GOOD - intent is clear
function validateAndSaveUserRecords(records: UserRecord[]): void;
```

---

## 2. Functions

### 2.1 Single Responsibility

Each function does ONE thing. If you need "and" to describe it, split it.

```typescript
// BAD - multiple responsibilities
function validateAndSaveUser(user: User): void {
  if (!user.email) throw new Error('Invalid email');
  if (!user.name) throw new Error('Invalid name');
  this.repository.save(user);
  this.emailService.sendWelcome(user.email);
}

// GOOD - single responsibility
function validateUser(user: User): void {
  if (!user.email) throw new Error('Invalid email');
  if (!user.name) throw new Error('Invalid name');
}

function saveUser(user: User): void {
  this.repository.save(user);
}

function notifyNewUser(email: string): void {
  this.emailService.sendWelcome(email);
}
```

### 2.2 Maximum 5 Statements

Functions exceeding 5 statements must be refactored.

```typescript
// BAD - too many statements
function processOrder(order: Order): void {
  const user = this.userService.getById(order.userId);
  const items = this.itemService.getByIds(order.itemIds);
  const total = items.reduce((sum, item) => sum + item.price, 0);
  const discount = this.discountService.calculate(user, total);
  const finalTotal = total - discount;
  const payment = this.paymentService.charge(user, finalTotal);
  const confirmation = this.confirmationService.create(order, payment);
  this.emailService.send(user.email, confirmation);
}

// GOOD - delegated responsibilities
function processOrder(order: Order): void {
  const context = this.buildOrderContext(order);
  const payment = this.executePayment(context);
  this.sendConfirmation(context, payment);
}
```

### 2.3 Parameters

- Maximum 3 parameters
- Use object parameter for more

```typescript
// BAD - too many parameters
function createUser(
  name: string,
  email: string,
  age: number,
  role: string,
  department: string
): User;

// GOOD - object parameter
interface CreateUserParams {
  name: string;
  email: string;
  age: number;
  role: UserRole;
  department: string;
}

function createUser(params: CreateUserParams): User;
```

### 2.4 Return Early

Avoid deep nesting with early returns.

```typescript
// BAD - deep nesting
function getDiscount(user: User): number {
  if (user) {
    if (user.isPremium) {
      if (user.yearsActive > 5) {
        return 0.3;
      } else {
        return 0.2;
      }
    } else {
      return 0.1;
    }
  }
  return 0;
}

// GOOD - early returns
function getDiscount(user: User | null): number {
  if (!user) return 0;
  if (!user.isPremium) return 0.1;
  if (user.yearsActive <= 5) return 0.2;
  return 0.3;
}
```

---

## 3. Classes

### 3.1 Structure Order

```typescript
class UserService {
  // 1. Static members
  static readonly DEFAULT_ROLE = UserRole.Guest;

  // 2. Private fields
  private readonly repository: UserRepository;
  private readonly cache: CacheService;

  // 3. Constructor
  constructor(repository: UserRepository, cache: CacheService) {
    this.repository = repository;
    this.cache = cache;
  }

  // 4. Public methods
  getById(id: string): User | null {
    return this.findInCacheOrRepository(id);
  }

  // 5. Private methods
  private findInCacheOrRepository(id: string): User | null {
    return this.cache.get(id) ?? this.repository.findById(id);
  }
}
```

### 3.2 Single Responsibility

A class should have only one reason to change.

```typescript
// BAD - multiple responsibilities
class User {
  save(): void { /* database logic */ }
  sendEmail(): void { /* email logic */ }
  generateReport(): void { /* report logic */ }
}

// GOOD - separated concerns
class User { /* user data only */ }
class UserRepository { /* persistence */ }
class UserNotificationService { /* notifications */ }
class UserReportGenerator { /* reports */ }
```

### 3.3 Composition Over Inheritance

```typescript
// BAD - inheritance chain
class Animal { }
class Mammal extends Animal { }
class Dog extends Mammal { }
class ServiceDog extends Dog { }

// GOOD - composition
interface Walkable { walk(): void; }
interface Trainable { train(): void; }

class Dog implements Walkable {
  walk(): void { }
}

class ServiceDog {
  constructor(
    private readonly dog: Dog,
    private readonly training: TrainingService
  ) { }
}
```

---

## 4. Comments Policy

### 4.1 Forbidden Comments

```typescript
// FORBIDDEN - obvious comments
const count = 0; // initialize count to zero

// FORBIDDEN - changelog comments
// Changed by John on 2024-01-15
// Modified to fix bug #123

// FORBIDDEN - commented-out code
// function oldImplementation() { }

// FORBIDDEN - closing brace comments
} // end if
} // end for
} // end class
```

### 4.2 Allowed Comments

```typescript
// ALLOWED - TODO with ticket reference
// TODO(TICKET-123): Implement retry logic

// ALLOWED - public API documentation (JSDoc)
/**
 * Calculates compound interest.
 * @param principal - Initial investment amount
 * @param rate - Annual interest rate (decimal)
 * @param periods - Number of compounding periods
 * @returns Final amount after interest
 */
function calculateCompoundInterest(
  principal: number,
  rate: number,
  periods: number
): number {
  return principal * Math.pow(1 + rate, periods);
}
```

### 4.3 JSDoc Usage

Use JSDoc ONLY for:
- Public APIs consumed externally
- Library functions
- Complex algorithms requiring explanation

Do NOT use JSDoc for:
- Internal methods
- Self-explanatory functions
- Private members

---

## 5. Type Safety

### 5.1 Strict Mode Required

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true
  }
}
```

### 5.2 Avoid `any`

```typescript
// BAD
function process(data: any): any { }

// GOOD
function process<T extends Record<string, unknown>>(data: T): ProcessedData { }

// ACCEPTABLE - when truly unknown
function parseExternalResponse(data: unknown): ParsedResponse {
  if (!isValidResponse(data)) {
    throw new Error('Invalid response format');
  }
  return data as ParsedResponse;
}
```

### 5.3 Type Guards

```typescript
// BAD - type assertion without validation
const user = response as User;

// GOOD - type guard
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'email' in value
  );
}

if (isUser(response)) {
  console.log(response.email);
}
```

### 5.4 Discriminated Unions

```typescript
// GOOD - exhaustive type checking
type Result<T> =
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error }
  | { status: 'loading' };

function handleResult<T>(result: Result<T>): void {
  switch (result.status) {
    case 'success':
      console.log(result.data);
      break;
    case 'error':
      console.error(result.error);
      break;
    case 'loading':
      console.log('Loading...');
      break;
  }
}
```

---

## 6. Error Handling

### 6.1 Custom Errors

```typescript
// GOOD - specific error types
class ValidationError extends Error {
  constructor(
    message: string,
    public readonly field: string
  ) {
    super(message);
    this.name = 'ValidationError';
  }
}

class NotFoundError extends Error {
  constructor(resource: string, id: string) {
    super(`${resource} with id ${id} not found`);
    this.name = 'NotFoundError';
  }
}
```

### 6.2 Result Pattern

```typescript
// GOOD - explicit error handling
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function parseJson<T>(json: string): Result<T> {
  try {
    return { ok: true, value: JSON.parse(json) as T };
  } catch (error) {
    return { ok: false, error: error as Error };
  }
}

const result = parseJson<User>(jsonString);
if (result.ok) {
  console.log(result.value);
} else {
  console.error(result.error);
}
```

---

## 7. Immutability

### 7.1 Prefer `const` and `readonly`

```typescript
// GOOD
const CONFIG = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
} as const;

interface User {
  readonly id: string;
  readonly email: string;
  name: string; // only mutable field
}
```

### 7.2 Immutable Operations

```typescript
// BAD - mutation
function addItem(items: Item[], newItem: Item): void {
  items.push(newItem);
}

// GOOD - immutable
function addItem(items: readonly Item[], newItem: Item): Item[] {
  return [...items, newItem];
}
```

---

## 8. Code Organization

### 8.1 File Structure

```
feature/
├── feature.service.ts      # Business logic
├── feature.repository.ts   # Data access
├── feature.model.ts        # Types/interfaces
├── feature.controller.ts   # Entry point (API/UI)
└── feature.spec.ts         # Tests
```

### 8.2 Import Order

```typescript
// 1. Node modules
import { Injectable } from '@nestjs/common';
import { Observable } from 'rxjs';

// 2. Workspace libs (@org/*)
import { User } from '@myorg/shared/models';
import { LoggerService } from '@myorg/shared/utils';

// 3. Relative imports
import { UserRepository } from './user.repository';
import { UserMapper } from './user.mapper';
```

---

## 9. Enforcement Checklist

Before committing, verify:

- [ ] All names are self-documenting
- [ ] Functions have single responsibility
- [ ] Functions have maximum 5 statements
- [ ] No `any` types (or justified with comment)
- [ ] No commented-out code
- [ ] No obvious comments
- [ ] JSDoc only on public APIs
- [ ] Early returns used (no deep nesting)
- [ ] Immutable patterns where possible
- [ ] Custom errors for domain exceptions

---

## 10. Quick Reference

| Rule | Threshold |
|------|-----------|
| Max function statements | 5 |
| Max function parameters | 3 |
| Max class methods | 10 |
| Max file lines | 200 |
| Max nesting depth | 2 |
| Comments per function | 0-1 |
