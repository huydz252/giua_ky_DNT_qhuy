import 'package:flutter/material.dart';

import '../../data/providers/supabase_image_storage.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/product_form_dialog.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    required this.product,
    required this.repository,
    required this.storage,
    super.key,
  });

  final Product product;
  final ProductRepository repository;
  final SupabaseImageStorage? storage;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product _product = widget.product;
  String? _error;

  Future<void> _edit() async {
    final updated = await ProductFormDialog.show(
      context,
      storage: widget.storage,
      product: _product,
      onSave: widget.repository.updateProduct,
    );
    if (updated == null || !mounted) return;
    setState(() {
      _product = updated;
      _error = null;
    });
  }

  Future<void> _delete() async {
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      itemName: _product.name,
      itemLabel: 'sản phẩm',
    );
    if (!mounted || !confirmed) return;
    try {
      await widget.repository.deleteProduct(_product.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _error = 'Không thể xóa sản phẩm: $error');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Chi tiết sản phẩm'),
      actions: [
        IconButton(
          tooltip: 'Sửa sản phẩm',
          onPressed: _edit,
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'Xóa sản phẩm',
          onPressed: _delete,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _product.image.isEmpty
                ? const SizedBox(
                    width: 240,
                    height: 220,
                    child: Icon(Icons.inventory_2_outlined, size: 80),
                  )
                : Image.network(
                    _product.image,
                    width: 320,
                    height: 260,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 240,
                      height: 220,
                      child: Icon(Icons.broken_image_outlined, size: 80),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _product.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                title: const Text('Giá'),
                trailing: Text('${_product.price.toStringAsFixed(0)} VNĐ'),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Số lượng'),
                trailing: Text(_product.quantity.toString()),
              ),
            ],
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    ),
    bottomNavigationBar: SafeArea(
      minimum: const EdgeInsets.all(16),
      child: FilledButton.icon(
        onPressed: _edit,
        icon: const Icon(Icons.edit),
        label: const Text('Sửa sản phẩm'),
      ),
    ),
  );
}
