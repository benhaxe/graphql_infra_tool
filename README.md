# GraphQL Infrastructure Tool

A comprehensive Flutter package that provides a robust wrapper around GraphQL operations with built-in error handling, authentication, caching, and logging capabilities.

## Features

- 🔐 **Flexible Authentication**: Support for multiple authentication providers (Bearer tokens, API keys, custom headers)
- 🚨 **Smart Error Handling**: Customizable exception providers with pattern matching
- 📊 **Built-in Logging**: Comprehensive request/response logging with performance metrics
- 💾 **Caching Support**: Integrated GraphQL caching with custom cache policies
- 🎯 **Type Safety**: Full type safety with generic model parsing
- 🔄 **Result Wrapper**: Elegant result handling with Success/Failure pattern matching
- 🎨 **Customizable Configuration**: Flexible configuration for different environments
- 📱 **Flutter Ready**: Optimized for Flutter applications

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  graphql_infra_tool: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Basic Setup

```dart
import 'package:graphql_infra_tool/graphql_infra_tool.dart';

// Create a basic configuration
final config = GQLConfig(
  baseURL: 'https://api.example.com/graphql',
  queryPolicy: FetchPolicy.cacheFirst,
  mutationPolicy: FetchPolicy.networkOnly,
);

// Initialize the GraphQL client
final gqlClient = GQLClient(config);
```

### 2. Simple Query Example

```dart
// Define your GraphQL query
const String getUserQuery = '''
  query GetUser(\$id: String!) {
    user(id: \$id) {
      id
      name
      email
    }
  }
''';

// Execute the query
final result = await gqlClient.query<User>(
  query: getUserQuery,
  variable: {'id': 'user123'},
  modelParser: (json) => User.fromJson(json),
);
```

### 3. Using Result Wrapper

```dart
// Wrap your GraphQL operations for elegant error handling
final result = await GQLResultWrapper.wrap(() => 
  gqlClient.query<User>(
    query: getUserQuery,
    variable: {'id': 'user123'},
    modelParser: (json) => User.fromJson(json),
  )
);

// Handle the result with pattern matching
switch (result) {
  case Success<User>(:final data):
    print('User loaded: ${data.name}');
    break;
  case Failure<User>(:final exception):
    print('Error: ${exception.errorModel.message}');
    break;
}
```

## Advanced Configuration

### Authentication Providers

Create custom authentication providers by implementing `GQLAuthProvider`:

```dart
class BearerTokenProvider implements GQLAuthProvider {
  final String token;
  
  BearerTokenProvider(this.token);
  
  @override
  String get headerKey => 'Authorization';
  
  @override
  TokenCallback get getToken => () async => 'Bearer $token';
}

class TenantIdProvider implements GQLAuthProvider {
  final String tenantId;
  
  TenantIdProvider(this.tenantId);
  
  @override
  String get headerKey => 'x-tenant-id';
  
  @override
  TokenCallback get getToken => () async => tenantId;
}

// Use in configuration
final config = GQLConfig(
  baseURL: 'https://api.example.com/graphql',
  authProviders: [
    BearerTokenProvider('your-jwt-token'),
    TenantIdProvider('tenant-123'),
  ],
);
```

### Custom Exception Handling

Implement `GQLExceptionProvider` for custom error handling:

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
          message: 'Authentication required',
          code: 'UNAUTHORIZED',
        ));
      case 403:
        return AppError(AppErrorModel(
          message: 'Access forbidden',
          code: 'FORBIDDEN',
        ));
      default:
        return AppError(AppErrorModel(
          message: errorMessage ?? 'HTTP Error',
          code: errorCode,
        ));
    }
  }
}

// Add to configuration
final config = GQLConfig(
  baseURL: 'https://api.example.com/graphql',
  exceptionProviders: [
    HttpExceptionProvider(),
    NotFoundExceptionProvider(),
  ],
);
```

### Response Node Path Configuration

Configure response node paths to automatically extract data from nested responses:

```dart
final config = GQLConfig(
  baseURL: 'https://api.example.com/graphql',
  responseNodePaths: ['data', 'result.data', 'response.payload'],
);
```

This automatically extracts data from responses like:
```json
{
  "data": {
    "user": {
      "id": "123",
      "name": "John Doe"
    }
  }
}
```

## Complete Example

Here's a complete example showing how to set up and use the package:

```dart
import 'package:flutter/material.dart';
import 'package:graphql_infra_tool/graphql_infra_tool.dart';

class GraphQLService {
  late final GQLClient _client;
  
  GraphQLService() {
    _initializeClient();
  }
  
  void _initializeClient() {
    final config = GQLConfig(
      baseURL: 'https://api.example.com/graphql',
      authProviders: [
        BearerTokenProvider('your-jwt-token'),
      ],
      exceptionProviders: [
        HttpExceptionProvider(),
      ],
      queryPolicy: FetchPolicy.cacheFirst,
      mutationPolicy: FetchPolicy.networkOnly,
      responseNodePaths: ['data'],
      enableLogging: true,
    );
    
    _client = GQLClient(config);
  }
  
  Future<GQLResult<User>> getUser(String userId) async {
    return GQLResultWrapper.wrap(() => 
      _client.query<User>(
        query: '''
          query GetUser(\$id: String!) {
            user(id: \$id) {
              id
              name
              email
              createdAt
            }
          }
        ''',
        variable: {'id': userId},
        modelParser: (json) => User.fromJson(json),
      )
    );
  }
  
  Future<GQLResult<List<User>>> getUsers() async {
    return GQLResultWrapper.wrap(() => 
      _client.queryList<User>(
        query: '''
          query GetUsers {
            users {
              id
              name
              email
            }
          }
        ''',
        modelParser: (json) => User.fromJson(json),
      )
    );
  }
  
  Future<GQLResult<User>> createUser(CreateUserInput input) async {
    return GQLResultWrapper.wrap(() => 
      _client.mutate<User>(
        mutation: '''
          mutation CreateUser(\$input: CreateUserInput!) {
            createUser(input: \$input) {
              id
              name
              email
            }
          }
        ''',
        variable: {'input': input.toJson()},
        modelParser: (json) => User.fromJson(json),
      )
    );
  }
}

// Usage in a Flutter widget
class UserListWidget extends StatefulWidget {
  @override
  _UserListWidgetState createState() => _UserListWidgetState();
}

class _UserListWidgetState extends State<UserListWidget> {
  final GraphQLService _graphQLService = GraphQLService();
  List<User> users = [];
  String? errorMessage;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }
  
  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    
    final result = await _graphQLService.getUsers();
    
    result.when(
      onSuccess: (data) {
        setState(() {
          users = data;
          isLoading = false;
          errorMessage = null;
        });
      },
      onFailure: (error) {
        setState(() {
          errorMessage = error.message;
          isLoading = false;
        });
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (errorMessage != null) {
      return Center(child: Text('Error: $errorMessage'));
    }
    
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          title: Text(user.name),
          subtitle: Text(user.email),
        );
      },
    );
  }
}
```

## API Reference

### GQLConfig

Main configuration class for the GraphQL client.

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
  List<String>? responseNodePaths,
})
```

### GQLClient

Main GraphQL client with methods for queries and mutations.

#### Methods

- `query<T>()` - Execute a GraphQL query
- `queryList<T>()` - Execute a GraphQL query returning a list
- `mutate<T>()` - Execute a GraphQL mutation
- `mutateList<T>()` - Execute a GraphQL mutation returning a list
- `saveCacheData()` - Save data to cache
- `getCacheData()` - Retrieve data from cache
- `clearCache()` - Clear all cached data
- `updateCache()` - Update cache with new data

### GQLResult

Result wrapper using pattern matching for elegant error handling.

```dart
// Pattern matching
switch (result) {
  case Success<T>(:final data):
    // Handle success
    break;
  case Failure<T>(:final exception):
    // Handle error
    break;
}

// Callback style
result.when(
  onSuccess: (data) => print('Success: $data'),
  onFailure: (error) => print('Error: ${error.message}'),
);
```

### GQLResultWrapper

Wrapper for automatic error handling and result transformation.

```dart
// Static method
final result = await GQLResultWrapper.wrap(() => someGraphQLOperation());

// Instance method
final wrapper = GQLResultWrapper();
final result = await wrapper.call(() => someGraphQLOperation());
```

## Best Practices

1. **Use Result Wrapper**: Always wrap your GraphQL operations with `GQLResultWrapper` for consistent error handling.

2. **Configure Node Paths**: Set up `responseNodePaths` to automatically extract data from your API responses.

3. **Implement Custom Providers**: Create custom authentication and exception providers for your specific needs.

4. **Cache Strategy**: Choose appropriate cache policies based on your data requirements.

5. **Type Safety**: Always use generic types with your model parsers for type safety.

6. **Error Handling**: Implement comprehensive error handling with custom exception providers.

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please:

1. Check the [documentation](https://pub.dev/packages/graphql_infra_tool)
2. Search [existing issues](https://github.com/your-org/graphql_infra_tool/issues)
3. Create a [new issue](https://github.com/your-org/graphql_infra_tool/issues/new)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes and updates.ter