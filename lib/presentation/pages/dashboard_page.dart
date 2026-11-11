import 'package:flutter/material.dart';

import '../../data/providers/supabase_image_storage.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_list_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    required this.authRepository,
    required this.productRepository,
    required this.storage,
    required this.onLogout,
    super.key,
  });

  final AuthRepository authRepository;
  final ProductRepository productRepository;
  final SupabaseImageStorage? storage;
  final VoidCallback onLogout;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loggingOut = false;
  String? _error;

  Future<void> _logout() async {
    setState(() {
      _loggingOut = true;
      _error = null;
    });
    try {
      await widget.authRepository.logout();
      if (mounted) widget.onLogout();
    } catch (_) {
      if (mounted) setState(() => _error = 'Không thể đăng xuất.');
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  void _openProducts() => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => ProductListPage(
        repository: widget.productRepository,
        storage: widget.storage,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Quản trị sản phẩm'),
      actions: [
        TextButton.icon(
          onPressed: _loggingOut ? null : _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Đăng xuất'),
        ),
      ],
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Xin chào, quản trị viên',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Quản lý tên, giá, số lượng và hình ảnh sản phẩm.'),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 24),
            StreamBuilder<List<Product>>(
              stream: widget.productRepository.watchProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Không đọc được Firestore. Kiểm tra collection products và Rules.\n${snapshot.error}',
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Card(
                    child: SizedBox(
                      height: 110,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.inventory_2_outlined, size: 32),
                    title: const Text('Sản phẩm trong hệ thống'),
                    subtitle: Text('${snapshot.data!.length} sản phẩm'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: _openProducts,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  widget.storage == null
                      ? Icons.cloud_off_outlined
                      : Icons.cloud_done_outlined,
                ),
                title: const Text('Lưu trữ hình ảnh'),
                subtitle: Text(
                  widget.storage == null
                      ? 'Chưa nạp cấu hình Supabase'
                      : 'Bucket Supabase: images',
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _openProducts,
              icon: const Icon(Icons.inventory_outlined),
              label: const Text('Mở danh sách sản phẩm'),
            ),
          ],
        ),
      ),
    ),
  );
}
