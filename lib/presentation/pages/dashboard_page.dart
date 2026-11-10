import 'package:flutter/material.dart';

import '../../domain/repositories/auth_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    required this.authRepository,
    required this.onLoggedOut,
    super.key,
  });

  final AuthRepository authRepository;
  final VoidCallback onLoggedOut;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoggingOut = false;
  String? _errorMessage;

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() {
      _isLoggingOut = true;
      _errorMessage = null;
    });

    try {
      await widget.authRepository.logout();
      if (!mounted) return;
      widget.onLoggedOut();
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Không thể đăng xuất. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          TextButton.icon(
            key: const Key('logoutButton'),
            onPressed: _isLoggingOut ? null : _logout,
            icon: _isLoggingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle_outlined, size: 64),
              const SizedBox(height: 12),
              Text(
                'Xin chào, admin',
                key: const Key('dashboardGreeting'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text('Bạn đã đăng nhập thành công.'),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  key: const Key('logoutErrorMessage'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
