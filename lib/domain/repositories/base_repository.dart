import '../models/student.dart';

/// CRUD contract consumed by the application, independent of data storage.
abstract interface class BaseRepository {
  Future<List<Student>> getItems();

  /// Emits the current list on each subscription, followed by later changes.
  Stream<List<Student>> watchItems();

  Future<Student?> getItemById(String id);

  /// The repository assigns a unique ID; [item.id] is ignored on creation.
  Future<void> addItem(Student item);

  /// Updates the item with the same ID. Throws [StateError] if it is missing.
  Future<void> updateItem(Student item);

  Future<void> deleteItem(String id);

  /// Searches student code, name, email, and class name case-insensitively.
  Future<List<Student>> searchItems(String keyword);

  /// Releases resources owned by the repository.
  Future<void> dispose();
}
