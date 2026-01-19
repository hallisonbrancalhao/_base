#!/usr/bin/env bash

# =============================================================================
# Common Utilities for Setup Scripts
# =============================================================================
# Shared functions for colors, logging, environment detection, and utilities.
# Source this file in other setup scripts.
# =============================================================================

# -----------------------------------------------------------------------------
# Colors & Formatting
# -----------------------------------------------------------------------------
if [[ -t 1 ]] && [[ -z "$NO_COLOR" ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  MAGENTA='\033[0;35m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  DIM='\033[2m'
  NC='\033[0m'
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  MAGENTA=''
  CYAN=''
  BOLD=''
  DIM=''
  NC=''
fi

# -----------------------------------------------------------------------------
# Logging Functions
# -----------------------------------------------------------------------------
log_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
  echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
  echo -e "${RED}✗${NC} $1" >&2
}

log_step() {
  echo -e "\n${BOLD}${CYAN}▶${NC} ${BOLD}$1${NC}"
}

log_substep() {
  echo -e "  ${DIM}→${NC} $1"
}

log_header() {
  echo -e "\n${BOLD}${MAGENTA}════════════════════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${MAGENTA}  $1${NC}"
  echo -e "${BOLD}${MAGENTA}════════════════════════════════════════════════════════════${NC}\n"
}

log_section() {
  echo -e "\n${BOLD}────────────────────────────────────────${NC}"
  echo -e "${BOLD}  $1${NC}"
  echo -e "${BOLD}────────────────────────────────────────${NC}"
}

# Verbose logging (only in non-CI environments)
log_verbose() {
  if ! is_ci; then
    echo -e "${DIM}$1${NC}"
  fi
}

# -----------------------------------------------------------------------------
# Environment Detection
# -----------------------------------------------------------------------------
is_ci() {
  [[ -n "$CI" ]] || [[ -n "$GITHUB_ACTIONS" ]] || [[ -n "$GITLAB_CI" ]] || [[ -n "$JENKINS_URL" ]] || [[ -n "$CIRCLECI" ]]
}

is_devcontainer() {
  [[ -n "$REMOTE_CONTAINERS" ]] || [[ -n "$CODESPACES" ]] || [[ -f "/.dockerenv" ]] || [[ -n "$DEVCONTAINER" ]]
}

is_headless() {
  is_ci || is_devcontainer || [[ ! -t 0 ]]
}

has_docker() {
  command -v docker &>/dev/null && docker info &>/dev/null 2>&1
}

has_docker_compose() {
  command -v docker-compose &>/dev/null || docker compose version &>/dev/null 2>&1
}

has_pnpm() {
  command -v pnpm &>/dev/null
}

has_node() {
  command -v node &>/dev/null
}

has_nx() {
  command -v nx &>/dev/null || [[ -f "./node_modules/.bin/nx" ]]
}

# -----------------------------------------------------------------------------
# Version Checks
# -----------------------------------------------------------------------------
get_node_version() {
  if has_node; then
    node --version | sed 's/v//'
  else
    echo "not installed"
  fi
}

get_pnpm_version() {
  if has_pnpm; then
    pnpm --version
  else
    echo "not installed"
  fi
}

get_nx_version() {
  if [[ -f "package.json" ]]; then
    grep -o '"nx": "[^"]*"' package.json 2>/dev/null | cut -d'"' -f4 || echo "not found"
  else
    echo "not found"
  fi
}

check_node_version() {
  local required_major="${1:-20}"
  local current_version
  current_version=$(get_node_version)
  local current_major
  current_major=$(echo "$current_version" | cut -d'.' -f1)

  if [[ "$current_major" -ge "$required_major" ]]; then
    return 0
  else
    return 1
  fi
}

check_pnpm_version() {
  local required_major="${1:-8}"
  local current_version
  current_version=$(get_pnpm_version)
  local current_major
  current_major=$(echo "$current_version" | cut -d'.' -f1)

  if [[ "$current_major" -ge "$required_major" ]]; then
    return 0
  else
    return 1
  fi
}

# -----------------------------------------------------------------------------
# Project Utilities
# -----------------------------------------------------------------------------
get_project_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/nx.json" ]] || [[ -f "$dir/package.json" ]]; then
      echo "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  echo "$PWD"
}

ensure_project_root() {
  local root
  root=$(get_project_root)
  if [[ "$PWD" != "$root" ]]; then
    cd "$root" || exit 1
  fi
}

# Check if lockfile exists
has_lockfile() {
  [[ -f "pnpm-lock.yaml" ]] || [[ -f "package-lock.json" ]] || [[ -f "yarn.lock" ]] || [[ -f "bun.lockb" ]]
}

# Check if node_modules exists
has_node_modules() {
  [[ -d "node_modules" ]]
}

# Check if .env file exists
has_env_file() {
  [[ -f ".env" ]]
}

# Check if .env.example exists
has_env_example() {
  [[ -f ".env.example" ]]
}

# -----------------------------------------------------------------------------
# Nx Utilities
# -----------------------------------------------------------------------------
run_nx() {
  if [[ -f "./node_modules/.bin/nx" ]]; then
    ./node_modules/.bin/nx "$@"
  elif command -v nx &>/dev/null; then
    nx "$@"
  elif has_pnpm; then
    pnpm nx "$@"
  else
    log_error "Nx not found. Run 'pnpm install' first."
    return 1
  fi
}

nx_affected_projects() {
  run_nx show projects --affected 2>/dev/null || echo ""
}

nx_has_affected() {
  local affected
  affected=$(nx_affected_projects)
  [[ -n "$affected" ]]
}

# -----------------------------------------------------------------------------
# Process Utilities
# -----------------------------------------------------------------------------
run_with_spinner() {
  local msg="$1"
  shift
  local cmd="$*"

  if is_ci; then
    echo "→ $msg"
    eval "$cmd"
    return $?
  fi

  local pid
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0

  eval "$cmd" &
  pid=$!

  while kill -0 "$pid" 2>/dev/null; do
    printf "\r${CYAN}%s${NC} %s" "${spin:i++%10:1}" "$msg"
    sleep 0.1
  done

  wait "$pid"
  local exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    printf "\r${GREEN}✓${NC} %s\n" "$msg"
  else
    printf "\r${RED}✗${NC} %s\n" "$msg"
  fi

  return $exit_code
}

# -----------------------------------------------------------------------------
# Summary & Reporting
# -----------------------------------------------------------------------------
print_env_summary() {
  log_section "Environment Summary"
  echo -e "  ${DIM}OS:${NC}          $(uname -s) $(uname -m)"
  echo -e "  ${DIM}Node:${NC}        $(get_node_version)"
  echo -e "  ${DIM}pnpm:${NC}        $(get_pnpm_version)"
  echo -e "  ${DIM}Nx:${NC}          $(get_nx_version)"
  echo -e "  ${DIM}Docker:${NC}      $(has_docker && echo 'available' || echo 'not available')"
  echo -e "  ${DIM}CI:${NC}          $(is_ci && echo 'yes' || echo 'no')"
  echo -e "  ${DIM}Devcontainer:${NC} $(is_devcontainer && echo 'yes' || echo 'no')"
}

# Track execution time
START_TIME=""

start_timer() {
  START_TIME=$(date +%s)
}

get_elapsed_time() {
  if [[ -n "$START_TIME" ]]; then
    local end_time
    end_time=$(date +%s)
    local elapsed=$((end_time - START_TIME))
    echo "${elapsed}s"
  else
    echo "unknown"
  fi
}

# -----------------------------------------------------------------------------
# Error Handling
# -----------------------------------------------------------------------------
setup_error_handling() {
  set -euo pipefail
  trap 'log_error "Script failed at line $LINENO. Exit code: $?"' ERR
}

# Cleanup function (can be extended by sourcing scripts)
cleanup() {
  :
}

trap cleanup EXIT
