#!/bin/bash

# Pre-implementation hook: Checks if user prompt indicates implementation intent
# Returns system reminder to read architecture rules before implementing
# Also checks for active plans and suggests review before implementation

USER_PROMPT="$CLAUDE_USER_CONTENT"
PLANS_DIR="${CLAUDE_WORKING_DIRECTORY:-$(pwd)}/.agent/Plans"

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

        # Check for active plans
        PLAN_FILES=$(find "$PLANS_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null || echo "")
        if [ -n "$PLAN_FILES" ]; then
            echo "ACTIVE PLAN DETECTED"
            echo "===================="
            echo "Found plan file(s) in .claude/plans/"
            echo ""
            echo "RECOMMENDED: Before implementing, use subagents to review the plan:"
            echo ""
            echo "Option 1 - Quick Review (inline):"
            echo "  Use Task tool with @arch-validator and @code-reviewer agents"
            echo "  to analyze the plan for architecture compliance."
            echo ""
            echo "Option 2 - Full Review (headless):"
            echo "  Run: .claude/hooks/plan-review.sh"
            echo "  Reviews are saved in .claude/plans/reviews/"
            echo ""
            echo "Plan files found:"
            echo "$PLAN_FILES" | while read -r f; do echo "  - $(basename "$f")"; done
            echo ""
            echo "===================="
            echo ""
        fi

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
