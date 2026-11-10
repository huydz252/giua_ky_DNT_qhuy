/// Data source choices that have a real implementation in this project.
enum DatabaseType { mock }

class AppConfig {
  const AppConfig._();

  /// Change this value when another repository implementation is added.
  static const DatabaseType databaseType = DatabaseType.mock;
}
