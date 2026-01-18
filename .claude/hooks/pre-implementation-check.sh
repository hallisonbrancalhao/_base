#!/bin/bash

# Pre-implementation hook: Checks if user prompt indicates implementation intent
# Returns system reminder to read architecture rules before implementing

USER_PROMPT="$CLAUDE_USER_CONTENT"

# Implementation patterns (case insensitive)
IMPLEMENTATION_PATTERNS=(
    "implement"
    "create"
    "add feature"
    "add component"
    "add service"
    "add lib"
    "build"
    "develop"
    "code"
    "write"
    "fazer"
    "criar"
    "implementar"
    "adicionar"
    "desenvolver"
    "gerar"
    "nx g"
    "nx generate"
    "refactor"
    "refatorar"
)

# Check if prompt matches implementation patterns
PROMPT_LOWER=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')

for pattern in "${IMPLEMENTATION_PATTERNS[@]}"; do
    if [[ "$PROMPT_LOWER" == *"$pattern"* ]]; then
        echo "<system-reminder>"
        echo "IMPLEMENTATION DETECTED - PRE-IMPLEMENTATION CHECKLIST:"
        echo ""
        echo "Before implementing, you MUST read and follow these architecture files:"
        echo ""
        echo "1. .agent/System/base_rules.md (Core rules)"
        echo "2. .agent/System/barrel_best_practices.md (Import patterns)"
        echo "3. .agent/System/libs_architecture_pattern.md (Lib structure)"
        echo "4. .agent/System/interface-dto-architecture.md (DTO conventions)"
        echo ""
        echo "Key reminders:"
        echo "- Use direct imports, NOT barrel imports"
        echo "- Follow Facade Pattern for state management"
        echo "- Components must be presentational (dumb)"
        echo "- Respect dependency matrix (Domain -> Util only, etc.)"
        echo "- Use proper tags in project.json"
        echo ""
        echo "Read the files above BEFORE writing any code."
        echo "</system-reminder>"
        exit 0
    fi
done

exit 0
