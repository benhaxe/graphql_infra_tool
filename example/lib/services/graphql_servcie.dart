import 'package:graphql_infra_tool/config/src/graphql_config.dart';
import 'package:graphql_infra_tool/result/src/gql_result.dart';
import 'package:graphql_infra_tool/result/src/gql_result_wrapper_impl.dart';
import 'package:graphql_infra_tool/service/src/gql_client.dart';
import 'package:graphql_infra_tool_example/models/user.dart';
import 'package:graphql_infra_tool_example/providers/auth_provider.dart';
import 'package:graphql_infra_tool_example/providers/exception_provider.dart';

class GraphQLService {
  static final GraphQLService _instance = GraphQLService._internal();
  factory GraphQLService() => _instance;
  GraphQLService._internal() {
    _initializeClient();
  }

  late final GQLClient _client;

  void _initializeClient() {
    final config = GQLConfig(
      baseURL: 'https://api.example.com/graphql',
      authProviders: [BearerTokenProvider(), TenantIdProvider()],
      exceptionProviders: [
        HttpExceptionProvider(),
        NotFoundExceptionProvider(),
      ],
      responseNodePaths: ['data'],
    );

    _client = GQLClient(config, enableLogging: true);
  }

  // Queries
  Future<GQLResult<User>> getUser(String userId) async {
    return GQLResultWrapper.wrap(
      () => _client.query<User>(
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
      ),
    );
  }

  Future<GQLResult<List<User>>> getUsers() async {
    return GQLResultWrapper.wrap(
      () => _client.queryList<User>(
        query: '''
          query GetUsers {
            users {
              id
              name
              email
              createdAt
            }
          }
        ''',
        modelParser: (json) => User.fromJson(json),
      ),
    );
  }

  // Mutations
  Future<GQLResult<User>> createUser(CreateUserInput input) async {
    return GQLResultWrapper.wrap(
      () => _client.mutate<User>(
        mutation: '''
          mutation CreateUser(\$input: CreateUserInput!) {
            createUser(input: \$input) {
              id
              name
              email
              createdAt
            }
          }
        ''',
        variable: {'input': input.toJson()},
        modelParser: (json) => User.fromJson(json),
      ),
    );
  }

  Future<GQLResult<User>> updateUser(
    String userId,
    CreateUserInput input,
  ) async {
    return GQLResultWrapper.wrap(
      () => _client.mutate<User>(
        mutation: '''
          mutation UpdateUser(\$id: String!, \$input: UpdateUserInput!) {
            updateUser(id: \$id, input: \$input) {
              id
              name
              email
              createdAt
            }
          }
        ''',
        variable: {'id': userId, 'input': input.toJson()},
        modelParser: (json) => User.fromJson(json),
      ),
    );
  }

  Future<GQLResult<bool>> deleteUser(String userId) async {
    return GQLResultWrapper.wrap(
      () => _client.mutate<bool>(
        mutation: '''
          mutation DeleteUser(\$id: String!) {
            deleteUser(id: \$id)
          }
        ''',
        variable: {'id': userId},
        modelParser: (json) => json as bool,
      ),
    );
  }

  // Cache operations
  void clearCache() {
    _client.clearCache();
  }

  void updateUserCache(User user) {
    _client.updateCache(
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
      variable: {'id': user.id},
      data: {'user': user.toJson()},
    );
  }
}
