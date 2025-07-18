// Contract for providing custom exception handling
import 'package:graphql_infra_tool/exceptions/src/gql_exceptions.dart';

/// Similar to GQLAuthProvider but for exceptions
abstract class GQLExceptionProvider {
  /// The error code this provider handles (e.g., 'HTTP_EXCEPTION', 'PAYMENT_REQUIRED')
  String get errorCode;

  /// Create the appropriate exception for this error code
  /// Return null if this provider doesn't want to handle this specific case
  GQLException? createException(
    String errorCode,
    String? errorMessage,
    Map<String, dynamic>? extensions,
  );
}
