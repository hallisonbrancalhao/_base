#!/usr/bin/env bash

# =============================================================================
# Init-Only Mode - CI/Headless Setup
# =============================================================================
# Use: CI pipelines, devcontainers, automated environments
# Behavior: Minimal output, frozen lockfile, preflight checks, exits after setup
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

setup_error_handling
start_timer

# -----------------------------------------------------------------------------
# CI-Specific Configuration
# -----------------------------------------------------------------------------
export CI="${CI:-true}"
export NX_DAEMON="${NX_DAEMON:-false}"
export NX_SKIP_NX_CACHE="${NX_SKIP_NX_CACHE:-false}"

# -----------------------------------------------------------------------------
# Main Init-Only Function
# -----------------------------------------------------------------------------
run_init_only() {
  log_header "CI/Headless Environment Setup"

  ensure_project_root

  echo "→ Environment: $(is_ci && echo 'CI' || echo 'Headless')"
  echo "→ Node: $(get_node_version)"
  echo "→ pnpm: $(get_pnpm_version)"
  echo ""

  # Step 1: Validate CI environment
  validate_ci_environment

  # Step 2: Install dependencies (frozen)
  install_dependencies_frozen

  # Step 3: Prewarm/verify Nx cache
  verify_nx_cache

  # Step 4: Run preflight checks
  run_preflight_checks

  # Step 5: Generate artifacts (if needed)
  generate_artifacts

  # Step 6: Exit with summary
  exit_with_summary
}

# -----------------------------------------------------------------------------
# Step Functions
# -----------------------------------------------------------------------------

validate_ci_environment() {
  echo "→ Validating environment..."

  if ! has_node; then
    echo "ERROR: Node.js not found"
    exit 1
  fi

  if ! has_pnpm; then
    echo "ERROR: pnpm not found"
    exit 1
  fi

  if ! has_lockfile; then
    echo "ERROR: No lockfile found (pnpm-lock.yaml, package-lock.json, etc.)"
    exit 1
  fi

  echo "✓ Environment validated"
}

install_dependencies_frozen() {
  echo "→ Installing dependencies (frozen lockfile)..."

  # Use frozen lockfile for reproducible builds
  if pnpm install --frozen-lockfile; then
    echo "✓ Dependencies installed"
  else
    echo "ERROR: Failed to install dependencies"
    echo "Hint: Run 'pnpm install' locally to update lockfile"
    exit 1
  fi
}

verify_nx_cache() {
  echo "→ Verifying Nx cache..."

  # Check if Nx cache might be corrupted
  if [[ -d ".nx/cache" ]]; then
    # Try a simple Nx command to verify cache integrity
    if ! run_nx report &>/dev/null; then
      echo "⚠ Nx cache appears corrupted, resetting..."
      run_nx reset 2>/dev/null || rm -rf .nx/cache
      echo "✓ Nx cache reset"
    else
      echo "✓ Nx cache verified"
    fi
  else
    echo "✓ No existing cache (first run)"
  fi

  # Set up Nx for CI
  if [[ -z "$NX_BASE" ]]; then
    export NX_BASE="origin/main"
  fi
  if [[ -z "$NX_HEAD" ]]; then
    export NX_HEAD="HEAD"
  fi
}

run_preflight_checks() {
  echo "→ Running preflight checks..."

  local exit_code=0

  # Check if there are affected projects
  local affected
  affected=$(nx_affected_projects)

  if [[ -z "$affected" ]]; then
    echo "✓ No affected projects (skipping checks)"
    return 0
  fi

  echo "  Affected projects: $affected"

  # Lint affected
  echo "  → Linting affected..."
  if run_nx lint --affected --parallel=3; then
    echo "  ✓ Lint passed"
  else
    echo "  ✗ Lint failed"
    exit_code=1
  fi

  # Test affected
  echo "  → Testing affected..."
  if run_nx test --affected --parallel=3 --passWithNoTests; then
    echo "  ✓ Tests passed"
  else
    echo "  ✗ Tests failed"
    exit_code=1
  fi

  # Build affected
  echo "  → Building affected..."
  if run_nx build --affected --parallel=3; then
    echo "  ✓ Build passed"
  else
    echo "  ✗ Build failed"
    exit_code=1
  fi

  if [[ $exit_code -ne 0 ]]; then
    echo "ERROR: Preflight checks failed"
    exit $exit_code
  fi

  echo "✓ All preflight checks passed"
}

generate_artifacts() {
  echo "→ Generating artifacts..."

  # Generate Nx dependency graph (useful for debugging)
  if [[ -n "$CI_ARTIFACTS_DIR" ]] && [[ -d "$CI_ARTIFACTS_DIR" ]]; then
    run_nx graph --file="$CI_ARTIFACTS_DIR/nx-graph.html" 2>/dev/null || true
    echo "  ✓ Nx graph generated"
  fi

  # Export affected list for downstream jobs
  if [[ -n "$GITHUB_OUTPUT" ]]; then
    local affected
    affected=$(nx_affected_projects | tr '\n' ',' | sed 's/,$//')
    echo "affected_projects=$affected" >> "$GITHUB_OUTPUT"
    echo "  ✓ Affected projects exported to GITHUB_OUTPUT"
  fi

  echo "✓ Artifacts generated"
}

exit_with_summary() {
  local elapsed
  elapsed=$(get_elapsed_time)

  echo ""
  echo "════════════════════════════════════════════════════════════"
  echo "  CI Setup Complete"
  echo "════════════════════════════════════════════════════════════"
  echo ""
  echo "✓ Environment ready for CI pipeline"
  echo "  Duration: ${elapsed}"
  echo ""

  exit 0
}

# -----------------------------------------------------------------------------
# Entry Point
# -----------------------------------------------------------------------------
run_init_only "$@"
