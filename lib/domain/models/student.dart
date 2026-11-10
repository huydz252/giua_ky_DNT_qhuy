/// Database-independent model for a student record.
class Student {
  const Student({
    required this.id,
    required this.studentCode,
    required this.name,
    required this.email,
    required this.phone,
    required this.className,
    required this.averageScore,
    required this.createdAt,
    this.imageUrl,
  });

  final String id;
  final String studentCode;
  final String name;
  final String email;
  final String phone;
  final String className;
  final double averageScore;
  final String? imageUrl;
  final DateTime createdAt;

  /// Creates a student from a plain map without depending on a database SDK.
  ///
  /// Missing nullable or text fields receive safe defaults. Invalid numeric
  /// scores or dates throw [FormatException] so corrupt records are visible to
  /// the caller instead of silently becoming incorrect data.
  factory Student.fromMap(Map<String, Object?> map) {
    return Student(
      id: _readString(map, 'id'),
      studentCode: _readString(map, 'studentCode'),
      name: _readString(map, 'name'),
      email: _readString(map, 'email'),
      phone: _readString(map, 'phone'),
      className: _readString(map, 'className'),
      averageScore: _readDouble(map, 'averageScore'),
      imageUrl: _readNullableString(map, 'imageUrl'),
      createdAt: _readDateTime(map, 'createdAt'),
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'studentCode': studentCode,
    'name': name,
    'email': email,
    'phone': phone,
    'className': className,
    'averageScore': averageScore,
    'imageUrl': imageUrl,
    'createdAt': createdAt.toIso8601String(),
  };

  static const Object _keepImageUrl = Object();

  Student copyWith({
    String? id,
    String? studentCode,
    String? name,
    String? email,
    String? phone,
    String? className,
    double? averageScore,
    Object? imageUrl = _keepImageUrl,
    DateTime? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      studentCode: studentCode ?? this.studentCode,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      className: className ?? this.className,
      averageScore: averageScore ?? this.averageScore,
      imageUrl: identical(imageUrl, _keepImageUrl)
          ? this.imageUrl
          : imageUrl as String?,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static String _readString(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value == null) return '';
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    throw FormatException('Field "$key" must be text.');
  }

  static String? _readNullableString(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value == null) return null;
    if (value is String) return value;
    throw FormatException('Field "$key" must be text or null.');
  }

  static double _readDouble(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null && parsed.isFinite) return parsed;
    }
    throw FormatException('Field "$key" must be a finite number.');
  }

  static DateTime _readDateTime(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    throw FormatException('Field "$key" must be a valid date or timestamp.');
  }
}
