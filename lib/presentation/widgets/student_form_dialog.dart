import 'package:flutter/material.dart';

import '../../domain/models/student.dart';

/// Shared form for creating and editing a student.
class StudentFormDialog extends StatefulWidget {
  const StudentFormDialog({required this.onSave, this.student, super.key});

  final Student? student;
  final Future<void> Function(Student student) onSave;

  static Future<Student?> show(
    BuildContext context, {
    required Future<void> Function(Student student) onSave,
    Student? student,
  }) {
    return showDialog<Student>(
      context: context,
      builder: (_) => StudentFormDialog(student: student, onSave: onSave),
    );
  }

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _classController;
  late final TextEditingController _scoreController;
  late final TextEditingController _imageUrlController;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    _codeController = TextEditingController(text: student?.studentCode ?? '');
    _nameController = TextEditingController(text: student?.name ?? '');
    _emailController = TextEditingController(text: student?.email ?? '');
    _phoneController = TextEditingController(text: student?.phone ?? '');
    _classController = TextEditingController(text: student?.className ?? '');
    _scoreController = TextEditingController(
      text: student?.averageScore.toString() ?? '',
    );
    _imageUrlController = TextEditingController(text: student?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _classController.dispose();
    _scoreController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    final original = widget.student;
    final imageUrl = _imageUrlController.text.trim();
    final student = Student(
      id: original?.id ?? '',
      studentCode: _codeController.text.trim(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      className: _classController.text.trim(),
      averageScore: double.parse(_scoreController.text.trim()),
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      createdAt: original?.createdAt ?? DateTime.now(),
    );

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await widget.onSave(student);
      if (mounted) Navigator.of(context).pop(student);
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage = 'Không thể lưu sinh viên. Vui lòng thử lại.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;

    return AlertDialog(
      title: Text(isEditing ? 'Chỉnh sửa sinh viên' : 'Thêm sinh viên'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _requiredField(
                  controller: _codeController,
                  label: 'Mã sinh viên',
                  key: const Key('studentCodeField'),
                ),
                _requiredField(
                  controller: _nameController,
                  label: 'Họ tên',
                  key: const Key('studentNameField'),
                ),
                _requiredField(
                  controller: _emailController,
                  label: 'Email',
                  key: const Key('studentEmailField'),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                _requiredField(
                  controller: _phoneController,
                  label: 'Số điện thoại',
                  key: const Key('studentPhoneField'),
                  keyboardType: TextInputType.phone,
                ),
                _requiredField(
                  controller: _classController,
                  label: 'Lớp',
                  key: const Key('studentClassField'),
                ),
                _requiredField(
                  controller: _scoreController,
                  label: 'Điểm trung bình (0–10)',
                  key: const Key('studentScoreField'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _validateScore,
                ),
                TextFormField(
                  key: const Key('studentImageUrlField'),
                  controller: _imageUrlController,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'URL ảnh (không bắt buộc)',
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    key: const Key('studentFormError'),
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
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          key: const Key('saveStudentButton'),
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  key: Key('studentSaveLoadingIndicator'),
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Lưu thay đổi' : 'Thêm'),
        ),
      ],
    );
  }

  Widget _requiredField({
    required TextEditingController controller,
    required String label,
    required Key key,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        key: key,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator:
            validator ??
            (value) => value == null || value.trim().isEmpty
                ? 'Trường này không được để trống.'
                : null,
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Trường này không được để trống.';
    }
    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailPattern.hasMatch(value.trim())) return 'Email không hợp lệ.';
    return null;
  }

  String? _validateScore(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Trường này không được để trống.';
    }
    final score = double.tryParse(value.trim());
    if (score == null || !score.isFinite || score < 0 || score > 10) {
      return 'Điểm phải nằm trong khoảng 0 đến 10.';
    }
    return null;
  }
}
