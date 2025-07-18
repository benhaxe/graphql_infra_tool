import 'package:graphql_infra_tool/config/src/gql_auth_provider.dart';
import 'package:graphql_infra_tool/config/src/gql_exception_provider.dart';
import 'package:graphql_infra_tool/exceptions/src/gql_error_model.dart';
import 'package:graphql_infra_tool/exceptions/src/gql_exceptions.dart';

class MockAuthProvider implements GQLAuthProvider {
  @override
  String get headerKey => 'Authorization';

  @override
  TokenCallback get getToken => () async => 'Bearer mock-token';
}

class MockExceptionProvider implements GQLExceptionProvider {
  @override
  String get errorCode => 'CUSTOM_ERROR';

  @override
  GQLException? createException(
    String errorCode,
    String? errorMessage,
    Map<String, dynamic>? extensions,
  ) {
    return AppError(
      AppErrorModel(message: 'Custom handled error', code: errorCode),
    );
  }
}
