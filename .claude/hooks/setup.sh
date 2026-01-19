#!/usr/bin/env bash

# =============================================================================
# Unified Setup Script
# =============================================================================
# One script, three modes:
#   --init        : Interactive development setup (default)
#   --init-only   : CI/Headless setup (exits after completion)
#   --maintenance : Periodic upkeep (weekly chores)
#
# Usage:
#   ./setup.sh              # Auto-detect mode (init or init-only)
#   ./setup.sh --init       # Interactive setup
#   ./setup.sh --init-only  # CI/Headless setup
#   ./setup.sh --maintenance # Periodic maintenance
#   ./setup.sh --help       # Show help
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$SCRIPT_DIR/setup"

# -----------------------------------------------------------------------------
# Mode Detection
# -----------------------------------------------------------------------------
detect_mode() {
  # Check for explicit flags first
  for arg in "$@"; do
    case "$arg" in
      --init)
        echo "init"
        return
        ;;
      --init-only)
        echo "init-only"
        return
        ;;
      --maintenance)
        echo "maintenance"
        return
        ;;
      --help|-h)
        echo "help"
        return
        ;;
    esac
  done

  # Auto-detect based on environment
  if [[ -n "${CI:-}" ]] || [[ -n "${GITHUB_ACTIONS:-}" ]] || [[ -n "${GITLAB_CI:-}" ]]; then
    echo "init-only"
  elif [[ -n "${REMOTE_CONTAINERS:-}" ]] || [[ -n "${CODESPACES:-}" ]] || [[ -f "/.dockerenv" ]]; then
    echo "init-only"
  elif [[ ! -t 0 ]]; then
    # Non-interactive terminal
    echo "init-only"
  else
    echo "init"
  fi
}

# -----------------------------------------------------------------------------
# Help
# -----------------------------------------------------------------------------
show_help() {
  cat <<EOF
Unified Setup Script

Usage: setup.sh [MODE] [OPTIONS]

Modes:
  --init          Interactive development setup (default for local dev)
                  - Installs dependencies
                  - Validates environment
                  - Sets up .env files
                  - Starts Docker services
                  - Runs sanity checks

  --init-only     CI/Headless setup (default for CI environments)
                  - Frozen lockfile install
                  - Nx cache verification
                  - Preflight checks (lint, test, build affected)
                  - Exits after setup

  --maintenance   Periodic maintenance (run weekly)
                  - Updates dependencies
                  - Cleans caches and artifacts
                  - Security audit
                  - Formats code
                  - Full health checks
                  - Generates report

Options:
  -h, --help      Show this help message

Environment Detection:
  The script auto-detects the appropriate mode if not specified:
  - CI environment (CI=true, GITHUB_ACTIONS, etc.) → --init-only
  - Devcontainer/Codespaces → --init-only
  - Non-interactive terminal → --init-only
  - Otherwise → --init

Examples:
  ./setup.sh                    # Auto-detect mode
  ./setup.sh --init             # Force interactive mode
  ./setup.sh --init-only        # Force CI mode
  ./setup.sh --maintenance      # Run maintenance

Make targets:
  make init       # Run --init mode
  make ci         # Run --init-only mode
  make maintain   # Run --maintenance mode

EOF
}

# -----------------------------------------------------------------------------
# Validation
# -----------------------------------------------------------------------------
validate_setup_dir() {
  if [[ ! -d "$SETUP_DIR" ]]; then
    echo "ERROR: Setup directory not found: $SETUP_DIR" >&2
    exit 1
  fi
}

validate_script() {
  local script="$1"
  if [[ ! -f "$script" ]]; then
    echo "ERROR: Script not found: $script" >&2
    exit 1
  fi
  if [[ ! -x "$script" ]]; then
    echo "INFO: Making script executable: $script"
    chmod +x "$script"
  fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
  local mode
  mode=$(detect_mode "$@")

  case "$mode" in
    init)
      validate_setup_dir
      validate_script "$SETUP_DIR/init.sh"
      exec "$SETUP_DIR/init.sh" "$@"
      ;;
    init-only)
      validate_setup_dir
      validate_script "$SETUP_DIR/init-only.sh"
      exec "$SETUP_DIR/init-only.sh" "$@"
      ;;
    maintenance)
      validate_setup_dir
      validate_script "$SETUP_DIR/maintenance.sh"
      exec "$SETUP_DIR/maintenance.sh" "$@"
      ;;
    help)
      show_help
      exit 0
      ;;
    *)
      echo "ERROR: Unknown mode: $mode" >&2
      show_help
      exit 1
      ;;
  esac
}

main "$@"
