import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_infra_tool/config/src/gql_auth_provider.dart';
import 'package:graphql_infra_tool/config/src/gql_exception_provider.dart';

class GQLConfig {
  final String baseURL;
  final TokenCallback? bearerToken;
  final List<GQLAuthProvider>? authProviders;
  final List<GQLExceptionProvider>? exceptionProviders;
  final Map<String, String>? defaultHeaders;
  final Store? cacheStore;
  final FetchPolicy? queryPolicy;
  final FetchPolicy? watchQueryPolicy;
  final FetchPolicy? mutationPolicy;
  final FetchPolicy? watchMutationPolicy;
  final FetchPolicy? subscribePolicy;
  final List<String>? responseNodePaths;

  GQLConfig({
    required this.baseURL,
    this.bearerToken,
    this.authProviders,
    this.exceptionProviders,
    this.defaultHeaders,
    this.cacheStore,
    this.queryPolicy,
    this.watchQueryPolicy,
    this.mutationPolicy,
    this.watchMutationPolicy,
    this.subscribePolicy,
    this.responseNodePaths,
  });
}
