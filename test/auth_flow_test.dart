import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giua_ky/app.dart';
import 'package:giua_ky/data/repositories/mock_auth_repository.dart';
import 'package:giua_ky/domain/repositories/auth_repository.dart';
import 'package:giua_ky/presentation/pages/login_page.dart';

void main() {
  testWidgets('opens LoginPage when no session exists', (tester) async {
    await tester.pumpWidget(
      CrudTemplateApp(
        authRepository: MockAuthRepository(simulatedDelay: Duration.zero),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('usernameField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
  });

  testWidgets('validates empty fields and reports failed credentials', (
    tester,
  ) async {
    await tester.pumpWidget(
      CrudTemplateApp(
        authRepository: MockAuthRepository(simulatedDelay: Duration.zero),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập tên đăng nhập.'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('usernameField')), 'admin');
    await tester.enterText(find.byKey(const Key('passwordField')), 'wrong');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('loginErrorMessage')), findsOneWidget);
    expect(find.text('Sai tên đăng nhập hoặc mật khẩu.'), findsOneWidget);
  });

  testWidgets('shows loading and then opens DashboardPage on success', (
    tester,
  ) async {
    await tester.pumpWidget(
      CrudTemplateApp(authRepository: MockAuthRepository()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('usernameField')), 'admin');
    await tester.enterText(find.byKey(const Key('passwordField')), '123456');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();

    expect(find.byKey(const Key('loginLoadingIndicator')), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboardGreeting')), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('starts at DashboardPage when repository reports a session', (
    tester,
  ) async {
    final repository = MockAuthRepository(simulatedDelay: Duration.zero);
    await repository.login('admin', '123456');

    await tester.pumpWidget(CrudTemplateApp(authRepository: repository));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboardGreeting')), findsOneWidget);
    expect(find.byKey(const Key('usernameField')), findsNothing);
  });

  testWidgets('logout returns to LoginPage', (tester) async {
    await tester.pumpWidget(
      CrudTemplateApp(
        authRepository: MockAuthRepository(simulatedDelay: Duration.zero),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('usernameField')), 'admin');
    await tester.enterText(find.byKey(const Key('passwordField')), '123456');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('logoutButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('usernameField')), findsOneWidget);
    expect(find.byKey(const Key('dashboardGreeting')), findsNothing);
  });

  testWidgets('LoginPage depends on AuthRepository contract', (tester) async {
    final repository = _FailingAuthRepository();
    await tester.pumpWidget(
      MaterialApp(home: LoginPageHarness(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('usernameField')), 'admin');
    await tester.enterText(find.byKey(const Key('passwordField')), '123456');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('loginErrorMessage')), findsOneWidget);
  });
}

class LoginPageHarness extends StatelessWidget {
  const LoginPageHarness({required this.repository, super.key});

  final AuthRepository repository;

  @override
  Widget build(BuildContext context) {
    return LoginPage(authRepository: repository, onLoginSuccess: () {});
  }
}

class _FailingAuthRepository implements AuthRepository {
  @override
  Future<bool> login(String username, String password) async {
    throw StateError('Simulated authentication failure.');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<bool> isLoggedIn() async => false;
}
