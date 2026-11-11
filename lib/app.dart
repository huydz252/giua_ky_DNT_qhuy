import 'package:flutter/material.dart';

import 'data/providers/supabase_image_storage.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/login_page.dart';

class ProductAdminApp extends StatelessWidget {
  const ProductAdminApp({
    required this.authRepository,
    required this.productRepository,
    required this.storage,
    super.key,
  });

  final AuthRepository authRepository;
  final ProductRepository productRepository;
  final SupabaseImageStorage? storage;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Quản lý sản phẩm',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    ),
    home: _AuthGate(
      authRepository: authRepository,
      productRepository: productRepository,
      storage: storage,
    ),
  );
}

class _AuthGate extends StatefulWidget {
  const _AuthGate({
    required this.authRepository,
    required this.productRepository,
    required this.storage,
  });

  final AuthRepository authRepository;
  final ProductRepository productRepository;
  final SupabaseImageStorage? storage;

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool? _loggedIn;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final loggedIn = await widget.authRepository.isLoggedIn();
      if (mounted) setState(() => _loggedIn = loggedIn);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _loggedIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loggedIn == null) {
      return const Material(child: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Material(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Firebase Authentication lỗi: $_error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    if (_loggedIn!) {
      return DashboardPage(
        authRepository: widget.authRepository,
        productRepository: widget.productRepository,
        storage: widget.storage,
        onLogout: () => setState(() => _loggedIn = false),
      );
    }
    return LoginPage(
      authRepository: widget.authRepository,
      onSuccess: () => setState(() => _loggedIn = true),
    );
  }
}
