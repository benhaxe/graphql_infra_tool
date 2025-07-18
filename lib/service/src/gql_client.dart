import 'dart:developer';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_infra_tool/graphql_infra_tool.dart';
import 'package:graphql_infra_tool/service/src/gql_logger.dart';

class GQLClient {
  GQLClient(this._gqlConfig, {this.enableLogging = true}) {
    _init();
  }

  late final GraphQLClient _client;

  final GQLConfig _gqlConfig;
  final bool enableLogging;

  GQLConfig get gqlConfig => _gqlConfig;
  GraphQLClient get gqlClient => _client;

  void _init() {
    try {
      final httpLink = HttpLink(
        _gqlConfig.baseURL,
        defaultHeaders: {'Content-Type': 'application/json'},
      );

      //Create auth link if bearer token is provided.
      Link finalLink = httpLink;
      if (_gqlConfig.bearerToken != null) {
        final authLink = AuthLink(
          getToken: () async {
            final token = await _gqlConfig.bearerToken!();
            return token != null && token.isNotEmpty ? 'Bearer $token' : '';
          },
        );
        finalLink = authLink.concat(finalLink);
      }

      //Add auth provider from the list
      if (_gqlConfig.authProviders != null &&
          _gqlConfig.authProviders!.isNotEmpty) {
        for (final authProvider in _gqlConfig.authProviders!) {
          final authLink = AuthLink(
            headerKey: authProvider.headerKey,
            getToken: () async {
              final token = await authProvider.getToken();
              return token ?? '';
            },
          );
          finalLink = authLink.concat(finalLink);
        }
      }

      // Add logging link if enabled
      if (enableLogging) {
        finalLink = Link.from([GQLLogger(), finalLink]);
      }

      _client = GraphQLClient(
        link: finalLink,
        cache: GraphQLCache(store: _gqlConfig.cacheStore),
        defaultPolicies: DefaultPolicies(
          query: Policies(
            fetch: _gqlConfig.queryPolicy ?? FetchPolicy.cacheFirst,
          ),
          mutate: Policies(
            fetch: _gqlConfig.mutationPolicy ?? FetchPolicy.networkOnly,
          ),
        ),
      );
    } catch (exception) {
      throw GQLException.fromException(
        exception,
        exceptionProviders: _gqlConfig.exceptionProviders,
      );
    }
  }

  Future<T> mutate<T>({
    required String mutation,
    Map<String, dynamic>? variable,
    FetchPolicy? fetchPolicy,
    required T Function(dynamic json) modelParser,
  }) async {
    try {
      final response = await _client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: variable ?? {},
          fetchPolicy: fetchPolicy ?? _gqlConfig.mutationPolicy,
        ),
      );

      // Check if there are GraphQL errors first
      if (response.hasException) {
        throw response.exception!;
      }

      // Check if data is null
      if (response.data == null) {
        throw Exception('GraphQL response data is null');
      }

      final resolvedData = _getResolvedData(mutation, response.data!);
      try {
        return modelParser(resolvedData);
      } catch (e, s) {
        log("Model parsing error $e,\n$s");
        rethrow;
      }
    } catch (exception) {
      throw GQLException.fromException(
        exception,
        exceptionProviders: _gqlConfig.exceptionProviders,
      );
    }
  }

  Future<T> query<T>({
    required String query,
    Map<String, dynamic>? variable,
    FetchPolicy? fetchPolicy,
    required T Function(dynamic json) modelParser,
  }) async {
    try {
      final response = await _client.query(
        QueryOptions(
          document: gql(query),
          variables: variable ?? {},
          fetchPolicy: fetchPolicy ?? _gqlConfig.queryPolicy,
        ),
      );

      // Check if there are GraphQL errors first
      if (response.hasException) {
        throw response.exception!;
      }

      // Check if data is null
      if (response.data == null) {
        throw Exception('GraphQL response data is null');
      }

      final resolvedData = _getResolvedData(query, response.data!);
      try {
        return modelParser(resolvedData);
      } catch (e, s) {
        log("Model parsing error $e,\n$s");
        rethrow;
      }
    } catch (exception) {
      throw GQLException.fromException(
        exception,
        exceptionProviders: _gqlConfig.exceptionProviders,
      );
    }
  }

  Future<List<T>> queryList<T>({
    required String query,
    Map<String, dynamic>? variable,
    FetchPolicy? fetchPolicy,
    required T Function(dynamic json) modelParser,
  }) async {
    try {
      final response = await _client.query(
        QueryOptions(
          document: gql(query),
          variables: variable ?? {},
          fetchPolicy: fetchPolicy ?? _gqlConfig.queryPolicy,
        ),
      );

      if (response.hasException) {
        throw response.exception!;
      }

      if (response.data == null) {
        return <T>[];
      }

      final resolvedData = _getResolvedData(query, response.data!);

      if (resolvedData is List) {
        try {
          return resolvedData
              .map((json) => modelParser(json))
              .toList()
              .cast<T>();
        } catch (e, s) {
          log("Model parsing error $e,\n$s");
          rethrow;
        }
      }
      return <T>[];
    } catch (exception) {
      throw GQLException.fromException(
        exception,
        exceptionProviders: _gqlConfig.exceptionProviders,
      );
    }
  }

  Future<List<T>> mutateList<T>({
    required String mutation,
    Map<String, dynamic>? variable,
    FetchPolicy? fetchPolicy,
    required T Function(dynamic json) modelParser,
  }) async {
    try {
      final response = await _client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: variable ?? {},
          fetchPolicy: fetchPolicy ?? _gqlConfig.mutationPolicy,
        ),
      );

      if (response.hasException) {
        throw response.exception!;
      }

      if (response.data == null) {
        return <T>[];
      }

      final resolvedData = _getResolvedData(mutation, response.data!);
      if (resolvedData is List) {
        try {
          return resolvedData
              .map((json) => modelParser(json))
              .toList()
              .cast<T>();
        } catch (e, s) {
          log("Model parsing error $e,\n$s");
          rethrow;
        }
      }
      return <T>[];
    } catch (exception) {
      throw GQLException.fromException(
        exception,
        exceptionProviders: _gqlConfig.exceptionProviders,
      );
    }
  }

  bool saveCacheData(String dataID, Map<String, dynamic> data) {
    try {
      _client.cache.store.put(dataID, data);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearCache() async {
    _client.cache.store.reset();
  }

  Map<String, dynamic>? getCacheData(String dataID) {
    try {
      return _client.cache.store.get(dataID);
    } catch (e) {
      rethrow;
    }
  }

  void updateCache({
    required String query,
    required Map<String, dynamic> data,
    Map<String, dynamic>? variable,
  }) {
    _client.cache.writeQuery(
      Request(
        operation: Operation(document: gql(query)),
        variables: variable ?? {},
      ),
      data: data,
    );
  }

  dynamic _getNodeFromPath(Map<String, dynamic> data, String path) {
    final nodes = path.split('.');
    dynamic currentData = data;

    for (final key in nodes) {
      if (currentData is Map<String, dynamic>) {
        currentData = currentData[key];
      } else {
        return null;
      }
    }
    return currentData;
  }

  dynamic _resolveNodePath(Map<String, dynamic> data) {
    // If no node paths configured, return the original data
    if (_gqlConfig.responseNodePaths == null ||
        _gqlConfig.responseNodePaths!.isEmpty) {
      return data;
    }

    // Try to find the data using configured paths
    for (var path in _gqlConfig.responseNodePaths!) {
      final node = _getNodeFromPath(data, path);
      if (node != null) {
        return node;
      }
    }

    // If no valid node found, return the original data
    return data;
  }

  dynamic _getResolvedData(String operation, Map<String, dynamic> data) {
    final fieldName = _getFieldName(operation);
    final fieldData = data[fieldName];
    return _resolveNodePath(fieldData);
  }
}

String _getFieldName(String value) {
  // Remove whitespace and newlines
  final cleanQuery = value.replaceAll(RegExp(r'\s+'), ' ');

  // First remove the operation name if present
  final withoutOperation = cleanQuery.replaceAll(
    RegExp(r'(?:query|mutation)\s+\w+\s*'),
    '',
  );

  // Find the first field name after the opening brace
  final fieldMatch = RegExp(r'{\s*(\w+)').firstMatch(withoutOperation);

  if (fieldMatch == null) {
    throw Exception('Could not find field name in query');
  }

  return fieldMatch.group(1)!;
}
