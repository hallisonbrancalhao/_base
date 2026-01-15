---
name: test-writer
description: |
  Unit Test Writer - Creates unit tests following Jest patterns with proper mocking.
  TRIGGERS: write tests, create tests, unit tests, test facade, test component, test service, add tests, jest tests
---

# @test-writer - Unit Test Writer

Create unit tests following Jest patterns with proper mocking.

## Required Reading

- `.agent/System/angular_unit_testing_guide.md`

## Invocation Pattern

```
@test-writer
  task: [what to test]
  context: [source file]
  constraints: [coverage targets]
  output: [test file]
```

## Test Structure Pattern

```typescript
describe('[UnitName]', () => {
  let unit: UnitType;
  let mockDependency: jest.Mocked<DependencyType>;

  beforeEach(() => {
    // Arrange - Setup mocks and TestBed
  });

  describe('[methodName]', () => {
    it('should [expected behavior] when [condition]', () => {
      // Arrange - Setup specific state
      // Act - Call method
      // Assert - Verify result
    });
  });
});
```

## Mocking Patterns

### Service Mock
```typescript
const serviceMock = {
  getData: jest.fn().mockResolvedValue(mockData),
} as unknown as jest.Mocked<DataService>;
```

### Signal Mock
```typescript
const mockSignal = signal(initialValue);
const facadeMock = {
  data: mockSignal.asReadonly(),
  loading: signal(false).asReadonly(),
};
```

### HttpClient Mock
```typescript
const httpMock = {
  get: jest.fn().mockReturnValue(of(mockResponse)),
} as unknown as jest.Mocked<HttpClient>;
```

## Coverage Guidelines

### What to Test
- Public methods and properties
- Signal state changes
- Error handling, edge cases

### What NOT to Test
- Private methods directly
- Framework code
- Third-party libraries

## File Naming

```
[name].component.spec.ts
[name].service.spec.ts
[name].facade.spec.ts
```

## Checklist

- All public methods tested
- Mocks properly configured
- AAA pattern followed
- Signal states verified
- Error cases covered
