## 1.0.0

- Initial version.

## 1.0.1

### Added
* New unified `execute<T>()` method for all GraphQL operations
* New unified `executeList<T>()` method for list operations
* `OperationType` enum to specify query, mutation, or subscription

### Improved
* Reduced code duplication
* Better consistency across operations

### Breaking Changes
* `query<T>()` method - use `execute<T>()` with `OperationType.query`
* `mutate<T>()` method - use `execute<T>()` with `OperationType.mutation`
* `queryList<T>()` method - use `executeList<T>()` with `OperationType.query`
* `mutateList<T>()` method - use `executeList<T>()` with `OperationType.mutation`

### Migration Guide
```dart
// Before (still works but deprecated)
final user = await client.query<User>(...);

// After (recommended)
final user = await client.execute<User>(
  operation: getUserQuery,
  operationType: OperationType.query,
  variables: {'id': '123'},
  modelParser: (json) => User.fromJson(json),
);