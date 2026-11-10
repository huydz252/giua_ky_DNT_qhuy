import 'package:flutter/material.dart';

import '../../domain/models/student.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/base_repository.dart';
import '../widgets/error_widget.dart' as app_widgets;
import '../widgets/loading_widget.dart';
import 'student_list_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    required this.authRepository,
    required this.studentRepository,
    required this.onLoggedOut,
    super.key,
  });

  final AuthRepository authRepository;
  final BaseRepository studentRepository;
  final VoidCallback onLoggedOut;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoggingOut = false;
  String? _logoutError;
  late Stream<List<Student>> _studentsStream;

  @override
  void initState() {
    super.initState();
    _studentsStream = widget.studentRepository.watchItems();
  }

  @override
  void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.studentRepository, widget.studentRepository)) {
      _studentsStream = widget.studentRepository.watchItems();
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() {
      _isLoggingOut = true;
      _logoutError = null;
    });

    try {
      await widget.authRepository.logout();
      if (!mounted) return;
      widget.onLoggedOut();
    } catch (_) {
      if (!mounted) return;
      setState(() => _logoutError = 'Không thể đăng xuất. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  void _openStudentList() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => StudentListPage(repository: widget.studentRepository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          TextButton.icon(
            key: const Key('logoutButton'),
            onPressed: _isLoggingOut ? null : _logout,
            icon: _isLoggingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Xin chào, admin',
            key: const Key('dashboardGreeting'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Tổng quan quản lý sinh viên',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (_logoutError != null) ...[
            const SizedBox(height: 12),
            Text(
              _logoutError!,
              key: const Key('logoutErrorMessage'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 20),
          StreamBuilder<List<Student>>(
            stream: _studentsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return app_widgets.ErrorWidget(
                  message: 'Không thể tải thống kê sinh viên.',
                  onRetry: () => setState(
                    () =>
                        _studentsStream = widget.studentRepository.watchItems(),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 160,
                  child: LoadingWidget(message: 'Đang tải thống kê...'),
                );
              }

              final students = snapshot.data!;
              final classCount = students
                  .map((student) => student.className)
                  .where((className) => className.isNotEmpty)
                  .toSet()
                  .length;
              final averageScore = students.isEmpty
                  ? 0.0
                  : students
                            .map((student) => student.averageScore)
                            .reduce((total, score) => total + score) /
                        students.length;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 600 ? 3 : 1;
                  return GridView.count(
                    key: const Key('dashboardStatistics'),
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: columns == 1 ? 3.6 : 1.6,
                    children: [
                      _StatisticCard(
                        label: 'Tổng sinh viên',
                        value: students.length.toString(),
                        icon: Icons.people_outline,
                      ),
                      _StatisticCard(
                        label: 'Số lớp',
                        value: classCount.toString(),
                        icon: Icons.class_outlined,
                      ),
                      _StatisticCard(
                        label: 'Điểm trung bình',
                        value: averageScore.toStringAsFixed(1),
                        icon: Icons.grade_outlined,
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const Key('openStudentListButton'),
            onPressed: _openStudentList,
            icon: const Icon(Icons.groups_outlined),
            label: const Text('Danh sách sinh viên'),
          ),
        ],
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
