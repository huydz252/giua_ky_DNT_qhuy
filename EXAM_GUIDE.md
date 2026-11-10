# Flutter CRUD Template – Exam Guide

Tài liệu này khớp với cấu trúc hiện tại của project. Mặc định, app dùng `Student` và `MockStudentRepository`. SQLite, Firebase và REST API dưới đây là hướng dẫn để tích hợp khi đề yêu cầu; hiện chưa cài hoặc đăng ký các backend đó. Không chọn một backend nếu chưa implement đủ `BaseRepository` và chưa test trên nền tảng đích.

## Luồng dữ liệu

```text
main.dart → AppConfig/DatabaseProvider → BaseRepository
                                      → MockStudentRepository
                                           → StreamBuilder trong StudentListPage
```

UI phụ thuộc repository contract, không phụ thuộc SDK database.

## 1. Đổi Student thành Product

### Model và contract

Đổi `lib/domain/models/student.dart` thành `product.dart`, class `Student` thành `Product`, rồi thay fields bằng:

```dart
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.description,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final String description;

  factory Product.fromMap(Map<String, Object?> map) => Product(
        id: map['id']?.toString() ?? '',
        name: map['name'] as String? ?? '',
        category: map['category'] as String? ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0,
        quantity: (map['quantity'] as num?)?.toInt() ?? 0,
        description: map['description'] as String? ?? '',
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'quantity': quantity,
        'description': description,
      };

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? quantity,
    String? description,
  }) => Product(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        price: price ?? this.price,
        quantity: quantity ?? this.quantity,
        description: description ?? this.description,
      );
}
```

Trong `lib/domain/repositories/base_repository.dart`, đổi import và các kiểu `Student` thành `Product`; giữ CRUD signatures. Contract hiện tên `BaseRepository`.

### Repository và DI

- Đổi `lib/data/repositories/mock_student_repository.dart` thành `mock_product_repository.dart`.
- Đổi `MockStudentRepository` thành `MockProductRepository`, seed list thành 5–10 `Product` mẫu; giữ ID sinh bởi repository, CRUD, stream snapshot đầu và dispose.
- Trong `searchItems`, tìm theo name/category/description:

```dart
return List<Product>.unmodifiable(_items.where((product) =>
    product.name.toLowerCase().contains(query) ||
    product.category.toLowerCase().contains(query) ||
    product.description.toLowerCase().contains(query)));
```

- `lib/data/providers/database_provider.dart`: đổi `studentRepository`/`createStudentRepository` thành `productRepository`/`createProductRepository`; factory trả `MockProductRepository`.
- `lib/config/app_config.dart`: vẫn chọn `DatabaseType.mock`.

### UI, validate và test

Đổi tên file/class và imports:

| Student | Product |
|---|---|
| `presentation/pages/student_list_page.dart` / `StudentListPage` | `product_list_page.dart` / `ProductListPage` |
| `presentation/pages/student_detail_page.dart` / `StudentDetailPage` | `product_detail_page.dart` / `ProductDetailPage` |
| `presentation/widgets/student_card.dart` / `StudentCard` | `product_card.dart` / `ProductCard` |
| `presentation/widgets/student_form_dialog.dart` / `StudentFormDialog` | `product_form_dialog.dart` / `ProductFormDialog` |

Trong `ProductFormDialog`, thay controller và fields bằng name/category/price/quantity/description. Ví dụ validate số:

```dart
String? validatePrice(String? value) {
  final number = double.tryParse(value?.trim() ?? '');
  if (number == null || !number.isFinite || number < 0) {
    return 'Giá phải là số không âm.';
  }
  return null;
}

String? validateQuantity(String? value) {
  final number = int.tryParse(value?.trim() ?? '');
  if (number == null || number < 0) return 'Số lượng phải là số nguyên không âm.';
  return null;
}
```

`ProductCard` hiển thị tên, danh mục, giá, số lượng; detail hiển thị đủ sáu fields. Trong `DashboardPage`, thay thống kê lớp/điểm bằng số sản phẩm, số danh mục, tổng số lượng hoặc tổng giá trị tồn kho. `app.dart` vẫn inject `BaseRepository`; `main.dart` lấy `DatabaseProvider.productRepository`. Sửa mọi fixtures/tests trong `test/` để dùng `Product`, gồm CRUD, Search, validation và stream.

Chạy `dart format .`, `flutter analyze`, `flutter test` sau đổi.

## 2. Đổi Student thành Book

Thực hiện cùng bước đổi model, contract, mock repository, provider, list/detail/card/form và tests như Product. Ví dụ fields:

```dart
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.category,
    required this.publishedYear,
  });
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String category;
  final int publishedYear;
}
```

Trong `lib/domain/models/book.dart`, thêm `fromMap`, `toMap`, `copyWith`. Đổi kiểu trong `base_repository.dart`; tạo `MockBookRepository` tại `lib/data/repositories/mock_book_repository.dart`; đổi provider thành `bookRepository`. Form validate title/author/ISBN/năm theo đề. Card/detail dùng trường Book. Search trong repository theo title, author, ISBN, category. Dashboard thống kê tổng sách/thể loại. Cập nhật tests cùng fixtures.

## 3. Đổi Student thành Employee

Dùng các bước đổi entity ở mục trên. Ví dụ fields thường gặp:

```dart
class Employee {
  const Employee({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.department,
    required this.position,
    required this.email,
    required this.phone,
    required this.salary,
  });
  final String id;
  final String employeeCode;
  final String name;
  final String department;
  final String position;
  final String email;
  final String phone;
  final double salary;
}
```

Sửa `domain/models/employee.dart`, `domain/repositories/base_repository.dart`, mock repository, `DatabaseProvider`, `EmployeeFormDialog`, `EmployeeCard`, `EmployeeDetailPage`, `EmployeeListPage`, `DashboardPage` và tests. Search theo employeeCode/name/department/email. Validator salary phải theo đề, không dùng validator điểm của Student.

## 4. Thêm field mới

Ví dụ thêm `address: String` cho Student:

1. `lib/domain/models/student.dart`: constructor/property, `fromMap`, `toMap`, `copyWith`.
2. `lib/data/repositories/mock_student_repository.dart`: bổ sung dữ liệu mẫu; thêm vào search nếu cần tìm theo address.
3. `lib/presentation/widgets/student_form_dialog.dart`: controller, initial value khi sửa, TextFormField, validator, gán khi tạo Student, dispose controller.
4. `lib/presentation/pages/student_detail_page.dart`: thêm `_DetailRow`; `student_card.dart` nếu field cần hiện trong list.
5. `test/student_repository_test.dart` và widget tests: fixtures, Map round-trip, create/update.
6. Nếu có DB thật: sửa schema/serializer. Với SQLite tăng version và viết `onUpgrade`.

Ví dụ Map/UI:

```dart
// student.dart
'address': address,

// student_form_dialog.dart
TextFormField(
  controller: _addressController,
  decoration: const InputDecoration(labelText: 'Địa chỉ'),
)
```

## 5. Thay Mock bằng SQLite

### Cài package và tạo bảng

Android/iOS/macOS:

```powershell
flutter pub add sqflite path
```

Tạo `lib/data/providers/sqlite_provider.dart`:

```dart
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class SqliteProvider {
  static Future<Database> open() async {
    final path = p.join(await getDatabasesPath(), 'crud_template.db');
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''CREATE TABLE students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentCode TEXT NOT NULL, name TEXT NOT NULL, email TEXT NOT NULL,
        phone TEXT NOT NULL, className TEXT NOT NULL,
        averageScore REAL NOT NULL, imageUrl TEXT, createdAt TEXT NOT NULL
      )''');
    });
  }
}
```

Với `sqflite`, ưu tiên tạo `lib/data/repositories/sqlite_student_repository.dart` implement đủ `BaseRepository`. Cốt lõi CRUD:

```dart
Future<List<Student>> getItems() async => (await db.query('students'))
    .map((row) => Student.fromMap(Map<String, Object?>.from(row)))
    .toList(growable: false);

Future<void> addItem(Student item) async {
  final values = item.toMap()..remove('id'); // SQLite AUTOINCREMENT
  await db.insert('students', values);
  _notifyListeners();
}

Future<void> updateItem(Student item) async {
  final count = await db.update('students', item.toMap(),
      where: 'id = ?', whereArgs: [item.id]);
  if (count == 0) throw StateError('Student không tồn tại: ${item.id}');
  _notifyListeners();
}

Future<void> deleteItem(String id) async {
  final count = await db.delete('students', where: 'id = ?', whereArgs: [id]);
  if (count == 0) throw StateError('Student không tồn tại: $id');
  _notifyListeners();
}
```

`searchItems` dùng `query(where: 'name LIKE ? OR studentCode LIKE ?', whereArgs: ['%$q%', '%$q%'])`; thêm các field search khác theo đề. Không nội suy input trực tiếp vào SQL.

SQLite không tự có Stream. Với app chỉ sửa dữ liệu qua cùng repository, giữ `StreamController.broadcast`, phát snapshot đầu khi subscribe và `_notifyListeners()` sau mutation. Nếu database có thay đổi ngoài repository, dùng polling trong `Stream.multi`; khởi động Timer khi subscribe, hủy Timer trong `onCancel`, chống poll chồng nhau, và hủy mọi Timer/đóng DB trong `dispose`. Không dùng `_notifyListeners` nếu chưa định nghĩa đúng controller/snapshot trong class.

Đăng ký `DatabaseType.sqlite` và `SqliteStudentRepository(await SqliteProvider.open())` trong `DatabaseProvider`; database mở bất đồng bộ nên initialize trước `runApp`. `sqflite` mặc định tập trung vào Android/iOS/macOS; Windows/Linux cần FFI package, Web setup riêng.

## 6. Thay Mock bằng Firebase Realtime Database

Cài và cấu hình Firebase:

```powershell
flutter pub add firebase_core firebase_database
dart pub global activate flutterfire_cli
flutterfire configure
```

Trong `lib/main.dart`, initialize Firebase trước khi tạo app/repository:

```dart
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

Tạo `lib/data/repositories/firebase_student_repository.dart`, implement `BaseRepository`. Mapping và realtime stream:

```dart
final _students = FirebaseDatabase.instance.ref('students');

Student fromEntry(String id, Object? value) {
  if (value is! Map) throw const FormatException('Expected student object.');
  final fields = value.map<String, Object?>(
    (key, value) => MapEntry(key.toString(), value),
  );
  fields['id'] = id;
  return Student.fromMap(fields);
}

Stream<List<Student>> watchItems() => _students.onValue.map((event) {
  final value = event.snapshot.value;
  if (value == null) return <Student>[];
  if (value is! Map) throw const FormatException('Expected students object.');
  return value.entries
      .map((entry) => fromEntry(entry.key.toString(), entry.value))
      .toList(growable: false);
});

Future<void> addItem(Student item) async {
  final ref = _students.push();
  final id = ref.key;
  if (id == null) throw StateError('Firebase did not create an ID.');
  await ref.set(item.copyWith(id: id).toMap());
}
```

Cùng class implement get/update/delete bằng `get()`, `child(item.id).set(...)`, `child(id).remove()`, và search. RTDB không có query substring tùy ý cho mọi field; dataset nhỏ có thể lọc sau khi lấy data trong repository. `onValue` phát snapshot hiện tại rồi phát thay đổi; StreamBuilder hủy subscription khi rời màn hình. Thêm `DatabaseType.firebaseRealtime` và factory vào `DatabaseProvider`. Cấu hình client không thay thế security rules của Firebase.

## 7. Thay Mock bằng Cloud Firestore

Cài `firebase_core` + `cloud_firestore` và chạy `flutterfire configure` như mục 6. Tạo `lib/data/repositories/firestore_student_repository.dart`:

```dart
final CollectionReference<Map<String, dynamic>> _students =
    FirebaseFirestore.instance.collection('students');

Student fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  final map = Map<String, Object?>.from(doc.data());
  map['id'] = doc.id;
  return Student.fromMap(map);
}

Stream<List<Student>> watchItems() => _students.snapshots().map(
  (snapshot) => snapshot.docs.map(fromDocument).toList(growable: false),
);

Future<void> addItem(Student item) async {
  final doc = _students.doc();
  await doc.set(item.copyWith(id: doc.id).toMap());
}

Future<void> updateItem(Student item) async =>
    _students.doc(item.id).set(item.toMap());

Future<void> deleteItem(String id) async => _students.doc(id).delete();
```

Implement get-by-id và search trong cùng repository. Firestore snapshots cung cấp realtime; không polling. Tìm `contains` tùy ý trên nhiều field không phải query tổng quát sẵn có: dùng prefix/index, backend search, hoặc lọc dataset nhỏ trong repository. Đăng ký `DatabaseType.firestore` tại `DatabaseProvider`; UI không đổi.

## 8. Tích hợp REST API

Thống nhất endpoint/JSON với server trước, ví dụ `GET/POST /students`, `GET/PUT/DELETE /students/{id}`, `GET /students?search=...`. Thêm package:

```powershell
flutter pub add http
```

Đặt base URL tập trung trong `lib/config/api_config.dart`, rồi tạo `lib/data/repositories/rest_student_repository.dart`. Inject `http.Client` để test được. Ví dụ GET/POST có kiểm tra HTTP status và JSON:

```dart
Future<List<Student>> getItems() async {
  final response = await _client.get(_uri('/students'));
  if (response.statusCode != 200) {
    throw HttpException('GET students: ${response.statusCode}');
  }
  final decoded = jsonDecode(utf8.decode(response.bodyBytes));
  if (decoded is! List) throw const FormatException('Expected JSON array.');
  return decoded.map((row) => Student.fromMap(
      Map<String, Object?>.from(row as Map))).toList(growable: false);
}

Future<void> addItem(Student item) async {
  final response = await _client.post(_uri('/students'),
    headers: {'content-type': 'application/json'},
    body: jsonEncode(item.toMap()..remove('id')));
  if (response.statusCode != 200 && response.statusCode != 201) {
    throw HttpException('POST students: ${response.statusCode}');
  }
}
```

Implement PUT/DELETE/search tương ứng; encode path IDs và xử lý body/status theo API thật. REST không tự realtime. Để giữ contract `watchItems`, dùng polling chỉ khi có listener, phát snapshot đầu, không poll chồng, hủy Timer trong `onCancel`; đóng `http.Client` trong `dispose`. Nếu API hỗ trợ SSE/WebSocket, dùng subscription đó. MongoDB chỉ được Flutter truy cập qua REST backend; không nhúng URI/password Mongo vào app. Thêm `DatabaseType.restApi` và factory trong `DatabaseProvider`.

## 9. Bỏ Login khi đề không yêu cầu

Muốn loại bỏ hẳn Auth khỏi đề hiện tại:

1. `lib/app.dart`: bỏ `AuthRepository` khỏi constructor/field `CrudTemplateApp`; đặt `home: DashboardPage(studentRepository: studentRepository)`; xóa `AuthGate` và imports Login/Auth.
2. `lib/main.dart`: bỏ `AuthProvider` và `authRepository`; chỉ inject `DatabaseProvider.studentRepository`.
3. `lib/presentation/pages/dashboard_page.dart`: bỏ constructor params `authRepository`/`onLoggedOut`, hàm `_logout`, và nút Logout trong AppBar.
4. `lib/presentation/pages/login_page.dart`: không còn được dùng; xóa nếu đề không cần. Giữ hoặc xóa `domain/repositories/auth_repository.dart`, `mock_auth_repository.dart`, `auth_provider.dart` tùy muốn template còn Auth cho đề khác hay không.
5. Cập nhật auth/widget tests để app mở thẳng Dashboard.

Sau khi bỏ `AuthRepository` khỏi constructor của `DashboardPage`, app root
trong `lib/app.dart` có dạng:

```dart
class CrudTemplateApp extends StatelessWidget {
  const CrudTemplateApp({required this.studentRepository, super.key});
  final BaseRepository studentRepository;

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: DashboardPage(studentRepository: studentRepository),
      );
}
```

## 10. Thêm tiêu chí tìm kiếm mới

Ví dụ tìm Student theo phone:

1. `lib/data/repositories/mock_student_repository.dart`: thêm
   `student.phone.toLowerCase().contains(query)` vào `searchItems`.
2. Mỗi repository backend cũng phải xử lý phone hoặc query server tương đương.
3. `lib/presentation/pages/student_list_page.dart`: Search hiện gọi
   `repository.searchItems(keyword)`; không lọc/tự giữ danh sách riêng trong page.
   Nếu muốn chọn field tìm, thêm dropdown và truyền field/keyword phù hợp.
4. `test/student_repository_test.dart`: thêm trường hợp match/no-match cho phone;
   `test/student_list_states_test.dart`: kiểm tra UI và Search Empty.

Nếu cần method riêng, thêm vào `BaseRepository`, ví dụ
`Future<List<Student>> searchByClass(String className)`, rồi implement ở mọi
repository được chọn và test lại từng implementation.

Ví dụ thêm `description` vào các trường được tìm:

```dart
@override
Future<List<Student>> searchItems(String keyword) async {
  final query = keyword.trim().toLowerCase();
  return List<Student>.unmodifiable(_items.where((student) =>
      student.studentCode.toLowerCase().contains(query) ||
      student.name.toLowerCase().contains(query) ||
      student.className.toLowerCase().contains(query) ||
      student.email.toLowerCase().contains(query) ||
      student.description.toLowerCase().contains(query)));
}
```

## Lệnh kiểm tra

```powershell
dart format .
flutter analyze
flutter test
```

Database snippets ở trên là điểm bắt đầu triển khai; cần hoàn thiện toàn bộ
contract, cấu hình platform/security và chạy tests trên backend/nền tảng đích
trước khi coi là tích hợp xong.

## Tài liệu chính thức

- [FlutterFire setup](https://firebase.google.com/docs/flutter/setup)
- [Realtime Database for Flutter](https://firebase.google.com/docs/database/flutter/read-and-write)
- [Cloud Firestore data](https://firebase.google.com/docs/firestore/query-data/get-data)
- [Flutter SQLite cookbook](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [sqflite package](https://pub.dev/packages/sqflite)
- [Dart http package](https://pub.dev/packages/http)
