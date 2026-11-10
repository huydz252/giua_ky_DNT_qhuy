import 'package:flutter/material.dart';

import '../../domain/models/student.dart';
import '../../domain/repositories/base_repository.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/empty_widget.dart';
import '../widgets/error_widget.dart' as app_widgets;
import '../widgets/loading_widget.dart';
import '../widgets/student_card.dart';
import '../widgets/student_form_dialog.dart';
import 'student_detail_page.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({required this.repository, super.key});

  final BaseRepository repository;

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final _searchController = TextEditingController();
  late Stream<List<Student>> _studentsStream;

  @override
  void initState() {
    super.initState();
    _studentsStream = widget.repository.watchItems();
  }

  @override
  void didUpdateWidget(covariant StudentListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.repository, widget.repository)) {
      _studentsStream = widget.repository.watchItems();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addStudent() async {
    final student = await StudentFormDialog.show(
      context,
      onSave: widget.repository.addItem,
    );
    if (student == null) return;
    if (mounted) _showMessage('Sinh viên đã được thêm.');
  }

  Future<void> _editStudent(Student student) async {
    final updatedStudent = await StudentFormDialog.show(
      context,
      student: student,
      onSave: widget.repository.updateItem,
    );
    if (updatedStudent == null) return;
    if (mounted) _showMessage('Thông tin sinh viên đã được cập nhật.');
  }

  Future<void> _deleteStudent(Student student) async {
    final confirmed = await ConfirmDeleteDialog.show(
      context,
      studentName: student.name,
    );
    if (!mounted || !confirmed) return;

    try {
      await widget.repository.deleteItem(student.id);
      if (mounted) _showMessage('Sinh viên đã được xóa.');
    } catch (_) {
      if (mounted) _showMessage('Không thể xóa sinh viên. Vui lòng thử lại.');
    }
  }

  Future<void> _openDetails(Student student) async {
    final wasDeleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            StudentDetailPage(student: student, repository: widget.repository),
      ),
    );
    if (!mounted) return;
    if (wasDeleted ?? false) _showMessage('Sinh viên đã được xóa.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildStudentCards(List<Student> students) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return StudentCard(
          student: student,
          onTap: () => _openDetails(student),
          onEdit: () => _editStudent(student),
          onDelete: () => _deleteStudent(student),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách sinh viên')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              key: const Key('studentSearchField'),
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tìm theo mã, tên, email hoặc lớp',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Xóa nội dung tìm kiếm',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: _studentsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return app_widgets.ErrorWidget(
                    message: 'Không thể tải danh sách sinh viên.',
                    onRetry: () => setState(
                      () => _studentsStream = widget.repository.watchItems(),
                    ),
                  );
                }
                if (!snapshot.hasData) return const LoadingWidget();

                final students = snapshot.data!;
                final keyword = _searchController.text.trim();
                if (keyword.isEmpty && students.isEmpty) {
                  return EmptyWidget(
                    message: 'Chưa có sinh viên nào.',
                    actionLabel: 'Thêm sinh viên',
                    onAction: _addStudent,
                  );
                }
                if (keyword.isNotEmpty) {
                  return FutureBuilder<List<Student>>(
                    future: widget.repository.searchItems(keyword),
                    builder: (context, searchSnapshot) {
                      if (searchSnapshot.hasError) {
                        return app_widgets.ErrorWidget(
                          message: 'Không thể tìm kiếm sinh viên.',
                          onRetry: () => setState(() {}),
                        );
                      }
                      if (!searchSnapshot.hasData) {
                        return const LoadingWidget(message: 'Đang tìm kiếm...');
                      }
                      final matchingStudents = searchSnapshot.data!;
                      if (matchingStudents.isEmpty) {
                        return const EmptyWidget(
                          message: 'Không tìm thấy sinh viên phù hợp.',
                        );
                      }
                      return _buildStudentCards(matchingStudents);
                    },
                  );
                }
                return _buildStudentCards(students);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addStudentButton'),
        onPressed: _addStudent,
        icon: const Icon(Icons.add),
        label: const Text('Thêm sinh viên'),
      ),
    );
  }
}
