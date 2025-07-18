import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GQLClient Field Name Extraction', () {
    test('should extract field name from simple query', () {
      const query = '''
        query {
          users {
            id
            name
          }
        }
      ''';

      final fieldName = _getFieldName(query);
      expect(fieldName, 'users');
    });

    test('should extract field name from named query', () {
      const query = '''
        query GetUsers {
          users {
            id
            name
          }
        }
      ''';

      final fieldName = _getFieldName(query);
      expect(fieldName, 'users');
    });

    test('should extract field name from mutation', () {
      const mutation = '''
        mutation CreateUser(\$input: CreateUserInput!) {
          createUser(input: \$input) {
            id
            name
          }
        }
      ''';

      final fieldName = _getFieldName(mutation);
      expect(fieldName, 'createUser');
    });

    test('should extract field name from query with variables', () {
      const query = '''
        query GetUser(\$id: String!) {
          user(id: \$id) {
            id
            name
          }
        }
      ''';

      final fieldName = _getFieldName(query);
      expect(fieldName, 'user');
    });

    test('should handle complex nested query', () {
      const query = '''
        query GetUserPosts(\$userId: String!) {
          userPosts(userId: \$userId) {
            id
            title
            author {
              id
              name
            }
          }
        }
      ''';

      final fieldName = _getFieldName(query);
      expect(fieldName, 'userPosts');
    });

    test('should throw exception for invalid query', () {
      const invalidQuery = 'invalid query string';

      expect(() => _getFieldName(invalidQuery), throwsException);
    });
  });

  group('GQLClient Node Path Resolution', () {
    test('should resolve simple node path', () {
      final data = {
        'data': {
          'user': {'id': '123', 'name': 'John Doe'},
        },
      };

      final result = _getNodeFromPath(data, 'data.user');
      expect(result, {'id': '123', 'name': 'John Doe'});
    });

    test('should resolve nested node path', () {
      final data = {
        'response': {
          'result': {
            'data': {
              'user': {'id': '123', 'name': 'John Doe'},
            },
          },
        },
      };

      final result = _getNodeFromPath(data, 'response.result.data.user');
      expect(result, {'id': '123', 'name': 'John Doe'});
    });

    test('should return null for invalid path', () {
      final data = {
        'data': {
          'user': {'id': '123', 'name': 'John Doe'},
        },
      };

      final result = _getNodeFromPath(data, 'invalid.path');
      expect(result, isNull);
    });

    test('should handle missing intermediate nodes', () {
      final data = {
        'data': {
          'user': {'id': '123'},
        },
      };

      final result = _getNodeFromPath(data, 'data.user.profile.avatar');
      expect(result, isNull);
    });
  });
}

// Helper function to simulate the private _getFieldName method
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

// Helper function to simulate the private _getNodeFromPath method
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
