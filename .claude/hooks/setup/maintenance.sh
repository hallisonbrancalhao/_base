#!/usr/bin/env bash

# =============================================================================
# Maintenance Mode - Periodic Upkeep
# =============================================================================
# Use: Weekly maintenance, health checks, dependency updates
# Behavior: Comprehensive checks, generates report, non-interactive
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

setup_error_handling
start_timer

# -----------------------------------------------------------------------------
# Report Variables
# -----------------------------------------------------------------------------
REPORT_FILE=""
ISSUES_FOUND=0
WARNINGS_FOUND=0

# -----------------------------------------------------------------------------
# Main Maintenance Function
# -----------------------------------------------------------------------------
run_maintenance() {
  log_header "Project Maintenance"

  ensure_project_root

  # Setup report file
  REPORT_FILE="maintenance-report-$(date +%Y%m%d-%H%M%S).md"

  print_env_summary

  # Step 1: Update dependencies
  update_dependencies

  # Step 2: Cleanup
  run_cleanup

  # Step 3: Security audit
  run_security_audit

  # Step 4: Format code
  run_formatting

  # Step 5: Full health checks
  run_full_health_checks

  # Step 6: Generate report
  generate_report
}

# -----------------------------------------------------------------------------
# Step Functions
# -----------------------------------------------------------------------------

update_dependencies() {
  log_step "Updating Dependencies"

  if ! has_pnpm; then
    log_error "pnpm is required"
    ((ISSUES_FOUND++))
    return 1
  fi

  log_substep "Checking for updates..."

  # Update dependencies
  if pnpm update 2>&1 | tee -a "$REPORT_FILE.tmp"; then
    log_success "Dependencies updated"

    # Check if lockfile changed
    if git diff --quiet pnpm-lock.yaml 2>/dev/null; then
      log_info "No dependency changes"
    else
      log_warning "Lockfile changed - review and commit"
      ((WARNINGS_FOUND++))
    fi
  else
    log_warning "Some updates may have failed"
    ((WARNINGS_FOUND++))
  fi
}

run_cleanup() {
  log_step "Running Cleanup"

  # Clean Nx cache
  log_substep "Resetting Nx cache..."
  if run_nx reset 2>/dev/null; then
    log_success "Nx cache reset"
  else
    log_info "Nx reset skipped"
  fi

  # Clean node_modules of unused packages
  log_substep "Pruning unused dependencies..."
  if has_pnpm; then
    if pnpm prune; then
      log_success "Dependencies pruned"
    else
      log_warning "Prune command failed, reinstalling..."
      rm -rf node_modules
      if pnpm install; then
        log_success "Dependencies reinstalled (cleaned)"
      else
        log_error "Failed to reinstall dependencies"
        ((ISSUES_FOUND++))
      fi
    fi
  fi

  # Clean build artifacts
  log_substep "Cleaning build artifacts..."
  if [[ -d "dist" ]]; then
    rm -rf dist
    log_success "dist/ cleaned"
  fi

  # Clean temporary files
  log_substep "Cleaning temporary files..."
  find . -name "*.log" -type f -delete 2>/dev/null || true
  find . -name ".DS_Store" -type f -delete 2>/dev/null || true
  log_success "Temporary files cleaned"
}

run_security_audit() {
  log_step "Security Audit"

  local audit_output=""
  local audit_exit=0

  log_substep "Running security audit..."

  # pnpm has native audit support
  if has_pnpm; then
    audit_output=$(pnpm audit --audit-level=moderate 2>&1) || audit_exit=$?
  elif command -v npm &>/dev/null; then
    audit_output=$(npm audit --audit-level=moderate 2>&1) || audit_exit=$?
  else
    log_info "No package manager available for security audit"
    return 0
  fi

  if [[ $audit_exit -eq 0 ]]; then
    log_success "No security vulnerabilities found"
  else
    # Count vulnerabilities
    local high_count
    local critical_count
    high_count=$(echo "$audit_output" | grep -c "high" || echo "0")
    critical_count=$(echo "$audit_output" | grep -c "critical" || echo "0")

    if [[ "$critical_count" -gt 0 ]]; then
      log_error "Found $critical_count critical vulnerabilities"
      ((ISSUES_FOUND++))
    elif [[ "$high_count" -gt 0 ]]; then
      log_warning "Found $high_count high vulnerabilities"
      ((WARNINGS_FOUND++))
    else
      log_warning "Found some vulnerabilities (review recommended)"
      ((WARNINGS_FOUND++))
    fi

    # Save audit output
    echo "$audit_output" >> "$REPORT_FILE.audit"
  fi
}

run_formatting() {
  log_step "Code Formatting"

  log_substep "Formatting codebase..."

  # Run Nx format
  if run_nx format:write 2>/dev/null; then
    log_success "Code formatted"

    # Check if any files changed
    if ! git diff --quiet 2>/dev/null; then
      log_warning "Files were formatted - review and commit"
      ((WARNINGS_FOUND++))

      # List changed files
      local changed_files
      changed_files=$(git diff --name-only 2>/dev/null | head -10)
      if [[ -n "$changed_files" ]]; then
        log_substep "Changed files:"
        echo "$changed_files" | while read -r file; do
          echo "    $file"
        done
      fi
    fi
  else
    log_warning "Formatting command not available or failed"
  fi
}

run_full_health_checks() {
  log_step "Full Health Checks"

  local all_passed=true

  # Lint all projects
  log_substep "Linting all projects..."
  if run_nx run-many -t lint --all --parallel=3 2>&1 | tee -a "$REPORT_FILE.lint"; then
    log_success "All lint checks passed"
  else
    log_error "Lint checks failed"
    ((ISSUES_FOUND++))
    all_passed=false
  fi

  # Test all projects
  log_substep "Testing all projects..."
  if run_nx run-many -t test --all --parallel=3 --passWithNoTests 2>&1 | tee -a "$REPORT_FILE.test"; then
    log_success "All tests passed"
  else
    log_error "Some tests failed"
    ((ISSUES_FOUND++))
    all_passed=false
  fi

  # Build all projects
  log_substep "Building all projects..."
  if run_nx run-many -t build --all --parallel=3 2>&1 | tee -a "$REPORT_FILE.build"; then
    log_success "All builds passed"
  else
    log_error "Some builds failed"
    ((ISSUES_FOUND++))
    all_passed=false
  fi

  # Type check
  log_substep "Running type check..."
  if pnpm tsc --noEmit 2>&1 | tee -a "$REPORT_FILE.tsc"; then
    log_success "Type check passed"
  else
    log_warning "Type errors found"
    ((WARNINGS_FOUND++))
    all_passed=false
  fi

  if $all_passed; then
    log_success "All health checks passed"
  fi
}

generate_report() {
  local elapsed
  elapsed=$(get_elapsed_time)

  log_header "Maintenance Report"

  # Create markdown report
  cat > "$REPORT_FILE" <<EOF
# Maintenance Report

**Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Duration:** ${elapsed}

## Summary

| Metric | Value |
|--------|-------|
| Issues Found | ${ISSUES_FOUND} |
| Warnings | ${WARNINGS_FOUND} |
| Status | $([ $ISSUES_FOUND -eq 0 ] && echo "✅ Healthy" || echo "❌ Needs Attention") |

## Environment

- **OS:** $(uname -s) $(uname -m)
- **Node:** $(get_node_version)
- **pnpm:** $(get_pnpm_version)
- **Nx:** $(get_nx_version)

## Actions Performed

1. ✅ Dependencies updated
2. ✅ Cache cleaned
3. ✅ Security audit completed
4. ✅ Code formatted
5. ✅ Full health checks run

## Recommendations

EOF

  if [[ $ISSUES_FOUND -gt 0 ]]; then
    echo "- ⚠️ Review and fix the ${ISSUES_FOUND} issue(s) found" >> "$REPORT_FILE"
  fi

  if [[ $WARNINGS_FOUND -gt 0 ]]; then
    echo "- 📝 Review the ${WARNINGS_FOUND} warning(s)" >> "$REPORT_FILE"
  fi

  if git diff --quiet 2>/dev/null; then
    echo "- No uncommitted changes" >> "$REPORT_FILE"
  else
    echo "- 📋 Review and commit any formatting/dependency changes" >> "$REPORT_FILE"
  fi

  echo "" >> "$REPORT_FILE"
  echo "---" >> "$REPORT_FILE"
  echo "*Generated by maintenance.sh*" >> "$REPORT_FILE"

  # Cleanup temp files
  rm -f "$REPORT_FILE.tmp" "$REPORT_FILE.audit" "$REPORT_FILE.lint" "$REPORT_FILE.test" "$REPORT_FILE.build" "$REPORT_FILE.tsc" 2>/dev/null

  # Print summary to console
  echo ""
  echo -e "${BOLD}Summary:${NC}"
  echo -e "  Issues:   ${ISSUES_FOUND}"
  echo -e "  Warnings: ${WARNINGS_FOUND}"
  echo -e "  Duration: ${elapsed}"
  echo ""

  if [[ $ISSUES_FOUND -eq 0 ]]; then
    echo -e "${GREEN}✓${NC} Project is healthy"
  else
    echo -e "${RED}✗${NC} Project needs attention (${ISSUES_FOUND} issues)"
  fi

  echo ""
  echo -e "Report saved to: ${BOLD}${REPORT_FILE}${NC}"

  # Exit with appropriate code
  if [[ $ISSUES_FOUND -gt 0 ]]; then
    exit 1
  fi
  exit 0
}

# -----------------------------------------------------------------------------
# Entry Point
# -----------------------------------------------------------------------------
run_maintenance "$@"
