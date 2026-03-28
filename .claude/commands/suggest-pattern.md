# /suggest-pattern - Design Pattern Advisor

Get design pattern recommendations for a specific problem or feature.

## Usage

```
/suggest-pattern [description of what needs to be built]
```

## Examples

```
/suggest-pattern new CRUD feature for managing invoices
/suggest-pattern authentication flow with multiple providers
/suggest-pattern complex form with nested sub-forms and dynamic validation
/suggest-pattern swappable data source (MongoDB in prod, in-memory for tests)
/suggest-pattern real-time notifications with WebSocket
```

## Steps

### 1. Analyze Problem

Parse $ARGUMENTS to understand what needs to be built.

### 2. Recommend Patterns

```
@pattern-advisor
  problem: [parsed description]
  context: [current project architecture from libs/ structure]
  constraints: [project conventions from .agent/System/]
```

### 3. Output

Provide:
- Recommended primary and supporting patterns
- Code skeletons using project conventions
- Anti-patterns to avoid
- References to architecture knowledge base documents
