---
name: e2e-tester
description: |
  Browser E2E Testing - Tests functionality end-to-end in a real browser using Chrome DevTools MCP.
  TRIGGERS: e2e test, browser test, test in browser, test login flow, test form, visual test, responsive test, test user flow
---

# @e2e-tester - Browser E2E Testing

Test functionality end-to-end in a real browser using Chrome DevTools MCP.

## Tools

| Tool | Purpose |
|------|---------|
| `mcp__chrome-devtools__navigate_page` | Navigate to URLs |
| `mcp__chrome-devtools__take_snapshot` | Get accessibility tree |
| `mcp__chrome-devtools__take_screenshot` | Capture visual state |
| `mcp__chrome-devtools__click` | Click elements |
| `mcp__chrome-devtools__fill` | Fill form inputs |
| `mcp__chrome-devtools__fill_form` | Fill multiple inputs |
| `mcp__chrome-devtools__wait_for` | Wait for content |
| `mcp__chrome-devtools__list_console_messages` | Check errors |
| `mcp__chrome-devtools__resize_page` | Test responsive |

## Invocation Pattern

```
@e2e-tester
  task: [what to test]
  url: [starting URL]
  flow: [step-by-step actions]
  assertions: [what to verify]
```

## Standard Workflow

1. Navigate to target URL
2. Take initial snapshot/screenshot
3. Perform interactions (click, fill)
4. Wait for expected content
5. Take result snapshot/screenshot
6. Check console for errors
7. Report findings

## Best Practices

### Before Testing
- Ensure dev server is running (`bun start`)
- Clear previous test state

### During Testing
- Take snapshots before interacting
- Use `data-testid` when available
- Wait for content, don't assume timing
- Check console after each step

## Output Format

```markdown
## E2E Test Report: [Feature]

### Steps Executed
1. [Step] - [Result]

### Assertions
- [x] Passed
- [ ] Failed - details

### Console Errors
[List or "None"]

### Status: PASS/FAIL
```
