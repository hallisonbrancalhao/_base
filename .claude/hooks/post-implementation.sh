#!/bin/bash
# Post-Implementation Hook
# Runs lint, test, and build validation after code changes

set -e

echo "🔍 Post-Implementation Validation"
echo "=================================="

# Get changed files from git
CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || echo "")

if [ -z "$CHANGED_FILES" ]; then
    echo "ℹ️  No changes detected, skipping validation."
    exit 0
fi

echo "📁 Changed files:"
echo "$CHANGED_FILES" | head -10
echo ""

# Run lint on affected projects
echo "🔧 Running lint..."
if npx nx affected:lint --base=HEAD~1 2>/dev/null; then
    echo "✅ Lint passed"
else
    echo "❌ Lint failed"
    LINT_FAILED=1
fi

# Run tests on affected projects
echo ""
echo "🧪 Running tests..."
if npx nx affected:test --base=HEAD~1 2>/dev/null; then
    echo "✅ Tests passed"
else
    echo "❌ Tests failed"
    TEST_FAILED=1
fi

# Run build on affected projects
echo ""
echo "🏗️  Running build..."
if npx nx affected:build --base=HEAD~1 2>/dev/null; then
    echo "✅ Build passed"
else
    echo "❌ Build failed"
    BUILD_FAILED=1
fi

echo ""
echo "=================================="

# Summary
if [ -n "$LINT_FAILED" ] || [ -n "$TEST_FAILED" ] || [ -n "$BUILD_FAILED" ]; then
    echo "⚠️  Some validations failed. Please review."
    exit 1
else
    echo "✅ All validations passed!"
    exit 0
fi
