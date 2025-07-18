import 'package:graphql_infra_tool/exceptions/exceptions.dart';

sealed class GQLResult<T> {
  const GQLResult();

  void when({
    required void Function(T) onSuccess,
    required void Function(AppErrorModel) onFailure,
  }) {
    final value = this;
    if (value is Success<T>) {
      onSuccess(value.data);
    }
    if (value is Failure<T>) {
      onFailure(value.exception.errorModel);
    }
  }
}

class Success<T> extends GQLResult<T> {
  final T data;

  const Success({required this.data});
}

class Failure<T> extends GQLResult<T> {
  final GQLException exception;

  const Failure({required this.exception});
}
