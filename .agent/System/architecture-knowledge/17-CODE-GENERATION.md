# Code Generation (Geracao de Codigo)

## Conceito

Nx Generators automatizam a criacao de codigo repetitivo. Em vez de copiar/colar e renomear manualmente, um generator cria toda a estrutura de arquivos, barrel exports e boilerplate de um novo dominio ou entidade com um unico comando.

---

## 1. Estrutura do Plugin

```
tools/plugin/dx-dev/
├── src/
│   ├── generators/
│   │   ├── entity/
│   │   │   ├── generator.ts       # Logica do generator
│   │   │   ├── schema.json        # Definicao de inputs
│   │   │   └── schema.d.ts        # Tipos TypeScript
│   │   └── use-cases/
│   │       ├── generator.ts
│   │       ├── schema.json
│   │       └── schema.d.ts
│   ├── files/                     # Templates de arquivos
│   │   ├── entity/                # Templates de entidade
│   │   └── use-cases/             # Templates de use cases
│   └── utils/
│       ├── get-all-names.ts       # Gera variantes de nomes
│       ├── pluralize.ts           # Pluralizacao
│       └── index.ts
├── generators.json                # Registry de generators
├── package.json
└── tsconfig.json
```

---

## 2. Registry de Generators

```json
// generators.json
{
  "generators": {
    "entity": {
      "factory": "./src/generators/entity/generator",
      "schema": "./src/generators/entity/schema.json",
      "description": "Entity generator"
    },
    "use-cases": {
      "factory": "./src/generators/use-cases/generator",
      "schema": "./src/generators/use-cases/schema.json",
      "description": "Use Cases"
    }
  }
}
```

---

## 3. Schema (Definicao de Inputs)

```json
// Entity schema
{
  "$schema": "https://json-schema.org/schema",
  "properties": {
    "name": {
      "type": "string",
      "description": "Entity name",
      "$default": { "$source": "argv", "index": 0 },
      "x-prompt": "What name would you like to use?"
    }
  },
  "required": ["name"]
}

// Use Cases schema
{
  "properties": {
    "name": {
      "type": "string",
      "$default": { "$source": "argv", "index": 0 },
      "x-prompt": "What name would you like to use?"
    },
    "scope": {
      "type": "string",
      "description": "Domain scope"
    }
  },
  "required": ["name", "scope"]
}
```

---

## 4. Name Transformation Utility

A funcao `getAllNames()` gera todas as variantes de nomenclatura:

```typescript
function getAllNames(name: string) {
  const names = getNames(name);
  return {
    ...names,
    fileName: names.fileName,           // kebab-case: "job-opening"
    className: names.className,         // PascalCase: "JobOpening"
    propertyName: names.propertyName,   // camelCase: "jobOpening"
    constantName: names.constantName,   // UPPER_SNAKE: "JOB_OPENING"
    plural: pluralize(names.fileName),  // Plural: "job-openings"
  };
}

function normalizeOptions(options: EntityGeneratorSchema) {
  const allNames = getAllNames(options.name);
  return {
    ...options,
    ...allNames,
    scope: options.scope ?? allNames.fileName,
  };
}
```

---

## 5. Generator Logic

### Entity Generator

```typescript
export async function entityGenerator(
  tree: Tree,
  options: EntityGeneratorSchema
) {
  const normalizedOptions = normalizeOptions(options);

  // 1. Gera arquivos a partir de templates
  generateFiles(
    tree,
    join(__dirname, 'files'),
    'packages',
    normalizedOptions
  );

  // 2. Calcula caminhos para barrel exports
  const barrels = buildBarrelPaths(
    normalizedOptions.scope,
    normalizedOptions.fileName
  );

  // 3. Adiciona exports aos barrel files (index.ts)
  for (const { path, file } of barrels) {
    addFileToBarrel(tree, path, file);
  }

  // 4. Formata todos os arquivos gerados
  await formatFiles(tree);
}
```

### Use Cases Generator

```typescript
export async function useCasesGenerator(
  tree: Tree,
  options: UseCasesGeneratorSchema
) {
  const normalizedOptions = normalizeOptions(options);
  const srcFolder = join(__dirname, '..', '..', 'files', 'use-cases');

  // 1. Gera arquivos de use cases
  generateFiles(tree, srcFolder, 'packages', normalizedOptions);

  // 2. Formata arquivos
  await formatFiles(tree);
}
```

---

## 6. Templates de Arquivo

Templates usam EJS syntax com variaveis do schema:

### Template de Use Case

```typescript
// __scope__/domain/src/client/use-cases/create-__fileName__.ts.template

import { UseCase } from '@devmx/shared-api-interfaces';
import { <%= className %>Service } from '../services';
import { Editable<%= className %> } from '../../lib/dtos';

export class Create<%= className %>UseCase
  implements UseCase<Editable<%= className %>, <%= className %>>
{
  constructor(private <%= propertyName %>Service: <%= className %>Service) {}

  execute(data: Editable<%= className %>) {
    return this.<%= propertyName %>Service.create(data);
  }
}
```

### Arquivo Gerado (com `name = "job-opening"`)

```typescript
// career/domain/src/client/use-cases/create-job-opening.ts

import { UseCase } from '@devmx/shared-api-interfaces';
import { JobOpeningService } from '../services';
import { EditableJobOpening } from '../../lib/dtos';

export class CreateJobOpeningUseCase
  implements UseCase<EditableJobOpening, JobOpening>
{
  constructor(private jobOpeningService: JobOpeningService) {}

  execute(data: EditableJobOpening) {
    return this.jobOpeningService.create(data);
  }
}
```

### Templates CRUD Completo

```
files/use-cases/__scope__/domain/src/client/use-cases/
├── create-__fileName__.ts.template
├── find-__fileName__-by-id.ts.template
├── find-__plural__.ts.template
├── update-__fileName__.ts.template
├── delete-__fileName__.ts.template
└── index.ts.template
```

---

## 7. Barrel Export Management

```typescript
function addFileToBarrel(tree: Tree, barrelPath: string, fileName: string) {
  const content = tree.read(barrelPath, 'utf-8');

  if (content && !content.includes(fileName)) {
    const exportLine = `export * from './${fileName}';`;
    tree.write(barrelPath, content + '\n' + exportLine);
  }
}

function buildBarrelPaths(scope: string, fileName: string) {
  return [
    {
      path: `packages/${scope}/domain/src/client/use-cases/index.ts`,
      file: `create-${fileName}`,
    },
    {
      path: `packages/${scope}/domain/src/client/use-cases/index.ts`,
      file: `find-${fileName}-by-id`,
    },
    // ... todos os use cases
  ];
}
```

---

## 8. Execucao do Generator

```bash
# Gerar nova entidade
nx generate @devmx/dx-dev:entity blog-post

# Gerar use cases para um scope existente
nx generate @devmx/dx-dev:use-cases blog-post --scope=blog

# Dry run (preview sem gerar)
nx generate @devmx/dx-dev:entity blog-post --dry-run
```

---

## 9. O que um Generator Cria

Para `nx generate @devmx/dx-dev:entity blog-post`:

```
packages/blog-post/
├── domain/src/
│   ├── lib/dtos/
│   │   ├── create-blog-post.ts
│   │   ├── update-blog-post.ts
│   │   └── index.ts
│   ├── client/
│   │   ├── services/
│   │   │   ├── blog-post.ts        # BlogPostService (abstract)
│   │   │   └── index.ts
│   │   └── use-cases/
│   │       ├── create-blog-post.ts  # CreateBlogPostUseCase
│   │       ├── find-blog-posts.ts   # FindBlogPostsUseCase
│   │       ├── find-blog-post-by-id.ts
│   │       ├── update-blog-post.ts
│   │       ├── delete-blog-post.ts
│   │       └── index.ts
│   └── server/
│       ├── services/
│       │   └── blog-posts.ts       # BlogPostsService (abstract)
│       └── use-cases/
│           ├── create-blog-post.ts
│           ├── find-blog-posts.ts
│           └── ...
```

---

## Principios de Code Generation

| Principio | Implementacao |
|-----------|---------------|
| **Consistencia** | Todos os dominios seguem a mesma estrutura |
| **DRY** | Templates eliminam copiar/colar |
| **Barrel management** | Exports atualizados automaticamente |
| **Name transformation** | Uma entrada gera todas as variantes |
| **Dry run** | Preview antes de gerar |
| **Formatacao** | Arquivos formatados automaticamente |

---

## Como Aplicar em Qualquer Projeto

1. **Identifique o boilerplate repetitivo** (a estrutura que se repete para cada dominio)
2. **Crie templates EJS** com variaveis para nomes
3. **Crie um schema JSON** definindo os inputs do generator
4. **Use `getAllNames()`** para gerar todas as variantes de nomenclatura
5. **Atualize barrel exports** automaticamente
6. **Formate arquivos** apos gerar
7. **Teste com `--dry-run`** antes de executar
8. **Documente o generator** no README do plugin
