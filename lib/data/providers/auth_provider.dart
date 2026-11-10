import '../../domain/repositories/auth_repository.dart';
import '../repositories/mock_auth_repository.dart';

/// Central place to select the application's authentication implementation.
class AuthProvider {
  AuthProvider._();

  static final AuthRepository authRepository = MockAuthRepository();
}
