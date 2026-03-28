#!/usr/bin/env bash

# =============================================================================
# Update Mode - Sync _base configuration to existing projects
# =============================================================================
# Use: Update existing projects with latest _base AI context and configuration
# Behavior: Detects _base source, syncs new/changed files, shows summary
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

setup_error_handling
start_timer

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
BASE_DIR=""
TARGET_DIR=""
DRY_RUN=false
FORCE=false
NO_MCP=false
NO_TASKS=false
VERBOSE=false

# Counters
CREATED=0
UPDATED=0
SKIPPED=0
ERRORS=0

# Known _base locations (searched in order)
KNOWN_BASE_PATHS=(
  "$HOME/Development/_base"
  "$HOME/Projects/_base"
  "$HOME/dev/_base"
)

# Directories and files to sync
SYNC_DIRS=(
  ".claude/agents"
  ".claude/commands"
  ".claude/hooks"
  ".claude/skills"
  ".agent/SOPs"
  ".agent/Tasks"
  ".agent/System"
  ".agent/Agents"
  ".ruler"
)

SYNC_ROOT_FILES=(
  "CLAUDE.md"
  ".claudeignore"
)

# Files to never overwrite (project-specific)
SKIP_FILES=(
  ".claude/settings.local.json"
  ".agent/Tasks/README.md"
)

# -----------------------------------------------------------------------------
# Argument Parsing
# -----------------------------------------------------------------------------
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --base)
        BASE_DIR="$2"
        shift 2
        ;;
      --target)
        TARGET_DIR="$2"
        shift 2
        ;;
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
      --verbose)
        VERBOSE=true
        shift
        ;;
      *)
        shift
        ;;
    esac
  done
}

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------
verbose() {
  if [[ "$VERBOSE" == true ]]; then
    log_substep "$1"
  fi
}

find_base_dir() {
  if [[ -n "$BASE_DIR" && -d "$BASE_DIR" ]]; then
    return 0
  fi

  for path in "${KNOWN_BASE_PATHS[@]}"; do
    if [[ -d "$path/.claude" && -d "$path/.agent" ]]; then
      BASE_DIR="$path"
      return 0
    fi
  done

  return 1
}

resolve_target_dir() {
  if [[ -n "$TARGET_DIR" ]]; then
    TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
      log_error "Target directory does not exist: $TARGET_DIR"
      exit 1
    }
    return 0
  fi

  local root
  root=$(get_project_root)
  TARGET_DIR="$root"
}

is_skip_file() {
  local rel_path="$1"
  for skip in "${SKIP_FILES[@]}"; do
    if [[ "$rel_path" == "$skip" ]]; then
      return 0
    fi
  done
  return 1
}

should_skip_by_options() {
  local rel_path="$1"

  if [[ "$NO_MCP" == true && "$rel_path" == ".mcp.json" ]]; then
    return 0
  fi

  if [[ "$NO_TASKS" == true && "$rel_path" == .agent/Tasks/* ]]; then
    if [[ "$rel_path" != .agent/Tasks/TEMPLATE_* && "$rel_path" != ".agent/Tasks/README.md" ]]; then
      return 0
    fi
  fi

  return 1
}

# -----------------------------------------------------------------------------
# Sync Functions
# -----------------------------------------------------------------------------
sync_single_file() {
  local src="$1"
  local rel_path="$2"
  local dest="$TARGET_DIR/$rel_path"
  local dest_dir
  dest_dir="$(dirname "$dest")"

  # Skip system files
  if [[ "$(basename "$src")" == ".DS_Store" ]]; then
    return 0
  fi

  # Skip protected files
  if is_skip_file "$rel_path"; then
    verbose "Skipped (protected): $rel_path"
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi

  # Skip by options
  if should_skip_by_options "$rel_path"; then
    verbose "Skipped (option): $rel_path"
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi

  # Determine action
  local action=""
  if [[ -f "$dest" ]]; then
    if cmp -s "$src" "$dest"; then
      verbose "Unchanged: $rel_path"
      SKIPPED=$((SKIPPED + 1))
      return 0
    fi
    action="update"
  else
    action="create"
  fi

  # Dry run
  if [[ "$DRY_RUN" == true ]]; then
    if [[ "$action" == "create" ]]; then
      log_info "[DRY-RUN] Would create: $rel_path"
    else
      log_info "[DRY-RUN] Would update: $rel_path"
    fi
    return 0
  fi

  # Create directory
  if [[ ! -d "$dest_dir" ]]; then
    mkdir -p "$dest_dir"
    verbose "Created directory: ${dest_dir#$TARGET_DIR/}"
  fi

  # Copy file
  if cp "$src" "$dest"; then
    if [[ "$action" == "create" ]]; then
      log_success "Created: $rel_path"
      CREATED=$((CREATED + 1))
    else
      log_success "Updated: $rel_path"
      UPDATED=$((UPDATED + 1))
    fi
  else
    log_error "Failed to copy: $rel_path"
    ERRORS=$((ERRORS + 1))
  fi
}

sync_directory() {
  local dir_name="$1"
  local src_dir="$BASE_DIR/$dir_name"

  if [[ ! -d "$src_dir" ]]; then
    verbose "Source directory not found: $dir_name"
    return 0
  fi

  log_substep "Syncing $dir_name/"

  while IFS= read -r -d '' file; do
    local rel_path="${file#$BASE_DIR/}"
    sync_single_file "$file" "$rel_path"
  done < <(find "$src_dir" -type f -print0 2>/dev/null)
}

sync_root_file() {
  local filename="$1"
  local src="$BASE_DIR/$filename"

  if [[ ! -f "$src" ]]; then
    verbose "Source file not found: $filename"
    return 0
  fi

  sync_single_file "$src" "$filename"
}

sync_settings_json() {
  local src="$BASE_DIR/.claude/settings.json"
  local dest="$TARGET_DIR/.claude/settings.json"

  if [[ ! -f "$src" ]]; then
    return 0
  fi

  if [[ ! -f "$dest" ]]; then
    sync_single_file "$src" ".claude/settings.json"
    return 0
  fi

  if cmp -s "$src" "$dest"; then
    verbose "Unchanged: .claude/settings.json"
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi

  if [[ "$FORCE" == true ]]; then
    sync_single_file "$src" ".claude/settings.json"
    return 0
  fi

  log_warning "settings.json differs - merging requires manual review"
  log_substep "Source: $src"
  log_substep "Target: $dest"

  if [[ "$DRY_RUN" == false ]]; then
    local backup="$dest.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$dest" "$backup"
    cp "$src" "$dest"
    log_success "Updated: .claude/settings.json (backup: $(basename "$backup"))"
    UPDATED=$((UPDATED + 1))
  else
    log_info "[DRY-RUN] Would update: .claude/settings.json (with backup)"
  fi
}

# -----------------------------------------------------------------------------
# Main Update Function
# -----------------------------------------------------------------------------
run_update() {
  parse_args "$@"

  log_header "Update Project Configuration"

  # Resolve target
  resolve_target_dir

  # Find _base
  if ! find_base_dir; then
    log_error "Could not find _base directory."
    log_info "Provide it with: setup.sh --update --base /path/to/_base"
    log_info "Searched:"
    for path in "${KNOWN_BASE_PATHS[@]}"; do
      log_substep "$path"
    done
    exit 1
  fi

  # Don't sync to self
  if [[ "$TARGET_DIR" == "$BASE_DIR" ]]; then
    log_error "Cannot update _base from itself"
    exit 1
  fi

  log_section "Configuration"
  echo -e "  ${DIM}Source (_base):${NC} $BASE_DIR"
  echo -e "  ${DIM}Target:${NC}        $TARGET_DIR"
  echo -e "  ${DIM}Dry run:${NC}       $DRY_RUN"
  echo -e "  ${DIM}Force:${NC}         $FORCE"
  echo ""

  if [[ "$DRY_RUN" == true ]]; then
    log_warning "DRY RUN MODE - No changes will be made"
    echo ""
  fi

  # Step 1: Sync root files
  log_step "Root Files"
  for file in "${SYNC_ROOT_FILES[@]}"; do
    sync_root_file "$file"
  done

  # Step 2: Sync .mcp.json separately (optional skip)
  if [[ "$NO_MCP" != true && -f "$BASE_DIR/.mcp.json" ]]; then
    sync_root_file ".mcp.json"
  fi

  # Step 3: Sync settings.json with merge awareness
  log_step "Settings"
  sync_settings_json

  # Step 4: Sync directories
  log_step "Directories"
  for dir in "${SYNC_DIRS[@]}"; do
    sync_directory "$dir"
  done

  # Summary
  display_update_summary
}

display_update_summary() {
  local elapsed
  elapsed=$(get_elapsed_time)

  log_header "Update Complete"

  if [[ "$DRY_RUN" == true ]]; then
    echo -e "  This was a ${YELLOW}dry run${NC}. No files were modified."
    echo -e "  Run without --dry-run to apply changes."
  else
    echo -e "  ${GREEN}Created:${NC}  $CREATED files"
    echo -e "  ${BLUE}Updated:${NC}  $UPDATED files"
    echo -e "  ${YELLOW}Skipped:${NC}  $SKIPPED files (unchanged or excluded)"
    if [[ $ERRORS -gt 0 ]]; then
      echo -e "  ${RED}Errors:${NC}   $ERRORS files"
    fi
  fi

  echo ""
  echo -e "  ${DIM}Duration: ${elapsed}${NC}"

  if [[ "$DRY_RUN" == false && ($CREATED -gt 0 || $UPDATED -gt 0) ]]; then
    echo ""
    log_section "Next Steps"
    echo ""
    echo "  1. Review changes:"
    echo "     cd $TARGET_DIR && git diff"
    echo ""
    echo "  2. Verify project-specific settings:"
    echo "     - .claude/settings.json (hooks, permissions)"
    echo "     - .mcp.json (MCP server configuration)"
    echo ""
    echo "  3. Commit:"
    echo "     git add .claude .agent .ruler CLAUDE.md .claudeignore"
    echo "     git commit -m 'chore: sync AI context from _base'"
    echo ""
  fi

  if [[ $ERRORS -gt 0 ]]; then
    exit 1
  fi
}

# -----------------------------------------------------------------------------
# Entry Point
# -----------------------------------------------------------------------------
run_update "$@"
