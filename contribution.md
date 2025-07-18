# CONTRIBUTING.md

# Contributing to GraphQL Infrastructure Tool

We welcome contributions to the GraphQL Infrastructure Tool! This document provides guidelines for contributing to the project.

## Code of Conduct

By participating in this project, you are expected to uphold our code of conduct:

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Respect different viewpoints and experiences

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, please include:

- **Clear description** of the issue
- **Steps to reproduce** the behavior
- **Expected behavior** vs actual behavior
- **Environment details** (Flutter version, Dart version, platform)
- **Code snippets** or minimal reproduction case

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **Clear description** of the enhancement
- **Use case** or problem it solves
- **Proposed solution** if you have one
- **Alternative solutions** you've considered

### Pull Requests

1. **Fork** the repository
2. **Create a feature branch** from `main`
3. **Make your changes** following our coding standards
4. **Add tests** for new functionality
5. **Update documentation** as needed
6. **Run tests** to ensure everything works
7. **Submit a pull request**

## Development Setup

1. **Clone the repository**:
```bash
git clone https://github.com/your-username/graphql_infra_tool.git
cd graphql_infra_tool
```

2. **Install dependencies**:
```bash
flutter pub get
```

3. **Run tests**:
```bash
flutter test
```

4. **Run static analysis**:
```bash
flutter analyze
```

## Coding Standards

### Code Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart)
- Use `dart format` to format code
- Use meaningful variable and function names
- Keep functions focused and small

### Documentation

- Document all public APIs with doc comments
- Include examples in documentation
- Update README.md for significant changes
- Add entries to CHANGELOG.md

### Testing

- Write unit tests for all new functionality
- Maintain test coverage above 80%
- Include integration tests for complex features
- Test edge cases and error conditions

### Commit Messages

Use conventional commit format:
```
type(scope): description

body (optional)

footer (optional)
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Examples:
```
feat(auth): add support for custom auth headers
fix(client): handle null response data gracefully
docs(readme): update installation instructions
```

## Architecture Guidelines

### File Organization

```
lib/
├── config/           # Configuration classes
├── exceptions/       # Error handling
├── result/          # Result wrapper classes
├── service/         # Core GraphQL client
└── graphql_infra_tool.dart  # Main export file
```

### Design Principles

1. **Separation of Concerns**: Each module has a single responsibility
2. **Dependency Injection**: Use dependency injection for testability
3. **Error Handling**: Comprehensive error handling throughout
4. **Type Safety**: Leverage Dart's type system for safety
5. **Performance**: Optimize for performance and memory usage

## Review Process

1. **Automated checks** must pass (tests, linting, formatting)
2. **Code review** by at least one maintainer
3. **Documentation** review for public API changes
4. **Integration testing** for significant changes

## Release Process

1. **Version bump** following semantic versioning
2. **Update CHANGELOG.md** with changes
3. **Tag release** in Git
4. **Publish to pub.dev**
5. **Update documentation** if needed

## Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Documentation**: Check README.md and API docs

## Recognition

Contributors will be recognized in:
- CHANGELOG.md for their contributions
- README.md contributors section
- GitHub repository contributors list

Thank you for contributing to GraphQL Infrastructure Tool!

---

# API_REFERENCE.md

# GraphQL Infrastructure Tool API Reference

Complete API reference for the GraphQL Infrastructure Tool package.

## Table of Contents

- [GQLConfig](#gqlconfig)
- [GQLClient](#gqlclient)
- [GQLAuthProvider](#gqlauthprovider)
- [GQLExceptionProvider](#gqlexceptionprovider)
- [GQLResult](#gqlresult)
- [GQLResultWrapper](#gqlresultwrapper)
- [GQLException](#gqlexception)
- [AppErrorModel](#apperrormodel)

## GQLConfig

Main configuration class for the GraphQL client.

### Constructor

```dart
GQLConfig({
  required String baseURL,
  TokenCallback? bearerToken,
  List<GQLAuthProvider>? authProviders,
  List<GQLExceptionProvider>? exceptionProviders,
  Map<String, String>? defaultHeaders,
  Store? cacheStore,
  FetchPolicy? queryPolicy,
  FetchPolicy? watchQueryPolicy,
  FetchPolicy? mutationPolicy,
  FetchPolicy? watchMutationPolicy,
  FetchPolicy? subscribePolicy,
  List<String>? responseNodePaths,
})
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `baseURL` | `String` | **Required.** The GraphQL endpoint URL |
| `bearerToken` | `TokenCallback?` | Function to retrieve bearer token |
| `authProviders` | `List<GQLAuthProvider>?` | List of authentication providers |
| `exceptionProviders` | `List<GQLExceptionProvider>?` | List of exception providers |
| `defaultHeaders` | `Map<String, String>?` | Default headers for requests |
| `cacheStore` | `Store?` | GraphQL cache store |
| `queryPolicy` | `FetchPolicy?` | Default fetch policy for queries |
| `watchQueryPolicy` | `FetchPolicy?` | Default fetch policy for watch queries |
| `mutationPolicy` | `FetchPolicy?` | Default fetch policy for mutations |
| `watchMutationPolicy` | `FetchPolicy?` | Default fetch policy for watch mutations |
| `subscribePolicy` | `FetchPolicy?` | Default fetch policy for subscriptions |
| `responseNodePaths` | `List<String>?` | Paths to extract data from responses |

### Example

```dart
final config = GQLConfig(
  baseURL: 'https://api.example.com/graphql',
  authProviders: [BearerTokenProvider('token')],
  exceptionProviders: [HttpExceptionProvider()],
  queryPolicy: FetchPolicy.cacheFirst,
  mutationPolicy: FetchPolicy.networkOnly,
  responseNodePaths: ['data', 'result.data'],
);
```

## GQLClient

Main GraphQL client for executing operations.

### Constructor

```dart
GQLClient(GQLConfig config, {bool enableLogging = true})
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `gqlConfig` | `GQLConfig` | Configuration used by the client |
| `gqlClient` | `GraphQLClient` | Underlying GraphQL client |
| `enableLogging` | `bool` | Whether to enable request/response logging |

### Methods

#### query<T>

Execute a GraphQL query.

```dart
Future<T> query<T>({
  required String query,
  Map<String, dynamic>? variable,
  FetchPolicy? fetchPolicy,
  required T Function(dynamic json) modelParser,
})
```

**Parameters:**
- `query`: GraphQL query string
- `variable`: Query variables
- `fetchPolicy`: Fetch policy override
- `modelParser`: Function to parse response data

**Returns:** Future containing parsed data of type T

**Example:**
```dart
final user = await client.query<User>(
  query: 'query GetUser(\$id: String!) { user(id: \$id) { id name } }',
  variable: {'id': 'user123'},
  modelParser: (json) => User.fromJson(json),
);
```

#### queryList<T>

Execute a GraphQL query returning a list.

```dart
Future<List<T>> queryList<T>({
  required String query,
  Map<String, dynamic>? variable,
  FetchPolicy? fetchPolicy,
  required T Function(dynamic json) modelParser,
})
```

**Parameters:** Same as `query<T>`

**Returns:** Future containing list of parsed data

**Example:**
```dart
final users = await client.queryList<User>(
  query: 'query GetUsers { users { id name } }',
  modelParser: (json) => User.fromJson(json),
);
```

#### mutate<T>

Execute a GraphQL mutation.

```dart
Future<T> mutate<T>({
  required String mutation,
  Map<String, dynamic>? variable,
  FetchPolicy? fetchPolicy,
  required T Function(dynamic json) modelParser,
})
```

**Parameters:**
- `mutation`: GraphQL mutation string
- `variable`: Mutation variables
- `fetchPolicy`: Fetch policy override
- `modelParser`: Function to parse response data

**Returns:** Future containing parsed data of type T

**Example:**
```dart
final user = await client.mutate<User>(
  mutation: 'mutation CreateUser(\$input: CreateUserInput!) { createUser(input: \$input) { id name } }',
  variable: {'input': {'name': 'John', 'email': 'john@example.com'}},
  modelParser: (json) => User.fromJson(json),
);
```

#### mutateList<T>

Execute a GraphQL mutation returning a list.

```dart
Future<List<T>> mutateList<T>({
  required String mutation,
  Map<String, dynamic>? variable,
  FetchPolicy? fetchPolicy,
  required T Function(dynamic json) modelParser,
})
```

**Parameters:** Same as `mutate<T>`

**Returns:** Future containing list of parsed data

#### Cache Management

##### saveCacheData

Save data to cache.

```dart
bool saveCacheData(String dataID, Map<String, dynamic> data)
```

##### getCacheData

Retrieve data from cache.

```dart
Map<String, dynamic>? getCacheData(String dataID)
```

##### clearCache

Clear all cached data.

```dart
Future<void> clearCache()
```

##### updateCache

Update cache with query data.

```dart
void updateCache({
  required String query,
  required Map<String, dynamic> data,
  Map<String, dynamic>? variable,
})
```

## GQLAuthProvider

Abstract class for implementing authentication providers.

### Abstract Methods

#### headerKey

```dart
String get headerKey
```

The header key for authentication (e.g., 'Authorization', 'x-api-key').

#### getToken

```dart
TokenCallback get getToken
```

Function to retrieve the authentication token.

### Implementation Example

```dart
class BearerTokenProvider implements GQLAuthProvider {
  final String token;
  
  BearerTokenProvider(this.token);
  
  @override
  String get headerKey => 'Authorization';
  
  @override
  TokenCallback get getToken => () async => 'Bearer $token';
}
```

## GQLExceptionProvider

Abstract class for implementing custom exception providers.

### Abstract Methods

#### errorCode

```dart
String get errorCode
```

The error code this provider handles.

#### createException

```dart
GQLException? createException(
  String errorCode,
  String? errorMessage,
  Map<String, dynamic>? extensions,
)
```

Create custom exception for the error code.

### Implementation Example

```dart
class HttpExceptionProvider implements GQLExceptionProvider {
  @override
  String get errorCode => 'HTTP_EXCEPTION';
  
  @override
  GQLException? createException(
    String errorCode,
    String? errorMessage,
    Map<String, dynamic>? extensions,
  ) {
    final status = extensions?['status'];
    switch (status) {
      case 401:
        return AppError(AppErrorModel(
          message: 'Unauthorized',
          code: errorCode,
        ));
      default:
        return AppError(AppErrorModel(
          message: errorMessage ?? 'HTTP Error',
          code: errorCode,
        ));
    }
  }
}
```

## GQLResult

Sealed class for handling operation results using pattern matching.

### Subclasses

#### Success<T>

Represents successful operation result.

```dart
class Success<T> extends GQLResult<T> {
  final T data;
  const Success({required this.data});
}
```

#### Failure<T>

Represents failed operation result.

```dart
class Failure<T> extends GQLResult<T> {
  final GQLException exception;
  const Failure({required this.exception});
}
```

### Methods

#### when

Handle result with callback functions.

```dart
void when({
  required void Function(T) onSuccess,
  required void Function(AppErrorModel) onFailure,
})
```

### Usage Examples

**Pattern Matching:**
```dart
switch (result) {
  case Success<User>(:final data):
    print('User: ${data.name}');
    break;
  case Failure<User>(:final exception):
    print('Error: ${exception.errorModel.message}');
    break;
}
```

**Callback Style:**
```dart
result.when(
  onSuccess: (user) => print('User: ${user.name}'),
  onFailure: (error) => print('Error: ${error.message}'),
);
```

## GQLResultWrapper

Wrapper for automatic error handling and result transformation.

### Methods

#### wrap (static)

```dart
static Future<GQLResult<T>> wrap<T>(Future<T> Function() func)
```

Wrap a function that returns a Future and convert to GQLResult.

**Example:**
```dart
final result = await GQLResultWrapper.wrap(() => 
  client.query<User>(
    query: getUserQuery,
    variable: {'id': 'user123'},
    modelParser: (json) => User.fromJson(json),
  )
);
```

#### call (instance)

```dart
Future<GQLResult<T>> call<T>(Future<T> Function() func)
```

Instance method for wrapping operations.

#### onGQLError

```dart
GQLResult<T> onGQLError<T>(GQLException exception, StackTrace stackTrace)
```

Override for custom error handling.

## GQLException

Sealed class for GraphQL exceptions.

### Factory Constructor

```dart
factory GQLException.fromException(
  dynamic exception, {
  List<GQLExceptionProvider>? exceptionProviders,
})
```

Create GQLException from any exception.

### Subclasses

#### AppError

Custom application error.

```dart
class