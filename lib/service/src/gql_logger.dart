import 'dart:developer';

import 'package:gql/ast.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:async';
import 'dart:convert';

class GQLLogger extends Link {
  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    final stopWatch = Stopwatch()..start();

    _logRequest(request);

    try {
      await for (final response in forward!(request)) {
        _logResponse(request, response, stopWatch.elapsedMilliseconds);
        yield response;
      }
    } catch (exception, stackTrace) {
      stopWatch.stop();

      //Log Error.
      _logError(request, exception, stopWatch.elapsedMilliseconds, stackTrace);
      rethrow;
    }
  }

  void _logRequest(Request request) {
    final operation = request.operation;
    final operationType = _getOperationType(operation.document);

    log('🚀 GraphQL $operationType Request:');

    if (request.variables.isNotEmpty) {
      log('📋 Variables: ${_formatJson(request.variables)}');
    }

    log('📄 Query: ${operation.document.definitions.first.toString()}');
    log('═══════════════════════════════════════════════════════');
  }

  void _logResponse(Request request, Response response, int duration) {
    final operation = request.operation;
    final operationType = _getOperationType(operation.document);
    log('✅ GraphQL $operationType Response (${duration}ms):');

    if (response.errors != null && response.errors!.isNotEmpty) {
      log('❌ Errors: ${_formatJson(response.errors)}');
    }

    if (response.data != null) {
      log('📦 Data: ${_formatJson(response.data!)}');
    }

    final contextEntry = response.context.entry();
    if (contextEntry != null) {
      log('🔧 Context: ${_formatJson(contextEntry)}');
    }

    log('═══════════════════════════════════════════════════════');
  }

  String _getOperationType(DocumentNode document) {
    final definition = document.definitions.first;
    if (definition is OperationDefinitionNode) {
      switch (definition.type) {
        case OperationType.query:
          return 'Query';
        case OperationType.mutation:
          return 'Mutation';
        case OperationType.subscription:
          return 'Subscription';
      }
    }
    return 'Operation';
  }

  void _logError(
    Request request,
    dynamic error,
    int duration, [
    StackTrace? stackTrace,
  ]) {
    final operation = request.operation;
    final operationType = _getOperationType(operation.document);

    log('💥 GraphQL $operationType Error (${duration}ms):');
    log('❌ Error: ${_formatJson(error)}');
    if (stackTrace != null) {
      log('🧵 StackTrace: $stackTrace');
    }
    log('═══════════════════════════════════════════════════════');
  }

  String _formatJson(dynamic data) {
    try {
      final encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }
}
