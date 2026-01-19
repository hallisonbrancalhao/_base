# Project Base

## Quick Start

```bash
# Start development session (interactive)
make init

# Or run directly
.claude/hooks/setup.sh --init
```

---

## Setup System

The project uses a unified setup script with three modes:

| Mode | Command | Use Case |
|------|---------|----------|
| **Init** | `make init` | Developer starting work session |
| **CI** | `make ci` | CI pipelines, devcontainers |
| **Maintenance** | `make maintain` | Weekly upkeep, health checks |

### Init Mode (`--init`)

Interactive setup for developers:

```bash
make init
# or: .claude/hooks/setup.sh --init
```

- Validates environment (Node, pnpm versions)
- Installs dependencies (`pnpm install`)
- Creates `.env` from `.env.example` (if needed)
- Starts Docker services (if available)
- Runs sanity checks (lint, typecheck affected)
- Displays quick commands summary

### CI Mode (`--init-only`)

Headless setup for automated environments:

```bash
make ci
# or: .claude/hooks/setup.sh --init-only
```

- Auto-detected in CI environments (GitHub Actions, GitLab CI, etc.)
- Frozen lockfile install (`pnpm install --frozen-lockfile`)
- Nx cache verification
- Preflight checks (lint, test, build affected)
- Exits with status code

### Maintenance Mode (`--maintenance`)

Periodic upkeep tasks:

```bash
make maintain
# or: .claude/hooks/setup.sh --maintenance
```

- Updates dependencies (`pnpm update`)
- Cleans caches and artifacts
- Security audit
- Formats code (`nx format:write`)
- Full health checks (lint all, test all, build all)
- Generates maintenance report

### Auto-Detection

Running without flags auto-detects the mode:

```bash
.claude/hooks/setup.sh  # Auto-detects based on environment
```

| Environment | Mode |
|-------------|------|
| CI (GitHub Actions, GitLab CI, etc.) | `--init-only` |
| Devcontainer/Codespaces | `--init-only` |
| Non-interactive terminal | `--init-only` |
| Local interactive | `--init` |

---

## Makefile Commands

```bash
make help  # Show all available commands
```

### Setup
| Command | Description |
|---------|-------------|
| `make init` | Interactive development setup |
| `make ci` | CI/Headless setup |
| `make maintain` | Periodic maintenance |

### Development
| Command | Description |
|---------|-------------|
| `make dev` | Start API + Web servers |
| `make dev-api` | Start API only |
| `make dev-web` | Start Web only |

### Quality
| Command | Description |
|---------|-------------|
| `make test` | Run tests (affected) |
| `make lint` | Run lint (affected) |
| `make typecheck` | TypeScript type check |
| `make format` | Format code |

### Build
| Command | Description |
|---------|-------------|
| `make build` | Build affected projects |
| `make build-all` | Build all projects |

### Utilities
| Command | Description |
|---------|-------------|
| `make clean` | Clean dist/ and cache |
| `make graph` | Open Nx dependency graph |
| `make status` | Git status + affected projects |

---

## Extras

`.claude/settings.local.json`

```json
{
  "enabledPlugins": {
    "frontend-design@claude-plugins-official": true,
    "feature-dev@claude-plugins-official": true,
  }
}
```

## Setup CLAUDE.md and AGENTS.mc

```bash
pnpm dlx @intellectronica/ruler apply
```

## Install extras libs

```bash
# MCPL - MCP Launchpad (https://github.com/kenneth-liao/mcp-launchpad/)

# Using curl (most common)
	curl -LsSf https://astral.sh/uv/install.sh | sh

# Using MACOS
  brew install uv

# Install MCPL
  uv tool install https://github.com/kenneth-liao/mcp-launchpad.git
```
--- 

Uses .env.example as base for .env file

```bash
cp .env.example .env
``` 

Then edit the .env file to add your environment variables.

### Config your mcpl settings

```bash 
mcpl config
```
### Refresh your mcpl list

```bash
mcpl list --refresh
```

(Credit: @kenneth-liao)

