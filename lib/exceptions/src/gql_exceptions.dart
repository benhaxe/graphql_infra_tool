import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_infra_tool/config/src/gql_exception_provider.dart';
import 'package:graphql_infra_tool/exceptions/src/gql_error_model.dart';

sealed class GQLException implements Exception {
  const GQLException();

  factory GQLException.fromException(
    dynamic exception, {
    List<GQLExceptionProvider>? exceptionProviders,
  }) {
    if (exception is Exception) {
      if (exception is OperationException) {
        if (exception.graphqlErrors.isNotEmpty) {
          final graphqlError = exception.graphqlErrors[0];
          final errorMessage = graphqlError.message;
          final errorCode = graphqlError.extensions?["code"] ?? 'NO_CODE';
          final extensions = graphqlError.extensions;

          // Check custom exception providers first (similar to auth providers)
          if (exceptionProviders != null && exceptionProviders.isNotEmpty) {
            for (final provider in exceptionProviders) {
              if (provider.errorCode == errorCode) {
                final customException = provider.createException(
                  errorCode,
                  errorMessage,
                  extensions,
                );
                if (customException != null) {
                  return customException;
                }
              }
            }
          }
          return AppError(
            AppErrorModel(message: errorMessage, code: errorCode),
          );
        }
        return AppError(AppErrorModel(message: 'Unknown GraphQL error'));
      } else if (exception is GQLException) {
        return exception;
      } else {
        return const UnExpectedError();
      }
    } else {
      if (exception.toString().contains('Is not a subtype of')) {
        return const UnableToProcessError();
      } else {
        return const UnExpectedError();
      }
    }
  }

  AppErrorModel get errorModel {
    return switch (this) {
      UnableToProcessError() => AppErrorModel(
        message: 'Unable to Process Data',
      ),
      UnExpectedError() => AppErrorModel(message: 'Unexpected Error occurred'),
      AppError(:final errorModel) => errorModel,
    };
  }
}

class UnableToProcessError extends GQLException {
  const UnableToProcessError();
}

class UnExpectedError extends GQLException {
  const UnExpectedError();
}

class AppError extends GQLException {
  @override
  final AppErrorModel errorModel;
  const AppError(this.errorModel);
}
