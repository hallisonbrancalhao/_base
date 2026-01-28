# E2E Testing Workflow

Run end-to-end tests using Chrome DevTools MCP.

## Arguments

`$ARGUMENTS` - Feature, flow, or page to test

## Prerequisites

- Chrome DevTools MCP configured in `.mcp.json`
- Application running locally

## Workflow

### Phase 1: Setup

1. **Start the application** (if not running):
   ```bash
   # Start in background
   pnpm nx serve web &
   pnpm nx serve api &

   # Wait for servers
   sleep 10
   ```

2. **Verify services**:
   ```bash
   curl -s http://localhost:4200 > /dev/null && echo "Frontend OK"
   curl -s http://localhost:3000/api/health > /dev/null && echo "API OK"
   ```

### Phase 2: Browser Setup

Use Chrome DevTools MCP tools:

1. **Open new page**:
   ```
   mcp__chrome-devtools__new_page
   url: "http://localhost:4200"
   ```

2. **Take initial screenshot**:
   ```
   mcp__chrome-devtools__take_screenshot
   ```

3. **Set viewport** (if testing responsive):
   ```
   mcp__chrome-devtools__resize_page
   width: 375  # Mobile
   height: 812
   ```

### Phase 3: Execute Test Flow

For: `$ARGUMENTS`

1. **Navigate to target page**:
   ```
   mcp__chrome-devtools__navigate_page
   url: "http://localhost:4200/[route]"
   ```

2. **Wait for content**:
   ```
   mcp__chrome-devtools__wait_for
   selector: "[data-testid='page-loaded']"
   timeout: 5000
   ```

3. **Interact with elements**:
   ```
   # Fill input
   mcp__chrome-devtools__fill
   selector: "[data-testid='email-input']"
   value: "test@example.com"

   # Click button
   mcp__chrome-devtools__click
   selector: "[data-testid='submit-btn']"
   ```

4. **Take screenshot after each step**:
   ```
   mcp__chrome-devtools__take_screenshot
   ```

### Phase 4: Validation

1. **Check console for errors**:
   ```
   mcp__chrome-devtools__list_console_messages
   ```

2. **Verify network requests**:
   ```
   mcp__chrome-devtools__list_network_requests
   ```

3. **Validate expected state**:
   ```
   mcp__chrome-devtools__take_snapshot
   # Check for expected elements in DOM
   ```

### Phase 5: Cleanup

1. **Close browser page**:
   ```
   mcp__chrome-devtools__close_page
   ```

2. **Stop servers** (if started by this workflow):
   ```bash
   # Kill background processes
   pkill -f "nx serve"
   ```

## Common Test Scenarios

### Login Flow
```
1. Navigate to /login
2. Fill email input
3. Fill password input
4. Click submit button
5. Wait for redirect to /dashboard
6. Verify dashboard loaded
```

### Form Submission
```
1. Navigate to form page
2. Fill all required fields
3. Click submit
4. Wait for success message
5. Verify data persisted (check list/detail page)
```

### Error Handling
```
1. Navigate to page
2. Trigger error condition (invalid input, network failure)
3. Verify error message displayed
4. Verify form still usable
```

### Responsive Testing
```
1. Set viewport to mobile (375x812)
2. Verify mobile layout
3. Set viewport to tablet (768x1024)
4. Verify tablet layout
5. Set viewport to desktop (1920x1080)
6. Verify desktop layout
```

## Output Format

After testing, provide:

1. **Test Summary**: Pass/Fail status
2. **Steps Executed**: List of actions taken
3. **Screenshots**: Key state screenshots
4. **Console Errors**: Any errors found
5. **Network Issues**: Failed requests
6. **Recommendations**: Suggested fixes if failures found

## Tips

- Always use `data-testid` selectors (more stable than CSS classes)
- Take screenshots before and after key actions
- Check console after each navigation
- Test both happy path and error scenarios
- Test on multiple viewports for responsive features
