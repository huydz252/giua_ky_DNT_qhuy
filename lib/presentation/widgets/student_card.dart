import 'package:flutter/material.dart';

import '../../domain/models/student.dart';

class StudentCard extends StatelessWidget {
  const StudentCard({
    required this.student,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Student student;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              CircleAvatar(
                child: Text(
                  student.name.isEmpty ? '?' : student.name[0].toUpperCase(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text('${student.studentCode}  ·  ${student.className}'),
                    Text(
                      'Điểm trung bình: ${student.averageScore.toStringAsFixed(1)}',
                    ),
                  ],
                ),
              ),
              IconButton(
                key: Key('editStudent-${student.id}'),
                tooltip: 'Chỉnh sửa ${student.name}',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                key: Key('deleteStudent-${student.id}'),
                tooltip: 'Xóa ${student.name}',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
