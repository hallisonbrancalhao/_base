# Barrel Exports - Boas Praticas

## Regra Fundamental

**SEMPRE prefira imports diretos ao inves de imports via barrel.**

```typescript
// CORRETO - Import direto
import { StoreDto } from '@store/domain/dtos/store.dto';
import { UserEntity } from '@backend/database/entities/user.entity';

// INCORRETO - Import via barrel
import { StoreDto } from '@store/domain';
import { UserEntity } from '@backend/database';
```

---

## Por que Imports Diretos?

| Aspecto | Import via Barrel | Import Direto |
|---------|-------------------|---------------|
| Tree-shaking | Falha frequentemente | Funciona corretamente |
| Bundle size | Carrega modulos extras | Carrega apenas o necessario |
| Build time | Mais lento | Mais rapido |
| Analise de dependencias | Complexa | Simples e direta |

---

## Estrutura de Paths no tsconfig.base.json

### Configuracao Obrigatoria

```json
{
  "compilerOptions": {
    "paths": {
      // Path para barrel (manter para retrocompatibilidade)
      "@store/domain": ["libs/store/domain/src/index.ts"],

      // Path para imports diretos (PREFERIDO)
      "@store/domain/*": ["libs/store/domain/src/lib/*"]
    }
  }
}
```

### Padrao de Nomenclatura

```
@{scope}/{lib}/*

Exemplos:
@store/domain/*
@user/data-access/*
@payment/api/*
@backend/shared/*
@shared/ui/*
```

---

## Padroes de Import por Camada

### 1. Domain Layer (DTOs, Interfaces, Models)

```typescript
// DTOs
import { StoreDto } from '@store/domain/dtos/store.dto';
import { CreateUserDto } from '@user/domain/dtos/create-user.dto';

// Interfaces
import { IStoreRepository } from '@store/domain/interfaces/store-repository.interface';

// Models
import { StoreModel } from '@store/domain/models/store.model';

// Enums
import { StoreStatus } from '@store/domain/enums/store-status.enum';
```

### 2. Data Access Layer (Services, State)

```typescript
// Services
import { StoreService } from '@store/data-access/services/store.service';
import { AuthService } from '@auth/data-access/services/auth.service';

// State (NgRx/Signals)
import { StoreState } from '@store/data-access/state/store.state';
import { storeSignals } from '@store/data-access/signals/store.signals';
```

### 3. Data Source Layer (Repositories, API Clients)

```typescript
// Repositories
import { StoreRepository } from '@store/data-source/repositories/store.repository';

// API Clients
import { PaymentApiClient } from '@payment/data-source/api/payment-api.client';
```

### 4. Backend/Database Layer (Entities, Schemas)

```typescript
// Entities
import { UserEntity } from '@backend/database/entities/user.entity';
import { StoreEntity } from '@backend/database/entities/store.entity';

// Schemas (MongoDB)
import { UserSchema } from '@backend/database/schemas/user.schema';
```

### 5. UI Layer (Components, Directives, Pipes)

```typescript
// Components
import { ButtonComponent } from '@shared/ui/components/button/button.component';
import { CardComponent } from '@shared/ui/components/card/card.component';

// Directives
import { ClickOutsideDirective } from '@shared/ui/directives/click-outside.directive';

// Pipes
import { CurrencyBrPipe } from '@shared/ui/pipes/currency-br.pipe';
```

### 6. Utils Layer (Funcoes Utilitarias)

```typescript
// Utils
import { formatCurrency } from '@shared/utils/formatters/currency.formatter';
import { validateCpf } from '@shared/utils/validators/cpf.validator';
```

---

## Quando Barrels SAO Permitidos

### Barrels PERMITIDOS (Manter)

1. **Entry points de API publica de bibliotecas**
   ```
   libs/store/api/src/index.ts
   ```

2. **Entry points de aplicacoes**
   ```
   apps/web/src/index.ts
   apps/api/src/main.ts
   ```

3. **Grupos coesos que SEMPRE sao usados juntos**
   ```typescript
   // Permitido: exportar validators que sempre sao usados em conjunto
   // libs/shared/validators/src/index.ts
   export { required } from './lib/required.validator';
   export { minLength } from './lib/min-length.validator';
   export { maxLength } from './lib/max-length.validator';
   ```

### Barrels PROIBIDOS (Remover)

1. **Subdiretorios internos de bibliotecas**
   ```
   libs/store/domain/src/lib/dtos/index.ts      // PROIBIDO
   libs/store/domain/src/lib/interfaces/index.ts // PROIBIDO
   ```

2. **Barrels com wildcard exports**
   ```typescript
   // PROIBIDO
   export * from './dtos';
   export * from './interfaces';
   export * from './models';
   ```

3. **Barrels com mais de 10 exports nao relacionados**

---

## Regras de ESLint

### Configuracao Recomendada

```json
{
  "plugins": ["no-barrel-files"],
  "rules": {
    "no-barrel-files/no-barrel-files": "warn"
  }
}
```

### Regra Customizada para o Projeto

```json
{
  "rules": {
    "no-restricted-imports": [
      "error",
      {
        "patterns": [
          {
            "group": ["@*/domain", "@*/data-access", "@*/data-source"],
            "message": "Use imports diretos: @scope/lib/path/to/file"
          }
        ]
      }
    ]
  }
}
```

---

## Exemplos Praticos

### Exemplo 1: Feature Component

```typescript
// store-list.component.ts

// CORRETO
import { StoreDto } from '@store/domain/dtos/store.dto';
import { StoreService } from '@store/data-access/services/store.service';
import { CardComponent } from '@shared/ui/components/card/card.component';

// INCORRETO
import { StoreDto } from '@store/domain';
import { StoreService } from '@store/data-access';
import { CardComponent } from '@shared/ui';
```

### Exemplo 2: Backend Service

```typescript
// store.service.ts

// CORRETO
import { StoreEntity } from '@backend/database/entities/store.entity';
import { CreateStoreDto } from '@store/domain/dtos/create-store.dto';
import { IStoreRepository } from '@store/domain/interfaces/store-repository.interface';

// INCORRETO
import { StoreEntity, CreateStoreDto, IStoreRepository } from '@store/domain';
```

### Exemplo 3: Multiplos Imports do Mesmo Modulo

```typescript
// CORRETO - Mesmo que sejam varios imports
import { StoreDto } from '@store/domain/dtos/store.dto';
import { CreateStoreDto } from '@store/domain/dtos/create-store.dto';
import { UpdateStoreDto } from '@store/domain/dtos/update-store.dto';

// INCORRETO - Barrel import
import { StoreDto, CreateStoreDto, UpdateStoreDto } from '@store/domain';
```

---

## Checklist de Revisao de Codigo

Antes de aprovar um PR, verificar:

- [ ] Nenhum import via barrel (`from '@scope/lib'` sem path adicional)
- [ ] Todos os imports usam paths diretos (`from '@scope/lib/path/to/file'`)
- [ ] Nenhum novo arquivo `index.ts` criado em subdiretorios
- [ ] Nenhum `export * from` adicionado

---

## Migracao de Imports Existentes

### Processo de Conversao

1. **Identificar import via barrel**
   ```typescript
   import { StoreDto } from '@store/domain';
   ```

2. **Localizar arquivo fonte**
   ```bash
   # Encontrar onde StoreDto esta definido
   grep -r "export class StoreDto" libs/
   # Resultado: libs/store/domain/src/lib/dtos/store.dto.ts
   ```

3. **Converter para import direto**
   ```typescript
   import { StoreDto } from '@store/domain/dtos/store.dto';
   ```

---

## Resumo das Regras

| Regra | Descricao |
|-------|-----------|
| **R1** | Sempre usar imports diretos |
| **R2** | Nunca usar `export * from` |
| **R3** | Nunca criar `index.ts` em subdiretorios |
| **R4** | Manter barrels apenas em entry points de API |
| **R5** | Configurar paths `@scope/lib/*` no tsconfig |
| **R6** | Habilitar ESLint rule `no-barrel-files` |

---

## Referencias

- [Atlassian: Performance improvements removing barrels](https://blog.atlassian.com/tag/performance/)
- [Vite: Tree-shaking documentation](https://vitejs.dev/guide/features.html#tree-shaking)
- [ESLint no-barrel-files plugin](https://www.npmjs.com/package/eslint-plugin-no-barrel-files)

---
