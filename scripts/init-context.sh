#!/usr/bin/env bash

# =============================================================================
# init-context.sh - Initialize AI context in any project
# =============================================================================
#
# Downloads and initializes the AI context structure in the current directory.
# Can be run directly with curl:
#
#   curl -fsSL https://raw.githubusercontent.com/USER/REPO/main/scripts/init-context.sh | bash
#
# Or locally:
#   ./scripts/init-context.sh [target-dir]
#
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Configuration
REPO_URL="https://github.com/halissonbrancalhao/ai-context-base"
BRANCH="main"
TARGET_DIR="${1:-.}"

print_header() {
    echo -e "\n${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}  $1${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_step() {
    echo -e "${CYAN}▸${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    exit 1
}

# =============================================================================
# Main
# =============================================================================

print_header "AI Context Initializer"

# Check if git is available
if ! command -v git &> /dev/null; then
    print_error "git is required but not installed"
fi

# Resolve target directory
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
    print_error "Target directory does not exist: $TARGET_DIR"
}

echo -e "${BOLD}Target:${NC} $TARGET_DIR\n"

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Clone repository (sparse checkout for efficiency)
print_step "Downloading context structure..."

cd "$TEMP_DIR"
git clone --depth 1 --filter=blob:none --sparse "$REPO_URL" base-context 2>/dev/null || {
    # Fallback: try with full clone if sparse not supported
    git clone --depth 1 "$REPO_URL" base-context 2>/dev/null || {
        print_error "Failed to clone repository. Check if the URL is correct and accessible."
    }
}

cd base-context

# Enable sparse checkout for only what we need
git sparse-checkout set .agent .claude .ruler .claudeignore .mcp.json CLAUDE.md scripts 2>/dev/null || true

print_success "Downloaded successfully"

# Run sync script
print_step "Syncing context to target..."

if [[ -f "scripts/sync-context.sh" ]]; then
    chmod +x scripts/sync-context.sh
    ./scripts/sync-context.sh "$TARGET_DIR" --force
else
    # Manual sync if script not available
    print_warning "Sync script not found, doing manual copy..."

    # Copy directories
    for dir in .agent .claude .ruler; do
        if [[ -d "$dir" ]]; then
            cp -r "$dir" "$TARGET_DIR/"
            print_success "Copied $dir/"
        fi
    done

    # Copy files
    for file in .claudeignore .mcp.json CLAUDE.md; do
        if [[ -f "$file" ]]; then
            cp "$file" "$TARGET_DIR/"
            print_success "Copied $file"
        fi
    done
fi

# =============================================================================
# Post-init setup
# =============================================================================

print_header "Setup Complete!"

echo -e "Context structure initialized in: ${BOLD}$TARGET_DIR${NC}\n"

echo -e "${BOLD}Structure created:${NC}"
echo "  .agent/        → AI documentation & agents"
echo "  .claude/       → Commands, hooks, skills, settings"
echo "  .ruler/        → Rules injection"
echo "  .claudeignore  → Context exclusions"
echo "  .mcp.json      → MCP servers config"
echo "  CLAUDE.md      → Main instructions"

echo -e "\n${BOLD}Next steps:${NC}"
echo ""
echo "1. ${CYAN}Configure MCP servers${NC}"
echo "   Edit .mcp.json and add API keys for:"
echo "   - context7 (documentation)"
echo "   - figma (design)"
echo "   - linear (tasks)"
echo ""
echo "2. ${CYAN}Customize for your stack${NC}"
echo "   Edit .agent/README.md:"
echo "   - Update project name"
echo "   - Update stack (Angular/React/Vue, etc.)"
echo "   - Update package manager"
echo ""
echo "3. ${CYAN}Remove irrelevant docs${NC}"
echo "   In .agent/System/, keep only docs for your stack:"
echo "   - Angular project? Keep angular_*.md"
echo "   - React project? Remove angular_*.md, add react docs"
echo ""
echo "4. ${CYAN}Add to git${NC}"
echo "   git add .agent .claude .ruler .claudeignore .mcp.json CLAUDE.md"
echo "   git commit -m 'chore: initialize AI context structure'"
echo ""
echo -e "${GREEN}Ready to use with Claude Code!${NC}"
