import 'package:graphql_infra_tool/config/src/gql_exception_provider.dart';
import 'package:graphql_infra_tool/exceptions/src/gql_error_model.dart';
import 'package:graphql_infra_tool/exceptions/src/gql_exceptions.dart';

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
        return AppError(
          AppErrorModel(
            message: 'Authentication required. Please log in again.',
            code: 'UNAUTHORIZED',
          ),
        );
      case 403:
        return AppError(
          AppErrorModel(
            message: 'You do not have permission to perform this action.',
            code: 'FORBIDDEN',
          ),
        );
      case 404:
        return AppError(
          AppErrorModel(
            message: 'The requested resource was not found.',
            code: 'NOT_FOUND',
          ),
        );
      case 500:
        return AppError(
          AppErrorModel(
            message: 'Internal server error. Please try again later.',
            code: 'INTERNAL_SERVER_ERROR',
          ),
        );
      default:
        return AppError(
          AppErrorModel(
            message: errorMessage ?? 'An HTTP error occurred',
            code: errorCode,
          ),
        );
    }
  }
}

class NotFoundExceptionProvider implements GQLExceptionProvider {
  @override
  String get errorCode => 'NOT_FOUND_ERROR';

  @override
  GQLException? createException(
    String errorCode,
    String? errorMessage,
    Map<String, dynamic>? extensions,
  ) {
    return AppError(
      AppErrorModel(
        message: errorMessage ?? 'Resource not found',
        code: errorCode,
      ),
    );
  }
}

class ValidationExceptionProvider implements GQLExceptionProvider {
  @override
  String get errorCode => 'VALIDATION_ERROR';

  @override
  GQLException? createException(
    String errorCode,
    String? errorMessage,
    Map<String, dynamic>? extensions,
  ) {
    final validationErrors = extensions?['validationErrors'] as List?;

    if (validationErrors != null && validationErrors.isNotEmpty) {
      final firstError = validationErrors.first;
      return AppError(
        AppErrorModel(
          message: firstError['message'] ?? errorMessage ?? 'Validation failed',
          code: errorCode,
        ),
      );
    }

    return AppError(
      AppErrorModel(
        message: errorMessage ?? 'Validation failed',
        code: errorCode,
      ),
    );
  }
}
