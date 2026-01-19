# =============================================================================
# Project Makefile
# =============================================================================
# Developer shortcuts for common operations
# =============================================================================

.PHONY: help init ci maintain setup dev test lint build clean format audit graph

# Default target
.DEFAULT_GOAL := help

# Setup script location
SETUP_SCRIPT := .claude/hooks/setup.sh

# =============================================================================
# Help
# =============================================================================

help: ## Show this help
	@echo ""
	@echo "Available targets:"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf ""} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""

# =============================================================================
# Setup Modes
# =============================================================================

init: ## Interactive development setup (start working)
	@$(SETUP_SCRIPT) --init

ci: ## CI/Headless setup (frozen install, preflight checks)
	@$(SETUP_SCRIPT) --init-only

maintain: ## Periodic maintenance (update, audit, full checks)
	@$(SETUP_SCRIPT) --maintenance

setup: init ## Alias for 'init'

# =============================================================================
# Development
# =============================================================================

dev: ## Start development servers (api + web)
	@pnpm nx run-many -t serve -p api,web --parallel

dev-api: ## Start API server only
	@pnpm nx serve api

dev-web: ## Start Web server only
	@pnpm nx serve web

# =============================================================================
# Quality
# =============================================================================

test: ## Run tests (affected)
	@pnpm nx test --affected

test-all: ## Run all tests
	@pnpm nx run-many -t test --all

lint: ## Run lint (affected)
	@pnpm nx lint --affected

lint-all: ## Run lint on all projects
	@pnpm nx run-many -t lint --all

lint-fix: ## Run lint with auto-fix
	@pnpm nx lint --affected --fix

typecheck: ## Run TypeScript type check
	@pnpm tsc --noEmit

# =============================================================================
# Build
# =============================================================================

build: ## Build affected projects
	@pnpm nx build --affected

build-all: ## Build all projects
	@pnpm nx run-many -t build --all

build-api: ## Build API
	@pnpm nx build api

build-web: ## Build Web
	@pnpm nx build web

# =============================================================================
# Utilities
# =============================================================================

clean: ## Clean build artifacts and caches
	@rm -rf dist .nx/cache
	@echo "✓ Cleaned dist/ and .nx/cache"

clean-all: ## Clean everything (including node_modules)
	@rm -rf dist .nx node_modules
	@echo "✓ Cleaned dist/, .nx/, and node_modules/"

format: ## Format code
	@pnpm nx format:write

format-check: ## Check code formatting
	@pnpm nx format:check

audit: ## Run security audit
	@npm audit --audit-level=moderate || true

graph: ## Open Nx dependency graph
	@pnpm nx graph

reset: ## Reset Nx cache
	@pnpm nx reset

# =============================================================================
# Git
# =============================================================================

status: ## Show git status and affected projects
	@echo "=== Git Status ==="
	@git status --short
	@echo ""
	@echo "=== Affected Projects ==="
	@pnpm nx show projects --affected 2>/dev/null || echo "None"

# =============================================================================
# Docker (if available)
# =============================================================================

docker-up: ## Start Docker services
	@docker compose up -d 2>/dev/null || docker-compose up -d 2>/dev/null || echo "No docker-compose file found"

docker-down: ## Stop Docker services
	@docker compose down 2>/dev/null || docker-compose down 2>/dev/null || echo "No docker-compose file found"

docker-logs: ## Show Docker logs
	@docker compose logs -f 2>/dev/null || docker-compose logs -f 2>/dev/null || echo "No docker-compose file found"

# =============================================================================
# Install
# =============================================================================

install: ## Install dependencies
	@pnpm install

install-frozen: ## Install dependencies (frozen lockfile)
	@pnpm install --frozen-lockfile

update: ## Update dependencies
	@pnpm update
