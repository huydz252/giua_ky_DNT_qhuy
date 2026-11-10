import 'dart:async';

import '../../domain/models/student.dart';
import '../../domain/repositories/base_repository.dart';

/// In-memory repository used by default so the app can run without a backend.
class MockStudentRepository implements BaseRepository {
  MockStudentRepository({List<Student>? initialItems})
    : _items = List<Student>.of(initialItems ?? _sampleStudents) {
    _ensureUniqueSeedIds();
  }

  final List<Student> _items;
  final StreamController<List<Student>> _changes =
      StreamController<List<Student>>.broadcast();

  int _idSequence = 0;
  bool _isDisposed = false;

  static final DateTime _sampleCreatedAt = DateTime.utc(2025, 1, 1);

  static final List<Student> _sampleStudents = [
    Student(
      id: 'student-001',
      studentCode: 'SV001',
      name: 'Nguyễn Minh Anh',
      email: 'minhanh@example.com',
      phone: '0901000001',
      className: 'CNTT01',
      averageScore: 8.4,
      createdAt: _sampleCreatedAt,
    ),
    Student(
      id: 'student-002',
      studentCode: 'SV002',
      name: 'Trần Quốc Bảo',
      email: 'quocbao@example.com',
      phone: '0901000002',
      className: 'CNTT01',
      averageScore: 7.8,
      createdAt: _sampleCreatedAt,
    ),
    Student(
      id: 'student-003',
      studentCode: 'SV003',
      name: 'Lê Thu Hà',
      email: 'thuha@example.com',
      phone: '0901000003',
      className: 'CNTT02',
      averageScore: 9.1,
      createdAt: _sampleCreatedAt,
    ),
    Student(
      id: 'student-004',
      studentCode: 'SV004',
      name: 'Phạm Đức Long',
      email: 'duclong@example.com',
      phone: '0901000004',
      className: 'CNTT02',
      averageScore: 6.9,
      createdAt: _sampleCreatedAt,
    ),
    Student(
      id: 'student-005',
      studentCode: 'SV005',
      name: 'Võ Ngọc Mai',
      email: 'ngocmai@example.com',
      phone: '0901000005',
      className: 'KTPM01',
      averageScore: 8.7,
      createdAt: _sampleCreatedAt,
    ),
    Student(
      id: 'student-006',
      studentCode: 'SV006',
      name: 'Đặng Hoàng Nam',
      email: 'hoangnam@example.com',
      phone: '0901000006',
      className: 'KTPM01',
      averageScore: 7.5,
      createdAt: _sampleCreatedAt,
    ),
  ];

  @override
  Future<List<Student>> getItems() async {
    _ensureNotDisposed();
    return _snapshot();
  }

  @override
  Stream<List<Student>> watchItems() {
    if (_isDisposed) {
      return Stream<List<Student>>.error(
        StateError('MockStudentRepository has been disposed.'),
      );
    }

    // Subscribe before emitting the snapshot so a mutation cannot fall in
    // between taking the initial value and listening for subsequent changes.
    return Stream<List<Student>>.multi((controller) {
      final subscription = _changes.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
      controller.add(_snapshot());
      controller.onCancel = subscription.cancel;
    });
  }

  @override
  Future<Student?> getItemById(String id) async {
    _ensureNotDisposed();
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<void> addItem(Student item) async {
    _ensureNotDisposed();
    final id = _generateUniqueId();
    _items.add(item.copyWith(id: id));
    _emitChanges();
  }

  @override
  Future<void> updateItem(Student item) async {
    _ensureNotDisposed();
    final index = _items.indexWhere((existing) => existing.id == item.id);
    if (index == -1) {
      throw StateError('Cannot update missing student "${item.id}".');
    }
    _items[index] = item;
    _emitChanges();
  }

  @override
  Future<void> deleteItem(String id) async {
    _ensureNotDisposed();
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw StateError('Cannot delete missing student "$id".');
    }
    _items.removeAt(index);
    _emitChanges();
  }

  @override
  Future<List<Student>> searchItems(String keyword) async {
    _ensureNotDisposed();
    final query = keyword.trim().toLowerCase();
    if (query.isEmpty) return _snapshot();

    return List<Student>.unmodifiable(
      _items.where((student) {
        return student.studentCode.toLowerCase().contains(query) ||
            student.name.toLowerCase().contains(query) ||
            student.email.toLowerCase().contains(query) ||
            student.className.toLowerCase().contains(query);
      }),
    );
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _changes.close();
  }

  List<Student> _snapshot() => List<Student>.unmodifiable(_items);

  void _emitChanges() {
    _changes.add(_snapshot());
  }

  String _generateUniqueId() {
    String id;
    do {
      _idSequence++;
      id = 'student-${DateTime.now().microsecondsSinceEpoch}-$_idSequence';
    } while (_items.any((item) => item.id == id));
    return id;
  }

  void _ensureUniqueSeedIds() {
    final ids = <String>{};
    for (final item in _items) {
      if (!ids.add(item.id)) {
        throw ArgumentError.value(
          item.id,
          'initialItems',
          'Student IDs must be unique.',
        );
      }
    }
  }

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('MockStudentRepository has been disposed.');
    }
  }
}
