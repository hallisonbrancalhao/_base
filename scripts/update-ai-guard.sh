#!/usr/bin/env bash

# =============================================================================
# update-ai-guard.sh - Sync apenas AI-Guard (performance + segurança + arquitetura)
# =============================================================================
#
# Aplica as auditorias AI-Guard em projetos que já possuem a estrutura .agent/
# e .claude/ mas ainda não têm os 3 novos agents / skills / command.
#
# Uso:
#   ./scripts/update-ai-guard.sh <target-project> [--dry-run] [--verbose]
#
# O que é sincronizado:
#   .claude/skills/performance-auditor/SKILL.md
#   .claude/skills/security-auditor/SKILL.md
#   .claude/skills/architecture-reviewer/SKILL.md
#   .claude/agents/performance-auditor.md
#   .claude/agents/security-auditor.md
#   .claude/agents/architecture-reviewer.md
#   .claude/commands/audit-report.md
#   .agent/Agents/quality/@performance-auditor.md
#   .agent/Agents/quality/@security-auditor.md
#   .agent/Agents/quality/@architecture-reviewer.md
#
# =============================================================================

set -euo pipefail

# Colors
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'
RED='\033[0;31m';   CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

TARGET_DIR=""
DRY_RUN=false
VERBOSE=false

# Lista canônica dos arquivos AI-Guard
AI_GUARD_FILES=(
  ".claude/skills/performance-auditor/SKILL.md"
  ".claude/skills/security-auditor/SKILL.md"
  ".claude/skills/architecture-reviewer/SKILL.md"
  ".claude/agents/performance-auditor.md"
  ".claude/agents/security-auditor.md"
  ".claude/agents/architecture-reviewer.md"
  ".claude/commands/audit-report.md"
  ".agent/Agents/quality/@performance-auditor.md"
  ".agent/Agents/quality/@security-auditor.md"
  ".agent/Agents/quality/@architecture-reviewer.md"
)

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
info()    { echo -e "${CYAN}▸${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn()    { echo -e "${YELLOW}⚠${NC} $1"; }
error()   { echo -e "${RED}✗${NC} $1" >&2; exit 1; }
verbose() { [[ "$VERBOSE" == true ]] && echo -e "  ${CYAN}→${NC} $1"; }

header() {
  echo -e "\n${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
  echo -e "${BOLD}  $1${NC}"
  echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

# -----------------------------------------------------------------------------
# Args
# -----------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --verbose) VERBOSE=true; shift ;;
    --help|-h)
      head -25 "$0" | tail -20
      exit 0
      ;;
    -*) error "Flag desconhecida: $1" ;;
    *)
      [[ -z "$TARGET_DIR" ]] && TARGET_DIR="$1" || error "Múltiplos targets"
      shift
      ;;
  esac
done

[[ -z "$TARGET_DIR" ]] && error "Informe o diretório alvo. Use --help para ajuda."
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || error "Target não existe: $TARGET_DIR"
[[ "$TARGET_DIR" == "$BASE_DIR" ]] && error "Target não pode ser o próprio _base"

# -----------------------------------------------------------------------------
# Pré-checagens
# -----------------------------------------------------------------------------
header "AI-Guard Updater"

echo -e "${BOLD}Source:${NC} $BASE_DIR"
echo -e "${BOLD}Target:${NC} $TARGET_DIR"
[[ "$DRY_RUN" == true ]] && warn "DRY RUN — nenhum arquivo será modificado"
echo ""

[[ -d "$TARGET_DIR/.claude" ]] || warn ".claude/ não existe no target — será criado"
[[ -d "$TARGET_DIR/.agent" ]] || warn ".agent/ não existe no target — será criado"

# -----------------------------------------------------------------------------
# Sync
# -----------------------------------------------------------------------------
CREATED=0; UPDATED=0; SKIPPED=0

for rel in "${AI_GUARD_FILES[@]}"; do
  src="$BASE_DIR/$rel"
  dest="$TARGET_DIR/$rel"

  if [[ ! -f "$src" ]]; then
    warn "Fonte ausente: $rel (pule)"
    continue
  fi

  if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
    verbose "Unchanged: $rel"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  action="create"
  [[ -f "$dest" ]] && action="update"

  if [[ "$DRY_RUN" == true ]]; then
    info "[DRY-RUN] ${action^}: $rel"
    continue
  fi

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"

  if [[ "$action" == "create" ]]; then
    success "Created: $rel"; CREATED=$((CREATED + 1))
  else
    success "Updated: $rel"; UPDATED=$((UPDATED + 1))
  fi
done

# -----------------------------------------------------------------------------
# Resumo
# -----------------------------------------------------------------------------
header "AI-Guard aplicado"

if [[ "$DRY_RUN" == true ]]; then
  echo -e "${YELLOW}Dry run${NC} — rode sem --dry-run para aplicar."
else
  echo -e "${GREEN}Created:${NC} $CREATED"
  echo -e "${BLUE}Updated:${NC} $UPDATED"
  echo -e "${YELLOW}Skipped:${NC} $SKIPPED"
fi

if [[ "$DRY_RUN" == false && ($CREATED -gt 0 || $UPDATED -gt 0) ]]; then
  cat <<EOF

${BOLD}Próximos passos:${NC}

  1. Atualize a tabela Agent Categories em ${BOLD}CLAUDE.md${NC} (e .claude/CLAUDE.md):
     - Adicione linha ${CYAN}AI-Guard${NC} com @performance-auditor, @security-auditor,
       @architecture-reviewer.

  2. Atualize ${BOLD}.agent/Agents/README.md${NC}:
     - Inclua os 3 agents na seção ${CYAN}quality/${NC}.

  3. (Opcional) Integre em ${BOLD}/validate${NC}:
     - Após QA + code-reviewer + arch-validator, rode /audit-report.

  4. Experimente:
     ${CYAN}/audit-report${NC}               # Projetos afetados
     ${CYAN}/audit-report all${NC}           # Codebase completo
     ${CYAN}/audit-report lib:user${NC}      # Apenas um escopo

  5. Commit:
     git add .claude/skills .claude/agents .claude/commands/audit-report.md \\
             .agent/Agents/quality CLAUDE.md .claude/CLAUDE.md
     git commit -m 'feat(ai-guard): add performance/security/architecture auditors'

EOF
fi
