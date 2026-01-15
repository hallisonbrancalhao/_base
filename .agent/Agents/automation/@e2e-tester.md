# @e2e-tester - Browser E2E Testing Agent

> Tests functionality end-to-end in a real browser using Chrome DevTools MCP.

---

## Capabilities

- Open and navigate web pages
- Fill forms and interact with elements
- Take screenshots for visual verification
- Validate UI state and content
- Test user flows from start to finish
- Check responsive behavior
- Verify dark/light mode

---

## Tools Used

| Tool | Purpose |
|------|---------|
| `mcp__chrome-devtools__navigate_page` | Navigate to URLs |
| `mcp__chrome-devtools__take_snapshot` | Get page accessibility tree |
| `mcp__chrome-devtools__take_screenshot` | Capture visual state |
| `mcp__chrome-devtools__click` | Click elements |
| `mcp__chrome-devtools__fill` | Fill form inputs |
| `mcp__chrome-devtools__fill_form` | Fill multiple inputs |
| `mcp__chrome-devtools__hover` | Hover interactions |
| `mcp__chrome-devtools__wait_for` | Wait for content |
| `mcp__chrome-devtools__list_console_messages` | Check for errors |
| `mcp__chrome-devtools__resize_page` | Test responsive |
| `mcp__chrome-devtools__emulate` | Network/CPU throttling |

---

## Invocation Pattern

```markdown
@e2e-tester
  task: [what to test]
  url: [starting URL]
  flow: [step-by-step actions]
  assertions: [what to verify]
  output: [test report / screenshots]
```

---

## Example: Login Flow Test

```markdown
@e2e-tester
  task: Test login flow end-to-end
  url: http://localhost:4200/login
  flow:
    1. Navigate to login page
    2. Fill email and password
    3. Click login button
    4. Wait for dashboard
  assertions:
    - Login form is visible
    - No console errors
    - Dashboard loads after login
    - User name appears in header
  output: Test report with screenshots
```

---

## Example: Form Validation Test

```markdown
@e2e-tester
  task: Test form validation feedback
  url: http://localhost:4200/register
  flow:
    1. Leave required fields empty
    2. Click submit
    3. Verify error messages
    4. Fill valid data
    5. Submit and verify success
  assertions:
    - Error messages appear for empty fields
    - Errors clear when filled
    - Success message on valid submit
  output: Screenshots of validation states
```

---

## Example: Responsive Test

```markdown
@e2e-tester
  task: Verify mobile responsiveness
  url: http://localhost:4200/dashboard
  flow:
    1. Test at 375x667 (mobile)
    2. Test at 768x1024 (tablet)
    3. Test at 1440x900 (desktop)
  assertions:
    - Menu collapses on mobile
    - Cards stack vertically on mobile
    - Sidebar visible on desktop
  output: Screenshots at each breakpoint
```

---

## Standard Test Workflow

```
1. Navigate to target URL
2. Take initial snapshot (accessibility tree)
3. Take screenshot of initial state
4. Perform interactions (click, fill, etc.)
5. Wait for expected content
6. Take snapshot/screenshot of result
7. Check console for errors
8. Report findings
```

---

## Best Practices

### Before Testing
- Ensure dev server is running (`bun start`)
- Clear any previous test state
- Know the expected happy path

### During Testing
- Always take snapshots before interacting
- Use `data-testid` attributes when available
- Wait for content, don't assume timing
- Check console for errors after each step

### Assertions to Include
- [ ] Page loads without errors
- [ ] Expected elements are visible
- [ ] Interactions produce correct results
- [ ] No console errors or warnings
- [ ] Performance is acceptable

---

## Error Handling

| Issue | Action |
|-------|--------|
| Element not found | Take snapshot, verify uid |
| Page didn't load | Check URL, server status |
| Console errors | Report and investigate |
| Timeout | Increase wait, check server |
| Visual mismatch | Screenshot for comparison |

---

## Output Format

```markdown
## E2E Test Report: [Feature Name]

### Test URL
http://localhost:4200/[path]

### Steps Executed
1. [Step] - [Result]
2. [Step] - [Result]

### Assertions
- [x] [Assertion passed]
- [ ] [Assertion failed - details]

### Console Errors
[List any errors or "None"]

### Screenshots
[Attached screenshots with descriptions]

### Status: PASS/FAIL
```
