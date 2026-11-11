import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  const ConfirmDeleteDialog({
    required this.itemName,
    this.itemLabel = 'sản phẩm',
    super.key,
  });

  final String itemName;
  final String itemLabel;

  static Future<bool> show(
    BuildContext context, {
    required String itemName,
    String itemLabel = 'sản phẩm',
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) =>
          ConfirmDeleteDialog(itemName: itemName, itemLabel: itemLabel),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Xác nhận xóa'),
    content: Text('Bạn có chắc muốn xóa $itemLabel "$itemName" không?'),
    actions: [
      TextButton(
        key: const Key('cancelDeleteButton'),
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('Hủy'),
      ),
      FilledButton.tonal(
        key: const Key('confirmDeleteButton'),
        onPressed: () => Navigator.of(context).pop(true),
        child: const Text('Xóa'),
      ),
    ],
  );
}
