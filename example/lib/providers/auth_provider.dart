import 'package:graphql_infra_tool/graphql_infra_tool.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BearerTokenProvider implements GQLAuthProvider {
  @override
  String get headerKey => 'Authorization';

  @override
  TokenCallback get getToken => () async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return token != null ? 'Bearer $token' : '';
  };
}

class TenantIdProvider implements GQLAuthProvider {
  @override
  String get headerKey => 'x-tenant-id';

  @override
  TokenCallback get getToken => () async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tenant_id') ?? '';
  };
}
