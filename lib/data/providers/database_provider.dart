import '../../config/app_config.dart';
import '../../domain/repositories/base_repository.dart';
import '../repositories/mock_student_repository.dart';

/// Small composition root for repositories; no third-party DI package needed.
class DatabaseProvider {
  DatabaseProvider._();

  /// Shared instance for app-wide consumers.
  static final BaseRepository studentRepository = createStudentRepository(
    AppConfig.databaseType,
  );

  /// Creates an instance when a separate repository lifecycle is needed.
  static BaseRepository createStudentRepository(DatabaseType type) {
    switch (type) {
      case DatabaseType.mock:
        return MockStudentRepository();
    }
  }
}
