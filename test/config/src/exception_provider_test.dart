import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_infra_tool/graphql_infra_tool.dart';

void main() {
  group('GQLExceptionProvider', () {
    test('should create custom exception for matching error code', () {
      final provider = TestExceptionProvider();

      expect(provider.errorCode, 'TEST_ERROR');

      final exception = provider.createException(
        'TEST_ERROR',
        'Test error message',
        {'status': 400},
      );

      expect(exception, isA<AppError>());
      final appError = exception as AppError;
      expect(appError.errorModel.message, 'Custom test error');
      expect(appError.errorModel.code, 'TEST_ERROR');
    });

    test('should return null for non-matching error code', () {
      final provider = TestExceptionProvider();

      final exception = provider.createException(
        'OTHER_ERROR',
        'Other error message',
        null,
      );

      expect(exception, isNull);
    });

    test('should handle extensions data', () {
      final provider = StatusExceptionProvider();

      final exception = provider.createException(
        'HTTP_ERROR',
        'HTTP error occurred',
        {'status': 401},
      );

      expect(exception, isA<AppError>());
      final appError = exception as AppError;
      expect(appError.errorModel.message, 'Unauthorized access');
    });
  });
}

class TestExceptionProvider implements GQLExceptionProvider {
  @override
  String get errorCode => 'TEST_ERROR';

  @override
  GQLException? createException(
    String errorCode,
    String? errorMessage,
    Map<String, dynamic>? extensions,
  ) {
    if (errorCode == 'TEST_ERROR') {
      return AppError(
        AppErrorModel(message: 'Custom test error', code: errorCode),
      );
    }
    return null;
  }
}

class StatusExceptionProvider implements GQLExceptionProvider {
  @override
  String get errorCode => 'HTTP_ERROR';

  @override
  GQLException? createException(
    String errorCode,
    String? errorMessage,
    Map<String, dynamic>? extensions,
  ) {
    final status = extensions?['status'] as int?;

    switch (status) {
      case 401:
        return AppError(
          AppErrorModel(message: 'Unauthorized access', code: errorCode),
        );
      case 403:
        return AppError(
          AppErrorModel(message: 'Forbidden access', code: errorCode),
        );
      case 404:
        return AppError(
          AppErrorModel(message: 'Resource not found', code: errorCode),
        );
      default:
        return AppError(
          AppErrorModel(
            message: errorMessage ?? 'HTTP error occurred',
            code: errorCode,
          ),
        );
    }
  }
}
