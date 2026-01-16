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
bunx @intellectronica/ruler apply
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
