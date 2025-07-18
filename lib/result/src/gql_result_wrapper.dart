import 'package:graphql_infra_tool/exceptions/src/gql_exceptions.dart';
import 'package:graphql_infra_tool/result/src/gql_result.dart';

abstract class GQLResultWrapperInterface {
  /// Main wrapper method that all implementations must provide
  Future<GQLResult<T>> call<T>(Future<T> Function() func);

  /// Error handling method that implementations can override
  GQLResult<T> onGQLError<T>(GQLException exception, StackTrace stackTrace);
}
