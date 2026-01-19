#!/bin/bash
# Archive Plan Hook
# Archives plans to dated folders after ExitPlanMode
# Triggered by PostToolUse:ExitPlanMode

set -e

PLANS_DIR="${CLAUDE_WORKING_DIRECTORY:-$(pwd)}/.agent/Plans"
ARCHIVE_DIR="$PLANS_DIR/archive"

# Get current date/time for folder naming
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DATE_FOLDER=$(date +"%Y-%m-%d")

# Create archive structure if needed
mkdir -p "$ARCHIVE_DIR/$DATE_FOLDER"

# Find plan files in the plans directory (not in archive)
PLAN_FILES=$(find "$PLANS_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null || echo "")

if [ -z "$PLAN_FILES" ]; then
    echo "INFO: No plan files to archive"
    exit 0
fi

# Archive each plan file
ARCHIVED_COUNT=0
for plan_file in $PLAN_FILES; do
    if [ -f "$plan_file" ]; then
        filename=$(basename "$plan_file" .md)
        archived_name="${filename}_${TIMESTAMP}.md"

        # Copy to archive (preserve original until confirmed)
        cp "$plan_file" "$ARCHIVE_DIR/$DATE_FOLDER/$archived_name"

        # Remove original after successful copy
        rm "$plan_file"

        ARCHIVED_COUNT=$((ARCHIVED_COUNT + 1))
        echo "ARCHIVED: $filename -> archive/$DATE_FOLDER/$archived_name"
    fi
done

if [ $ARCHIVED_COUNT -gt 0 ]; then
    echo ""
    echo "<system-reminder>"
    echo "PLAN ARCHIVED: $ARCHIVED_COUNT plan(s) moved to .agent/Plans/archive/$DATE_FOLDER/"
    echo ""
    echo "To review archived plans:"
    echo "  ls .agent/Plans/archive/$DATE_FOLDER/"
    echo ""
    echo "Context preserved for future reference and continuity."
    echo "</system-reminder>"
fi

exit 0
