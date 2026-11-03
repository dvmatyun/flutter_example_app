/// Domain error of the authentication flow.
///
/// [message] is safe to be shown to the user.
final class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}
