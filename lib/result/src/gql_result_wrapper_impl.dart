import 'dart:developer';

import 'package:graphql_infra_tool/exceptions/src/gql_exceptions.dart';
import 'package:graphql_infra_tool/result/src/gql_result.dart';
import 'package:graphql_infra_tool/result/src/gql_result_wrapper.dart';

class GQLResultWrapper implements GQLResultWrapperInterface {
  static final GQLResultWrapper _instance = GQLResultWrapper._internal();
  GQLResultWrapper._internal();
  factory GQLResultWrapper() => _instance;

  /// Static method for backward compatibility and easy usage
  static Future<GQLResult<T>> wrap<T>(Future<T> Function() func) async {
    return _instance.call(func);
  }

  @override
  Future<GQLResult<T>> call<T>(Future<T> Function() func) async {
    try {
      final result = await func();
      return Success<T>(data: result);
    } on GQLException catch (exception, stackTrace) {
      return onGQLError(exception, stackTrace);
    } catch (exception) {
      return Failure<T>(exception: GQLException.fromException(exception));
    }
  }

  @override
  GQLResult<T> onGQLError<T>(GQLException exception, StackTrace stackTrace) {
    logException(exception, stackTrace);

    return Failure<T>(exception: GQLException.fromException(exception));
  }

  void logException(GQLException exception, StackTrace stackTrace) {
    assert(() {
      log('🔥 EXCEPTION CAUGHT:');
      log('Type: ${exception.runtimeType}');
      log('Message: $exception');
      log('🔥 STACK TRACE:');
      log('$stackTrace');
      log('🔥 END DEBUG INFO');
      return true;
    }());
  }
}
