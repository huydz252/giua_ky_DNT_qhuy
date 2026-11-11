import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/providers/supabase_image_storage.dart';
import '../../domain/models/product.dart';

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({
    required this.storage,
    required this.onSave,
    this.product,
    super.key,
  });

  final SupabaseImageStorage? storage;
  final Product? product;
  final Future<void> Function(Product product) onSave;

  static Future<Product?> show(
    BuildContext context, {
    required SupabaseImageStorage? storage,
    required Future<void> Function(Product product) onSave,
    Product? product,
  }) => showDialog<Product>(
    context: context,
    builder: (_) =>
        ProductFormDialog(storage: storage, onSave: onSave, product: product),
  );

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product?.name ?? '');
  late final _price = TextEditingController(
    text: widget.product?.price.toString() ?? '',
  );
  late final _quantity = TextEditingController(
    text: widget.product?.quantity.toString() ?? '',
  );
  Uint8List? _imageBytes;
  String? _imageName;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageName = picked.name;
        _error = null;
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'Không thể đọc ảnh đã chọn.');
    }
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    if (widget.product == null && _imageBytes == null) {
      setState(() => _error = 'Vui lòng chọn hình ảnh sản phẩm.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      var image = widget.product?.image ?? '';
      if (_imageBytes != null) {
        final storage = widget.storage;
        if (storage == null) {
          throw StateError(
            'Kết nối Supabase chưa sẵn sàng. Kiểm tra URL/key trong cấu hình Supabase.',
          );
        }
        image = await storage.upload(_imageBytes!, _imageName ?? 'image');
      }

      final product = Product(
        id: widget.product?.id ?? '',
        name: _name.text.trim(),
        price: double.parse(_price.text.trim()),
        quantity: int.parse(_quantity.text.trim()),
        image: image,
      );
      await widget.onSave(product);
      if (mounted) Navigator.of(context).pop(product);
    } catch (error) {
      if (mounted) setState(() => _error = 'Không thể lưu sản phẩm: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.product != null;
    return AlertDialog(
      title: Text(editing ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nhập tên sản phẩm.'
                      : null,
                ),
                TextFormField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Giá sản phẩm',
                    suffixText: 'VNĐ',
                  ),
                  validator: (value) {
                    final price = double.tryParse(value?.trim() ?? '');
                    if (price == null || !price.isFinite || price < 0) {
                      return 'Giá phải là số không âm.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _quantity,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số lượng'),
                  validator: (value) {
                    final quantity = int.tryParse(value?.trim() ?? '');
                    if (quantity == null || quantity < 0) {
                      return 'Số lượng phải là số nguyên không âm.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (_imageBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _imageBytes!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (widget.product?.image.isNotEmpty ?? false)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.product!.image,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox(
                            width: 64,
                            height: 64,
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      )
                    else
                      const SizedBox(
                        width: 64,
                        height: 64,
                        child: Icon(Icons.image_outlined, size: 32),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saving ? null : _pickImage,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(_imageName ?? 'Chọn hình ảnh'),
                      ),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(editing ? 'Lưu thay đổi' : 'Thêm sản phẩm'),
        ),
      ],
    );
  }
}
