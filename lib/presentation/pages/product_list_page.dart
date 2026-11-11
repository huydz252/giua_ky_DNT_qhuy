import 'package:flutter/material.dart';

import '../../data/providers/supabase_image_storage.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/product_form_dialog.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({
    required this.repository,
    required this.storage,
    super.key,
  });

  final ProductRepository repository;
  final SupabaseImageStorage? storage;

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _search = TextEditingController();
  late Stream<List<Product>> _productsStream;

  @override
  void initState() {
    super.initState();
    _productsStream = widget.repository.watchProducts();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    final product = await ProductFormDialog.show(
      context,
      storage: widget.storage,
      onSave: widget.repository.addProduct,
    );
    if (product != null && mounted) _message('Đã thêm sản phẩm.');
  }

  Future<void> _editProduct(Product product) async {
    final updated = await ProductFormDialog.show(
      context,
      storage: widget.storage,
      product: product,
      onSave: widget.repository.updateProduct,
    );
    if (updated != null && mounted) _message('Đã cập nhật sản phẩm.');
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      itemName: product.name,
      itemLabel: 'sản phẩm',
    );
    if (!mounted || !confirmed) return;
    try {
      await widget.repository.deleteProduct(product.id);
      if (mounted) _message('Đã xóa sản phẩm.');
    } catch (error) {
      if (mounted) _message('Không thể xóa sản phẩm: $error');
    }
  }

  Future<void> _openDetails(Product product) =>
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => ProductDetailPage(
            product: product,
            repository: widget.repository,
            storage: widget.storage,
          ),
        ),
      );

  void _message(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  Widget _productList(List<Product> products) => ListView.builder(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
    itemCount: products.length,
    itemBuilder: (context, index) {
      final product = products[index];
      return Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.image.isEmpty
                ? const SizedBox(
                    width: 58,
                    height: 58,
                    child: Icon(Icons.inventory_2_outlined),
                  )
                : Image.network(
                    product.image,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 58,
                      height: 58,
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
          ),
          title: Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            'Giá: ${product.price.toStringAsFixed(0)} VNĐ  •  Số lượng: ${product.quantity}',
          ),
          onTap: () => _openDetails(product),
          trailing: Wrap(
            children: [
              IconButton(
                tooltip: 'Sửa sản phẩm',
                onPressed: () => _editProduct(product),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Xóa sản phẩm',
                onPressed: () => _deleteProduct(product),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Danh sách sản phẩm')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Tìm theo tên sản phẩm',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Product>>(
            stream: _productsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Không tải được sản phẩm. Kiểm tra Firestore Rules.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final query = _search.text.trim().toLowerCase();
              final products = snapshot.data!;
              final visible = query.isEmpty
                  ? products
                  : products
                        .where(
                          (item) => item.name.toLowerCase().contains(query),
                        )
                        .toList(growable: false);
              if (visible.isEmpty) {
                return Center(
                  child: Text(
                    query.isEmpty
                        ? 'Chưa có sản phẩm. Nhấn + để thêm.'
                        : 'Không tìm thấy sản phẩm phù hợp.',
                  ),
                );
              }
              return _productList(visible);
            },
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addProduct,
      icon: const Icon(Icons.add),
      label: const Text('Thêm sản phẩm'),
    ),
  );
}
