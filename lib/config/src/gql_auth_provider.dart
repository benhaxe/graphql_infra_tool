typedef TokenCallback = Future<String?> Function();

/// Contract for providing authentication headers
/// Implement this interface to provide custom auth headers
abstract class GQLAuthProvider {
  /// The header key (e.g., 'Authorization', 'x-tenant-id', 'Origin')
  String get headerKey;

  /// Get the token/value for this header
  /// Return null or empty string if no token is available
  TokenCallback get getToken;
}
