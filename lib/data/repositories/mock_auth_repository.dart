import '../../domain/repositories/auth_repository.dart';

/// In-memory demonstration authentication. This is not real security.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({this.simulatedDelay = const Duration(milliseconds: 300)});

  static const String _validUsername = 'admin';
  static const String _validPassword = '123456';

  /// A short delay makes the loading state visible while simulating a request.
  final Duration simulatedDelay;
  bool _isAuthenticated = false;

  @override
  Future<bool> login(String username, String password) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    _isAuthenticated =
        username.trim() == _validUsername && password == _validPassword;
    return _isAuthenticated;
  }

  @override
  Future<void> logout() async {
    _isAuthenticated = false;
  }

  @override
  Future<bool> isLoggedIn() async => _isAuthenticated;
}
