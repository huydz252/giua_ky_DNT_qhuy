/// Authentication contract used by the presentation layer.
///
/// Implementations can use a mock, Firebase Auth, or a REST API without
/// changing the login or dashboard widgets.
abstract interface class AuthRepository {
  Future<bool> login(String username, String password);

  Future<void> logout();

  Future<bool> isLoggedIn();
}
