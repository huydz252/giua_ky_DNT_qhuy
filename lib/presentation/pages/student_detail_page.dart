import 'package:flutter/material.dart';

import '../../domain/models/student.dart';
import '../../domain/repositories/base_repository.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/student_form_dialog.dart';

class StudentDetailPage extends StatefulWidget {
  const StudentDetailPage({
    required this.student,
    required this.repository,
    super.key,
  });

  final Student student;
  final BaseRepository repository;

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  late Student _student = widget.student;
  String? _errorMessage;

  Future<void> _editStudent() async {
    final updatedStudent = await StudentFormDialog.show(
      context,
      student: _student,
      onSave: widget.repository.updateItem,
    );
    if (updatedStudent == null) return;

    if (!mounted) return;
    setState(() {
      _student = updatedStudent;
      _errorMessage = null;
    });
    _showMessage('Thông tin sinh viên đã được cập nhật.');
  }

  Future<void> _deleteStudent() async {
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      studentName: _student.name,
    );
    if (!confirmed) return;

    try {
      await widget.repository.deleteItem(_student.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'Không thể xóa sinh viên.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sinh viên'),
        actions: [
          IconButton(
            key: const Key('detailEditButton'),
            tooltip: 'Chỉnh sửa',
            onPressed: _editStudent,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            key: const Key('detailDeleteButton'),
            tooltip: 'Xóa',
            onPressed: _deleteStudent,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 36,
                      child: Text(
                        _student.name.isEmpty
                            ? '?'
                            : _student.name[0].toUpperCase(),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _student.name,
                      key: const Key('studentDetailName'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const Divider(height: 32),
                  _DetailRow(
                    label: 'Mã sinh viên',
                    value: _student.studentCode,
                  ),
                  _DetailRow(label: 'Email', value: _student.email),
                  _DetailRow(label: 'Số điện thoại', value: _student.phone),
                  _DetailRow(label: 'Lớp', value: _student.className),
                  _DetailRow(
                    label: 'Điểm trung bình',
                    value: _student.averageScore.toStringAsFixed(1),
                  ),
                  _DetailRow(
                    label: 'Ngày tạo',
                    value: MaterialLocalizations.of(context)
                        .formatMediumDate(_student.createdAt),
                  ),
                  if (_student.imageUrl != null)
                    _DetailRow(label: 'URL ảnh', value: _student.imageUrl!),
                ],
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              key: const Key('studentDetailError'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _editStudent,
          icon: const Icon(Icons.edit),
          label: const Text('Chỉnh sửa thông tin'),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
