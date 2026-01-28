#!/usr/bin/env bash

# =============================================================================
# sync-context.sh - Sync AI context structure to target project
# =============================================================================
#
# Syncs the complete AI assistant context structure (.agent, .claude, .ruler,
# .mcp.json, .claudeignore, CLAUDE.md) from this base repository to a target
# project.
#
# Usage:
#   ./scripts/sync-context.sh <target-project-path> [options]
#
# Options:
#   --dry-run       Show what would be done without making changes
#   --force         Overwrite all files without prompting
#   --no-mcp        Skip .mcp.json (useful if target has custom MCP config)
#   --no-tasks      Skip .agent/Tasks/ (don't overwrite PRDs)
#   --minimal       Only sync essential files (commands, hooks, base rules)
#   --verbose       Show detailed progress
#   --help          Show this help message
#
# Examples:
#   ./scripts/sync-context.sh ~/projects/my-app
#   ./scripts/sync-context.sh ~/projects/my-app --dry-run
#   ./scripts/sync-context.sh ~/projects/my-app --no-mcp --no-tasks
#
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Script directory (where base context lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Default options
DRY_RUN=false
FORCE=false
NO_MCP=false
NO_TASKS=false
MINIMAL=false
VERBOSE=false
TARGET_DIR=""

# Counters
CREATED=0
UPDATED=0
SKIPPED=0

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
    echo -e "\n${BOLD}${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║${NC}  ${BOLD}$1${NC}"
    echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_section() {
    echo -e "\n${CYAN}▸ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "  ${CYAN}→${NC} $1"
    fi
}

show_help() {
    head -35 "$0" | tail -30
    exit 0
}

# =============================================================================
# Argument Parsing
# =============================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --no-mcp)
            NO_MCP=true
            shift
            ;;
        --no-tasks)
            NO_TASKS=true
            shift
            ;;
        --minimal)
            MINIMAL=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            show_help
            ;;
        -*)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
        *)
            if [[ -z "$TARGET_DIR" ]]; then
                TARGET_DIR="$1"
            else
                print_error "Multiple target directories specified"
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate target directory
if [[ -z "$TARGET_DIR" ]]; then
    print_error "Target directory not specified"
    echo "Usage: $0 <target-project-path> [options]"
    echo "Use --help for more information"
    exit 1
fi

# Resolve to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
    print_error "Target directory does not exist: $TARGET_DIR"
    exit 1
}

# Don't sync to self
if [[ "$TARGET_DIR" == "$BASE_DIR" ]]; then
    print_error "Cannot sync to the same directory"
    exit 1
fi

# =============================================================================
# Sync Functions
# =============================================================================

sync_file() {
    local src="$1"
    local relative_path="${src#$BASE_DIR/}"
    local dest="$TARGET_DIR/$relative_path"
    local dest_dir="$(dirname "$dest")"

    # Skip based on options
    if [[ "$NO_MCP" == true && "$relative_path" == ".mcp.json" ]]; then
        print_verbose "Skipping .mcp.json (--no-mcp)"
        SKIPPED=$((SKIPPED + 1))
        return
    fi

    if [[ "$NO_TASKS" == true && "$relative_path" == .agent/Tasks/* && "$relative_path" != ".agent/Tasks/README.md" ]]; then
        print_verbose "Skipping $relative_path (--no-tasks)"
        SKIPPED=$((SKIPPED + 1))
        return
    fi

    # Skip .DS_Store and other system files
    if [[ "$(basename "$src")" == ".DS_Store" ]]; then
        return
    fi

    # Skip settings.local.json (user-specific)
    if [[ "$relative_path" == ".claude/settings.local.json" ]]; then
        print_verbose "Skipping settings.local.json (user-specific)"
        SKIPPED=$((SKIPPED + 1))
        return
    fi

    # Minimal mode - only essential files
    if [[ "$MINIMAL" == true ]]; then
        local essential_patterns=(
            ".claude/commands/*"
            ".claude/hooks/*"
            ".claude/settings.json"
            ".claudeignore"
            "CLAUDE.md"
            ".ruler/*"
            ".agent/README.md"
            ".agent/System/base_rules.md"
            ".agent/System/README.md"
            ".agent/Agents/README.md"
        )

        local is_essential=false
        for pattern in "${essential_patterns[@]}"; do
            if [[ "$relative_path" == $pattern ]]; then
                is_essential=true
                break
            fi
        done

        if [[ "$is_essential" == false ]]; then
            print_verbose "Skipping $relative_path (--minimal)"
            SKIPPED=$((SKIPPED + 1))
            return
        fi
    fi

    # Check if file exists at destination
    local action=""
    if [[ -f "$dest" ]]; then
        # Compare files
        if cmp -s "$src" "$dest"; then
            print_verbose "Unchanged: $relative_path"
            SKIPPED=$((SKIPPED + 1))
            return
        fi
        action="update"
    else
        action="create"
    fi

    # Dry run mode
    if [[ "$DRY_RUN" == true ]]; then
        if [[ "$action" == "create" ]]; then
            print_info "[DRY-RUN] Would create: $relative_path"
        else
            print_info "[DRY-RUN] Would update: $relative_path"
        fi
        return
    fi

    # Create directory if needed
    if [[ ! -d "$dest_dir" ]]; then
        mkdir -p "$dest_dir"
        print_verbose "Created directory: ${dest_dir#$TARGET_DIR/}"
    fi

    # Copy file
    cp "$src" "$dest"

    if [[ "$action" == "create" ]]; then
        print_success "Created: $relative_path"
        CREATED=$((CREATED + 1))
    else
        print_success "Updated: $relative_path"
        UPDATED=$((UPDATED + 1))
    fi
}

sync_directory() {
    local src_dir="$1"
    local dir_name="$(basename "$src_dir")"

    print_section "Syncing $dir_name/"

    while IFS= read -r -d '' file; do
        sync_file "$file"
    done < <(find "$src_dir" -type f -print0)
}

# =============================================================================
# Main Execution
# =============================================================================

print_header "AI Context Sync Tool"

echo -e "${BOLD}Source:${NC}  $BASE_DIR"
echo -e "${BOLD}Target:${NC}  $TARGET_DIR"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    print_warning "DRY RUN MODE - No changes will be made"
fi

if [[ "$MINIMAL" == true ]]; then
    print_info "Minimal mode - only essential files"
fi

# Sync each context component
print_section "Syncing root files"
[[ -f "$BASE_DIR/.claudeignore" ]] && sync_file "$BASE_DIR/.claudeignore"
[[ -f "$BASE_DIR/.mcp.json" ]] && sync_file "$BASE_DIR/.mcp.json"
[[ -f "$BASE_DIR/CLAUDE.md" ]] && sync_file "$BASE_DIR/CLAUDE.md"

# Sync .ruler
if [[ -d "$BASE_DIR/.ruler" ]]; then
    sync_directory "$BASE_DIR/.ruler"
fi

# Sync .claude
if [[ -d "$BASE_DIR/.claude" ]]; then
    sync_directory "$BASE_DIR/.claude"
fi

# Sync .agent
if [[ -d "$BASE_DIR/.agent" ]]; then
    sync_directory "$BASE_DIR/.agent"
fi

# =============================================================================
# Summary
# =============================================================================

print_header "Sync Complete"

if [[ "$DRY_RUN" == true ]]; then
    echo -e "This was a ${YELLOW}dry run${NC}. No files were modified."
    echo -e "Run without --dry-run to apply changes."
else
    echo -e "${GREEN}Created:${NC} $CREATED files"
    echo -e "${BLUE}Updated:${NC} $UPDATED files"
    echo -e "${YELLOW}Skipped:${NC} $SKIPPED files (unchanged or excluded)"
fi

echo ""

# Post-sync instructions
if [[ "$DRY_RUN" == false && ($CREATED -gt 0 || $UPDATED -gt 0) ]]; then
    print_section "Next Steps"
    echo ""
    echo "1. Review synced files:"
    echo "   cd $TARGET_DIR"
    echo "   git status"
    echo ""
    echo "2. Update project-specific settings:"
    echo "   - .mcp.json: Add/remove MCPs for your stack"
    echo "   - .agent/README.md: Update project name and stack"
    echo "   - .agent/System/: Keep only relevant docs for your framework"
    echo ""
    echo "3. Commit the changes:"
    echo "   git add .agent .claude .ruler .claudeignore .mcp.json CLAUDE.md"
    echo "   git commit -m 'chore: sync AI context structure from base'"
    echo ""
fi
