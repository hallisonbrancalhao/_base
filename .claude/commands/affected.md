# Nx Affected Analysis

Analise e execute ações nos projetos afetados pelas mudanças recentes.

## Contexto
Argumento: **$ARGUMENTS** (lint | test | build | all | graph)

## Comandos por Ação

### lint
```bash
npx nx affected:lint --base=HEAD~1
```

### test
```bash
npx nx affected:test --base=HEAD~1
```

### build
```bash
npx nx affected:build --base=HEAD~1
```

### all
```bash
npx nx affected:lint --base=HEAD~1
npx nx affected:test --base=HEAD~1
npx nx affected:build --base=HEAD~1
```

### graph
```bash
npx nx graph --affected
```

## Processo
1. Identifique a ação solicitada ($ARGUMENTS)
2. Execute o comando Nx correspondente
3. Reporte resultados de forma clara
4. Se houver falhas, liste os projetos e arquivos problemáticos

## Se nenhum argumento for passado
Execute `npx nx affected --base=HEAD~1` para listar projetos afetados.
