import 'package:flutter/material.dart';

import 'domain/repositories/base_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/login_page.dart';

class CrudTemplateApp extends StatelessWidget {
  const CrudTemplateApp({
    required this.authRepository,
    required this.studentRepository,
    super.key,
  });

  final AuthRepository authRepository;
  final BaseRepository studentRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD Template',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: AuthGate(
        authRepository: authRepository,
        studentRepository: studentRepository,
      ),
    );
  }
}

/// Checks the session on app launch and switches between auth destinations.
class AuthGate extends StatefulWidget {
  const AuthGate({
    required this.authRepository,
    required this.studentRepository,
    super.key,
  });

  final AuthRepository authRepository;
  final BaseRepository studentRepository;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isCheckingSession = true;
  bool _isLoggedIn = false;
  Object? _sessionError;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    setState(() {
      _isCheckingSession = true;
      _sessionError = null;
    });

    try {
      final isLoggedIn = await widget.authRepository.isLoggedIn();
      if (!mounted) return;
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isCheckingSession = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sessionError = error;
        _isCheckingSession = false;
      });
    }
  }

  void _handleLoginSuccess() {
    setState(() => _isLoggedIn = true);
  }

  void _handleLogout() {
    setState(() => _isLoggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(key: Key('sessionLoadingIndicator')),
        ),
      );
    }

    if (_sessionError != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Không thể kiểm tra trạng thái đăng nhập.'),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('retrySessionButton'),
                onPressed: _checkSession,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoggedIn) {
      return DashboardPage(
        authRepository: widget.authRepository,
        studentRepository: widget.studentRepository,
        onLoggedOut: _handleLogout,
      );
    }

    return LoginPage(
      authRepository: widget.authRepository,
      onLoginSuccess: _handleLoginSuccess,
    );
  }
}
