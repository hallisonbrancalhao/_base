---
description: Implementar task do .agent/Tasks com contexto completo
---

# Implementação de Tasks com Context .agent/

Você vai me ajudar a implementar uma task do diretório `.agent/Tasks` seguindo todos os padrões do projeto.

## Instruções Passo-a-Passo

### 1. Obter Task Context

Primeiro, navegue até `.agent/Tasks/` e escolha uma task com status não finalizado:

```bash
ls -la /Users/halissonbrancalhao/Development/base/.agent/Tasks/
```

Verifique os arquivos de task (TASK, PRDs, BUG) e selecione uma com status **TODO** ou **IN_PROGRESS**.

### 2. Carregar Project Context

**SEMPRE leia estes arquivos antes de implementar** (na ordem):

1. **Estrutura geral**:
   - `.agent/README.md`

2. **Padrões técnicos** (conforme tipo de task):
   - project: `.agent/System/project_overview.md`
   - libs: `.agent/System/libs_structure.md`
   - base: `.agent/System/base_rules.md`
   - Angular: `.agent/System/angular_best_practices.md`
     - `.agent/System/nx_architecture_guide.md`
   - NestJS: `.agent/System/nestjs_reference.md`
   - PrimeNG: `.agent/System/primeng_best_practices.md`
   - Testes: `.agent/System/angular_unit_testing_guide.md`

### 3. Implementar Task

Com base no conteúdo da task e dos padrões do projeto:

**Requirements Obrigatórios**:
- ✅ Angular: standalone components, signals, `input()`/`output()`, `@if`/`@for`
- ✅ NestJS: Clean Architecture, DTOs com validação, dependency injection
- ✅ Testes: Mock all, schemas, `data-testid`, `componentRef.setInput()`
- ✅ PrimeNG: Use components (`p-button`, `p-select`), NOT directives
- ❌ NO NgModules, NO `*ngIf`/`*ngFor`, NO `any` types, NO business logic in controllers

**Deliverables**:
1. Código implementado seguindo TODOS os padrões
2. Testes unitários (coverage >80%)
3. Resumo de implementação

### 4. Atualizar Status da Task

Após implementação, atualize o arquivo da task em `.agent/Tasks/` alterando o campo `status`:

```
status: DONE
completed_at: [data atual]
implementation_notes: [resumo detalhado do que foi implementado, decisões técnicas, testes adicionados]
```

### 5. Próxima Task

Repita o processo com a próxima task não finalizada:

```bash
ls -la /Users/halissonbrancalhao/Development/base/.agent/Tasks/
```

---

## Fluxo Completo

```
1. Listar tasks em .agent/Tasks/
2. Escolher task com status TODO ou IN_PROGRESS
3. Ler conteúdo da task (TASK, PRDs, BUG)
4. Ler .agent/ context
5. Implementar seguindo padrões
6. Escrever testes (>80% coverage)
7. Atualizar status da task para DONE
8. Ir para próxima task
```

---

## Tipos de Tasks Suportadas

- **TASK**: Implementações de features/fixes
- **PRDs**: Requisitos de produto e especificações
- **BUG**: Correções de bugs identificados
- **FEATURE**: Novas funcionalidades
- **REFACTOR**: Melhorias e refatoração de código

---

## Exemplo de Implementação

```
**Task Context**:
[Conteúdo da task de .agent/Tasks/]

**Implementation**:
- Seguindo .agent/System/angular_best_practices.md
- Usando standalone component com signals
- PrimeNG para UI
- Testes com >80% coverage

**Deliverables**:
1. Código implementado
2. Testes
3. Status atualizado em .agent/Tasks/
```

---

**Agora me mostre qual task deseja implementar e vamos começar!**
