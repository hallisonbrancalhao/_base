#!/bin/bash
# Plan to PRD Converter Hook
# Converts approved plans to PRD format following .agent/Tasks/README.md template
# Triggered by PostToolUse:ExitPlanMode (before archive-plan.sh)

set -e

PLANS_DIR="${CLAUDE_WORKING_DIRECTORY:-$(pwd)}/.agent/Plans"
TASKS_DIR="${CLAUDE_WORKING_DIRECTORY:-$(pwd)}/.agent/Tasks"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DATE_ID=$(date +"%Y-%m")
PRD_COUNTER_FILE="$TASKS_DIR/.prd_counter"

# Get next PRD number for the month
get_next_prd_number() {
    local current_month=$(date +"%Y-%m")

    if [ -f "$PRD_COUNTER_FILE" ]; then
        local stored_month=$(head -1 "$PRD_COUNTER_FILE" 2>/dev/null || echo "")
        local stored_count=$(tail -1 "$PRD_COUNTER_FILE" 2>/dev/null || echo "0")

        if [ "$stored_month" = "$current_month" ]; then
            echo $((stored_count + 1))
            return
        fi
    fi

    # New month or no counter - start at 1
    echo "1"
}

# Update PRD counter
update_prd_counter() {
    local number=$1
    local current_month=$(date +"%Y-%m")
    echo -e "$current_month\n$number" > "$PRD_COUNTER_FILE"
}

# Extract feature name from plan content
extract_feature_name() {
    local content="$1"

    # Try to find a title/feature name in various formats
    local name=""

    # Look for "# Feature: name" or "# name"
    name=$(echo "$content" | grep -m1 "^#" | sed 's/^#\+\s*//' | sed 's/Feature:\s*//' | head -1)

    # If empty, try to find "feature:" or "name:" in YAML-like format
    if [ -z "$name" ]; then
        name=$(echo "$content" | grep -iE "^(feature|name):" | head -1 | sed 's/^[^:]*:\s*//')
    fi

    # Clean up the name for filename
    if [ -n "$name" ]; then
        echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_-' | head -c 50
    else
        echo "unnamed_feature"
    fi
}

# Extract scope from plan content
extract_scope() {
    local content="$1"

    # Look for scope mentions
    local scope=""
    scope=$(echo "$content" | grep -ioE "scope:\s*[a-z]+" | head -1 | sed 's/scope:\s*//i')

    if [ -z "$scope" ]; then
        scope=$(echo "$content" | grep -ioE "libs/([a-z]+)/" | head -1 | sed 's|libs/||' | sed 's|/||')
    fi

    echo "${scope:-shared}"
}

# Extract complexity estimation
extract_complexity() {
    local content="$1"
    local word_count=$(echo "$content" | wc -w | tr -d ' ')
    local file_mentions=$(echo "$content" | grep -coE "\.(ts|html|css|spec)" || echo "0")

    if [ "$file_mentions" -gt 10 ] || [ "$word_count" -gt 1000 ]; then
        echo "XL"
    elif [ "$file_mentions" -gt 5 ] || [ "$word_count" -gt 500 ]; then
        echo "L"
    elif [ "$file_mentions" -gt 2 ] || [ "$word_count" -gt 200 ]; then
        echo "M"
    else
        echo "S"
    fi
}

# Generate PRD from plan
generate_prd() {
    local plan_file="$1"
    local plan_content=$(cat "$plan_file")
    local plan_filename=$(basename "$plan_file" .md)

    local feature_name=$(extract_feature_name "$plan_content")
    local scope=$(extract_scope "$plan_content")
    local complexity=$(extract_complexity "$plan_content")
    local prd_number=$(get_next_prd_number)
    local prd_number_padded=$(printf "%03d" $prd_number)
    local prd_id="PRD-${DATE_ID}-${prd_number_padded}"
    local prd_filename="${prd_id}_${feature_name}.md"
    local prd_path="$TASKS_DIR/$prd_filename"

    # Update counter
    update_prd_counter "$prd_number"

    cat > "$prd_path" << 'PRDEOF'
# [FEATURE_NAME] - PRD

**ID**: [PRD_ID]
**Status**: :construction: In Development
**Priority**: P2 (Medium)
**Created**: [CREATED_DATE]
**Updated**: [CREATED_DATE]
**Owner**: @developer
**Source Plan**: [PLAN_FILENAME]

---

## AI Context Block

```yaml
# ============================================
# FEATURE IDENTIFICATION
# ============================================
feature:
  name: "[FEATURE_NAME_SLUG]"
  type: feature
  scope: [SCOPE]
  complexity: [COMPLEXITY]
  estimated_hours: [HOURS]

# ============================================
# NX MONOREPO IMPACT ANALYSIS
# ============================================
nx_impact:
  apps_affected:
    - name: "web"
      path: "apps/web"
      changes:
        - type: routes
          files: ["src/app/app.routes.ts"]

  libs_affected: []

  libs_to_create: []

# ============================================
# CODE PATTERNS TO FOLLOW
# ============================================
code_patterns:
  angular:
    components: standalone
    control_flow: "@if/@for"
    signals: true
    inputs: "input()"
    outputs: "output()"
    inject: "inject()"

  primeng:
    use_components: true
    avoid_directives: true
    templates: "#name"

  styling:
    framework: "tailwind"
    theme: "primeng-surface"
    dark_mode: "dark: prefix"

  testing:
    framework: "jest"
    selectors: "data-testid"
    coverage_target: 80
```

---

## Executive Summary

**One-liner**: [EXTRACT_FROM_PLAN]

**Business Context**:
This feature was planned and approved through the Claude Code plan mode workflow.

**Success Criteria**:
- [ ] Feature implemented following architecture rules
- [ ] Unit tests with >80% coverage
- [ ] All lint/test/build passing

---

## Original Plan Content

<details>
<summary>Click to expand original plan</summary>

```markdown
[PLAN_CONTENT]
```

</details>

---

## Functional Requirements

### FR-01: Main Feature

| Attribute | Value |
|-----------|-------|
| **Priority** | Must Have |
| **Complexity** | [COMPLEXITY] |
| **Scope** | [SCOPE] |

**Technical Implementation Notes**:
See original plan content above.

---

## Test Plan

### Unit Tests (Jest)

| Target | Test Cases | Priority | Coverage Target |
|--------|-----------|----------|-----------------|
| Components | render states, user interactions | Must | 80% |
| Facades | state management, methods | Must | 90% |
| Services | HTTP calls, transformations | Must | 85% |

---

## Definition of Done

### Code Quality
- [ ] All code follows `.agent/System/` guidelines
- [ ] Standalone components (NO NgModules)
- [ ] Signals used for state
- [ ] `@if`/`@for` used (NO `*ngIf`/`*ngFor`)
- [ ] PrimeNG components used (NO directives)
- [ ] Methods have max 5 instructions

### Testing
- [ ] Unit test coverage > 80%
- [ ] All tests pass: `nx affected:test --base=main`
- [ ] No lint errors: `nx affected:lint --base=main`

### Deployment
- [ ] Builds successfully: `nx affected:build --base=main`

---

## Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | [CREATED_DATE] | @developer | Generated from plan |
PRDEOF

    # Replace placeholders
    local created_date=$(date +"%Y-%m-%d")
    local hours_estimate=$( [ "$complexity" = "S" ] && echo "4" || ( [ "$complexity" = "M" ] && echo "8" || ( [ "$complexity" = "L" ] && echo "16" || echo "32" ) ) )

    # Use sed to replace placeholders (macOS compatible)
    sed -i '' "s|\[FEATURE_NAME\]|${feature_name}|g" "$prd_path"
    sed -i '' "s|\[FEATURE_NAME_SLUG\]|${feature_name}|g" "$prd_path"
    sed -i '' "s|\[PRD_ID\]|${prd_id}|g" "$prd_path"
    sed -i '' "s|\[CREATED_DATE\]|${created_date}|g" "$prd_path"
    sed -i '' "s|\[PLAN_FILENAME\]|${plan_filename}|g" "$prd_path"
    sed -i '' "s|\[SCOPE\]|${scope}|g" "$prd_path"
    sed -i '' "s|\[COMPLEXITY\]|${complexity}|g" "$prd_path"
    sed -i '' "s|\[HOURS\]|${hours_estimate}|g" "$prd_path"

    # Insert plan content (escape special characters for sed)
    local escaped_content=$(echo "$plan_content" | sed 's/[&/\]/\\&/g' | tr '\n' '\r')
    sed -i '' "s|\[PLAN_CONTENT\]|${escaped_content}|g" "$prd_path"
    sed -i '' 's/\r/\n/g' "$prd_path"

    # Extract one-liner from first paragraph or title
    local one_liner=$(echo "$plan_content" | grep -m1 -v "^#" | grep -v "^$" | head -c 100)
    sed -i '' "s|\[EXTRACT_FROM_PLAN\]|${one_liner}...|g" "$prd_path"

    echo "$prd_path"
}

# Main execution
echo ""
echo "PLAN TO PRD CONVERTER"
echo "====================="

# Find active plan files
PLAN_FILES=$(find "$PLANS_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | grep -v "README" || echo "")

if [ -z "$PLAN_FILES" ]; then
    echo "INFO: No plan files to convert to PRD"
    exit 0
fi

# Ensure Tasks directory exists
mkdir -p "$TASKS_DIR"

# Convert each plan
CONVERTED_COUNT=0
for plan_file in $PLAN_FILES; do
    if [ -f "$plan_file" ]; then
        echo ""
        echo "Converting: $(basename "$plan_file")"

        prd_path=$(generate_prd "$plan_file")

        if [ -f "$prd_path" ]; then
            CONVERTED_COUNT=$((CONVERTED_COUNT + 1))
            echo "Generated PRD: $(basename "$prd_path")"
        fi
    fi
done

if [ $CONVERTED_COUNT -gt 0 ]; then
    echo ""
    echo "<system-reminder>"
    echo "PRD GENERATED: $CONVERTED_COUNT PRD(s) created in .agent/Tasks/"
    echo ""
    echo "Next steps:"
    echo "1. Review the generated PRD(s)"
    echo "2. Fill in missing details (API contracts, specific files)"
    echo "3. Update nx_impact section with actual libs to create/modify"
    echo "4. Begin implementation following the PRD"
    echo ""
    echo "PRD files are ready for implementation tracking."
    echo "</system-reminder>"
fi

exit 0
