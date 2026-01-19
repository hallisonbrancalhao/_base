#!/usr/bin/env bash

# =============================================================================
# Init Mode - Interactive Development Setup
# =============================================================================
# Use: Developer starting a work session
# Behavior: Verbose output, starts services, interactive prompts if needed
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

setup_error_handling
start_timer

# -----------------------------------------------------------------------------
# Main Init Function
# -----------------------------------------------------------------------------
run_init() {
  log_header "Development Environment Setup"

  ensure_project_root
  print_env_summary

  # Step 1: Validate environment
  validate_environment

  # Step 2: Install dependencies
  install_dependencies

  # Step 3: Setup environment variables
  setup_env_file

  # Step 4: Start services (if Docker available)
  start_services

  # Step 5: Run sanity checks
  run_sanity_checks

  # Step 6: Display status summary
  display_summary
}

# -----------------------------------------------------------------------------
# Step Functions
# -----------------------------------------------------------------------------

validate_environment() {
  log_step "Validating Environment"

  local has_errors=false

  # Check Node.js
  if has_node; then
    if check_node_version 20; then
      log_success "Node.js $(get_node_version) installed"
    else
      log_warning "Node.js $(get_node_version) detected (v20+ recommended)"
    fi
  else
    log_error "Node.js not found"
    has_errors=true
  fi

  # Check pnpm
  if has_pnpm; then
    if check_pnpm_version 8; then
      log_success "pnpm $(get_pnpm_version) installed"
    else
      log_warning "pnpm $(get_pnpm_version) detected (v8+ recommended)"
    fi
  else
    log_error "pnpm not found. Install with: npm install -g pnpm"
    has_errors=true
  fi

  # Check Docker (optional)
  if has_docker; then
    log_success "Docker available"
  else
    log_info "Docker not available (optional)"
  fi

  if $has_errors; then
    log_error "Environment validation failed. Please install missing dependencies."
    exit 1
  fi
}

install_dependencies() {
  log_step "Installing Dependencies"

  if ! has_pnpm; then
    log_error "pnpm is required but not installed"
    exit 1
  fi

  if has_node_modules && has_lockfile; then
    log_substep "Checking dependencies..."
    log_substep "Installing/updating dependencies..."
    if pnpm install; then
      log_success "Dependencies installed"
    else
      log_error "Failed to install dependencies"
      exit 1
    fi
  else
    log_substep "Installing dependencies..."
    if pnpm install; then
      log_success "Dependencies installed"
    else
      log_error "Failed to install dependencies"
      exit 1
    fi
  fi
}

setup_env_file() {
  log_step "Environment Variables"

  if has_env_file; then
    log_success ".env file exists"
    return 0
  fi

  if has_env_example; then
    log_substep "Creating .env from .env.example..."
    cp .env.example .env
    log_success ".env file created from .env.example"
    log_warning "Review and update .env with your local configuration"
  else
    log_info "No .env.example found (skipping .env setup)"
  fi
}

start_services() {
  log_step "Starting Services"

  if ! has_docker; then
    log_info "Docker not available, skipping service startup"
    return 0
  fi

  # Check for docker-compose files
  local compose_file=""
  if [[ -f "docker-compose.yml" ]]; then
    compose_file="docker-compose.yml"
  elif [[ -f "docker-compose.yaml" ]]; then
    compose_file="docker-compose.yaml"
  elif [[ -f "compose.yml" ]]; then
    compose_file="compose.yml"
  elif [[ -f "compose.yaml" ]]; then
    compose_file="compose.yaml"
  fi

  if [[ -z "$compose_file" ]]; then
    log_info "No docker-compose file found (skipping)"
    return 0
  fi

  log_substep "Starting Docker services from $compose_file..."

  if has_docker_compose; then
    if docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null; then
      log_success "Docker services started"
    else
      log_warning "Failed to start Docker services"
    fi
  else
    log_warning "docker-compose not available"
  fi
}

run_sanity_checks() {
  log_step "Running Sanity Checks"

  local checks_passed=true

  # Check if there are affected projects
  if nx_has_affected; then
    log_substep "Checking affected projects..."

    # Lint affected
    log_substep "Linting affected projects..."
    if run_nx lint --affected 2>/dev/null; then
      log_success "Lint passed"
    else
      log_warning "Lint issues found (non-blocking)"
      checks_passed=false
    fi

    # Typecheck (via build with skipTsOutput or just tsc)
    log_substep "Type checking..."
    if run_nx run-many -t typecheck --affected 2>/dev/null || \
       pnpm tsc --noEmit 2>/dev/null; then
      log_success "Type check passed"
    else
      log_warning "Type errors found (non-blocking)"
      checks_passed=false
    fi
  else
    log_info "No affected projects detected"
  fi

  if $checks_passed; then
    log_success "All sanity checks passed"
  else
    log_warning "Some checks had issues (review recommended)"
  fi
}

display_summary() {
  local elapsed
  elapsed=$(get_elapsed_time)

  log_header "Setup Complete"

  echo -e "${GREEN}✓${NC} Environment is ready for development"
  echo ""
  echo -e "${BOLD}Quick Commands:${NC}"
  echo -e "  ${DIM}Start API:${NC}     pnpm nx serve api"
  echo -e "  ${DIM}Start Web:${NC}     pnpm nx serve web"
  echo -e "  ${DIM}Run Tests:${NC}     pnpm nx test --affected"
  echo -e "  ${DIM}Run Lint:${NC}      pnpm nx lint --affected"
  echo -e "  ${DIM}Build All:${NC}     pnpm nx build --all"
  echo ""
  echo -e "${DIM}Setup completed in ${elapsed}${NC}"
}

# -----------------------------------------------------------------------------
# Entry Point
# -----------------------------------------------------------------------------
run_init "$@"
