import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  const ConfirmDeleteDialog({required this.studentName, super.key});

  final String studentName;

  static Future<bool> show(
    BuildContext context, {
    required String studentName,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(studentName: studentName),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận xóa'),
      content: Text('Bạn có chắc muốn xóa sinh viên "$studentName" không?'),
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
}
