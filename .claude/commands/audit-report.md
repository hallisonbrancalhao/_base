---
description: Relatório completo de validação (performance + segurança + arquitetura) contra bugs gerados por IA
---

# /audit-report - AI-Guard Complete Report

Executa auditoria completa do projeto usando 3 especialistas em paralelo para detectar problemas introduzidos por código gerado por IA.

**Cobertura**:
- 🚀 **Performance**: N+1 queries, race conditions, memory leaks
- 🔒 **Segurança**: security lint (SAST), secret scan, lib exploit (SCA), version pinning
- 🏗️ **Arquitetura**: tradeoffs documentados, confiabilidade (failure tests), contingências (DR)

## Usage

```
/audit-report [scope]
```

- `scope`: `affected` (default) | `all` | `lib:[name]` | `feature:[name]`

## Examples

```
/audit-report                          # Projetos afetados pelo último commit
/audit-report all                      # Codebase inteiro
/audit-report lib:admin                # Apenas escopo admin
/audit-report feature:user-profile     # Feature específica
```

## Protocolo de Execução

### Fase 1 — Análise Paralela (3 agents simultâneos)

Spawne os 3 agents via Task tool em **uma única mensagem** (todos em paralelo):

**Agent 1 — Performance**:
```
@performance-auditor
  task: Auditar performance do escopo $ARGUMENTS
  scope: $ARGUMENTS ou affected
  detectors: all
```

**Agent 2 — Segurança**:
```
@security-auditor
  task: Auditar segurança do escopo $ARGUMENTS
  scope: $ARGUMENTS ou affected
  checks: all
```

**Agent 3 — Arquitetura**:
```
@architecture-reviewer
  task: Revisar arquitetura do escopo $ARGUMENTS
  scope: $ARGUMENTS ou affected
  pillars: all
```

### Fase 2 — Agregação

Consolide os 3 relatórios em um único documento no formato:

```markdown
# 🛡️ AI-Guard Report — [data]

**Escopo**: $ARGUMENTS
**Data**: [YYYY-MM-DD HH:mm]

## 📊 Executive Summary

| Pilar | Critical | High | Medium | Low | Total |
|-------|---------:|-----:|-------:|----:|------:|
| Performance | X | X | X | X | X |
| Segurança | X | X | X | X | X |
| Arquitetura | X | X | X | X | X |
| **Total** | **X** | **X** | **X** | **X** | **X** |

## 🔥 Top 5 Críticos (prioridade máxima)

1. [pilar] [file:line] — evidência → fix
2. ...

## 🚀 Performance Findings
[cola relatório completo do @performance-auditor]

## 🔒 Security Findings
[cola relatório completo do @security-auditor]

## 🏗️ Architecture Findings
[cola relatório completo do @architecture-reviewer]

## ✅ Plano de Ação (priorizado)

### Sprint 1 (críticos)
- [ ] ...

### Sprint 2 (altos)
- [ ] ...

### Backlog (médios/baixos)
- [ ] ...
```

### Fase 3 — Persistência

Salvar o relatório em:
```
.agent/Tasks/audit-reports/YYYY-MM-DD-audit-report.md
```

E apresentar link no chat para o usuário revisar.

## Quando Usar

- ✅ Antes de um release importante
- ✅ Após merge de PR grande gerado por IA
- ✅ Auditoria periódica (semanal/quinzenal)
- ✅ Quando o usuário pedir "relatório completo" ou "validar o projeto"
- ✅ Onboarding de novo código legado

## Integração com CI

Exemplo de step em GitHub Actions:

```yaml
- name: AI-Guard Audit
  run: |
    claude-code --command="/audit-report affected"
    cat .agent/Tasks/audit-reports/latest.md >> $GITHUB_STEP_SUMMARY
```

## Regras

- Os 3 agents **DEVEM** ser invocados em paralelo (1 mensagem, 3 Task calls)
- Nunca executar `/audit-report` sem apresentar o relatório ao usuário
- Severidade: `critical` (bloqueia release) | `high` (corrigir no sprint) | `medium` (próximo sprint) | `low` (backlog)
