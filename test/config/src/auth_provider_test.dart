import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_infra_tool/graphql_infra_tool.dart';

void main() {
  group('GQLAuthProvider', () {
    test('should provide header key and token', () async {
      final provider = TestAuthProvider();

      expect(provider.headerKey, 'X-Test-Header');

      final token = await provider.getToken();
      expect(token, 'test-token-value');
    });

    test('should handle async token retrieval', () async {
      final provider = AsyncAuthProvider();

      final token = await provider.getToken();
      expect(token, 'async-token');
    });

    test('should handle null token', () async {
      final provider = NullAuthProvider();

      final token = await provider.getToken();
      expect(token, isNull);
    });
  });
}

class TestAuthProvider implements GQLAuthProvider {
  @override
  String get headerKey => 'X-Test-Header';

  @override
  TokenCallback get getToken => () async => 'test-token-value';
}

class AsyncAuthProvider implements GQLAuthProvider {
  @override
  String get headerKey => 'Authorization';

  @override
  TokenCallback get getToken => () async {
    // Simulate async operation
    await Future.delayed(Duration(milliseconds: 100));
    return 'async-token';
  };
}

class NullAuthProvider implements GQLAuthProvider {
  @override
  String get headerKey => 'Authorization';

  @override
  TokenCallback get getToken => () async => null;
}
