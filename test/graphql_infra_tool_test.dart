import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_infra_tool/graphql_infra_tool.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_infra_tool/result/src/gql_result_wrapper_impl.dart';

import 'mocks.dart';

void main() {
  group('GQLConfig', () {
    test('should create config with required baseURL', () {
      final config = GQLConfig(baseURL: 'https://api.example.com/graphql');

      expect(config.baseURL, 'https://api.example.com/graphql');
      expect(config.authProviders, isNull);
      expect(config.exceptionProviders, isNull);
    });

    test('should support auth providers', () {
      final authProvider = MockAuthProvider();
      final config = GQLConfig(
        baseURL: 'https://api.example.com/graphql',
        authProviders: [authProvider],
      );

      expect(config.authProviders, isNotNull);
      expect(config.authProviders!.length, 1);
      expect(config.authProviders!.first, authProvider);
    });

    test('should support exception providers', () {
      final exceptionProvider = MockExceptionProvider();
      final config = GQLConfig(
        baseURL: 'https://api.example.com/graphql',
        exceptionProviders: [exceptionProvider],
      );

      expect(config.exceptionProviders, isNotNull);
      expect(config.exceptionProviders!.length, 1);
      expect(config.exceptionProviders!.first, exceptionProvider);
    });

    test('should support custom fetch policies', () {
      final config = GQLConfig(
        baseURL: 'https://api.example.com/graphql',
        queryPolicy: FetchPolicy.cacheFirst,
        mutationPolicy: FetchPolicy.networkOnly,
      );

      expect(config.queryPolicy, FetchPolicy.cacheFirst);
      expect(config.mutationPolicy, FetchPolicy.networkOnly);
    });

    test('should support response node paths', () {
      final config = GQLConfig(
        baseURL: 'https://api.example.com/graphql',
        responseNodePaths: ['data', 'result.data'],
      );

      expect(config.responseNodePaths, ['data', 'result.data']);
    });
  });

  group('GQLException', () {
    test('should create UnExpectedError from generic exception', () {
      final exception = GQLException.fromException(Exception('Test error'));

      expect(exception, isA<UnExpectedError>());
    });

    test('should create UnableToProcessError from type error', () {
      final exception = GQLException.fromException(
        'String is not a subtype of int',
      );

      expect(exception, isA<UnableToProcessError>());
    });

    test('should return same exception if already GQLException', () {
      final originalException = UnExpectedError();
      final exception = GQLException.fromException(originalException);

      expect(exception, same(originalException));
    });

    test('should create AppError from OperationException', () {
      final operationException = OperationException(
        graphqlErrors: [
          GraphQLError(
            message: 'Test GraphQL error',
            extensions: {'code': 'TEST_ERROR'},
          ),
        ],
      );

      final exception = GQLException.fromException(operationException);

      expect(exception, isA<AppError>());
      final appError = exception as AppError;
      expect(appError.errorModel.message, 'Test GraphQL error');
      expect(appError.errorModel.code, 'TEST_ERROR');
    });

    test('should use custom exception provider', () {
      final customProvider = MockExceptionProvider();
      final operationException = OperationException(
        graphqlErrors: [
          GraphQLError(
            message: 'Custom error',
            extensions: {'code': 'CUSTOM_ERROR'},
          ),
        ],
      );

      final exception = GQLException.fromException(
        operationException,
        exceptionProviders: [customProvider],
      );

      expect(exception, isA<AppError>());
      final appError = exception as AppError;
      expect(appError.errorModel.message, 'Custom handled error');
    });
  });

  group('GQLResult', () {
    test('should handle success case with when method', () {
      final result = Success(data: 'test data');
      String? successData;
      AppErrorModel? errorData;

      result.when(
        onSuccess: (data) => successData = data,
        onFailure: (error) => errorData = error,
      );

      expect(successData, 'test data');
      expect(errorData, isNull);
    });

    test('should handle failure case with when method', () {
      final result = Failure(
        exception: AppError(AppErrorModel(message: 'Test error')),
      );
      String? successData;
      AppErrorModel? errorData;

      result.when(
        onSuccess: (data) => successData = data,
        onFailure: (error) => errorData = error,
      );

      expect(successData, isNull);
      expect(errorData, isNotNull);
      expect(errorData!.message, 'Test error');
    });

    test('should support pattern matching', () {
      final successResult = Success(data: 42);
      final failureResult = Failure(
        exception: AppError(AppErrorModel(message: 'Error')),
      );

      // Test success pattern
      switch (successResult) {
        case Success<int>(:final data):
          expect(data, 42);
          break;
        case Failure<int>():
          fail('Should not match failure');
      }

      // Test failure pattern
      switch (failureResult) {
        case Success<int>():
          fail('Should not match success');
        case Failure<int>(:final exception):
          expect(exception.errorModel.message, 'Error');
          break;
      }
    });
  });

  group('GQLResultWrapper', () {
    test('should wrap successful operation', () async {
      final result = await GQLResultWrapperSample.wrap(() async => 'success');

      expect(result, isA<Success<String>>());
      final success = result as Success<String>;
      expect(success.data, 'success');
    });

    test('should wrap failing operation', () async {
      final result = await GQLResultWrapperSample.wrap(() async {
        throw Exception('Test error');
      });

      expect(result, isA<Failure<dynamic>>());
      final failure = result as Failure<dynamic>;
      expect(failure.exception, isA<UnExpectedError>());
    });

    test('should wrap GQLException', () async {
      final result = await GQLResultWrapperSample.wrap(() async {
        throw AppError(AppErrorModel(message: 'Custom error'));
      });

      expect(result, isA<Failure<dynamic>>());
      final failure = result as Failure<dynamic>;
      expect(failure.exception, isA<AppError>());
      expect(failure.exception.errorModel.message, 'Custom error');
    });

    test('should use instance method', () async {
      final wrapper = GQLResultWrapperSample();
      final result = await wrapper.call(() async => 'instance success');

      expect(result, isA<Success<String>>());
      final success = result as Success<String>;
      expect(success.data, 'instance success');
    });
  });

  group('AppErrorModel', () {
    test('should create error model with message and code', () {
      final errorModel = AppErrorModel(
        message: 'Test error message',
        code: 'TEST_CODE',
      );

      expect(errorModel.message, 'Test error message');
      expect(errorModel.code, 'TEST_CODE');
    });

    test('should create error model with null values', () {
      final errorModel = AppErrorModel();

      expect(errorModel.message, isNull);
      expect(errorModel.code, isNull);
    });
  });

  group('Exception Error Models', () {
    test('UnableToProcessError should have correct error model', () {
      const exception = UnableToProcessError();
      final errorModel = exception.errorModel;

      expect(errorModel.message, 'Unable to Process Data');
      expect(errorModel.code, isNull);
    });

    test('UnExpectedError should have correct error model', () {
      const exception = UnExpectedError();
      final errorModel = exception.errorModel;

      expect(errorModel.message, 'Unexpected Error occurred');
      expect(errorModel.code, isNull);
    });

    test('AppError should use provided error model', () {
      final providedErrorModel = AppErrorModel(
        message: 'Custom error',
        code: 'CUSTOM_CODE',
      );
      final exception = AppError(providedErrorModel);

      expect(exception.errorModel, same(providedErrorModel));
    });
  });
}
