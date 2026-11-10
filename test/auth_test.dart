import 'package:flutter_test/flutter_test.dart';
import 'package:giua_ky/data/repositories/mock_auth_repository.dart';

void main() {
  group('MockAuthRepository', () {
    late MockAuthRepository repository;

    setUp(() {
      repository = MockAuthRepository(simulatedDelay: Duration.zero);
    });

    test('starts logged out', () async {
      expect(await repository.isLoggedIn(), isFalse);
    });

    test('accepts the configured mock credentials', () async {
      expect(await repository.login('admin', '123456'), isTrue);
      expect(await repository.isLoggedIn(), isTrue);
    });

    test('rejects invalid credentials and remains logged out', () async {
      expect(await repository.login('admin', 'wrong'), isFalse);
      expect(await repository.isLoggedIn(), isFalse);
    });

    test('logout clears the authenticated state', () async {
      await repository.login('admin', '123456');
      await repository.logout();

      expect(await repository.isLoggedIn(), isFalse);
    });
  });
}
