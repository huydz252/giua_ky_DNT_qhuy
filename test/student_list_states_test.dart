import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giua_ky/data/repositories/mock_student_repository.dart';
import 'package:giua_ky/domain/models/student.dart';
import 'package:giua_ky/presentation/pages/student_list_page.dart';
import 'package:giua_ky/presentation/widgets/empty_widget.dart';
import 'package:giua_ky/presentation/widgets/error_widget.dart' as app_widgets;
import 'package:giua_ky/presentation/widgets/loading_widget.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('search filters streamed students and shows Search Empty', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = MockStudentRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      MaterialApp(home: StudentListPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nguyễn Minh Anh'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('studentSearchField')),
      'CNTT01',
    );
    await tester.pumpAndSettle();
    expect(find.text('Nguyễn Minh Anh'), findsOneWidget);
    expect(find.text('Trần Quốc Bảo'), findsOneWidget);
    expect(find.text('Lê Thu Hà'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('studentSearchField')),
      'thu hà',
    );
    await tester.pumpAndSettle();
    expect(find.text('Lê Thu Hà'), findsOneWidget);
    expect(find.text('Nguyễn Minh Anh'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('studentSearchField')),
      'ngocmai@example.com',
    );
    await tester.pumpAndSettle();
    expect(find.text('Võ Ngọc Mai'), findsOneWidget);
    expect(find.text('Lê Thu Hà'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('studentSearchField')),
      'not-found',
    );
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy sinh viên phù hợp.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('studentSearchField')),
      'SV003',
    );
    await tester.pumpAndSettle();
    expect(find.text('Lê Thu Hà'), findsOneWidget);
    expect(find.text('Nguyễn Minh Anh'), findsNothing);
  });

  testWidgets('list presents Loading, Empty, and Error states', (tester) async {
    final loadingRepository = _LoadingStudentRepository();
    await tester.pumpWidget(
      MaterialApp(home: StudentListPage(repository: loadingRepository)),
    );
    await tester.pump();
    expect(find.byType(LoadingWidget), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await loadingRepository.dispose();

    final emptyRepository = MockStudentRepository(initialItems: []);
    await tester.pumpWidget(
      MaterialApp(home: StudentListPage(repository: emptyRepository)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EmptyWidget), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await emptyRepository.dispose();

    final errorRepository = _ErrorStudentRepository();
    await tester.pumpWidget(
      MaterialApp(home: StudentListPage(repository: errorRepository)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(app_widgets.ErrorWidget), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await errorRepository.dispose();
  });

  testWidgets('invalid email and out-of-range score are rejected', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = MockStudentRepository(initialItems: []);
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      MaterialApp(home: StudentListPage(repository: repository)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addStudentButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('saveStudentButton')));
    await tester.pumpAndSettle();
    expect(find.text('Trường này không được để trống.'), findsNWidgets(6));
    expect(await repository.getItems(), isEmpty);

    await tester.enterText(find.byKey(const Key('studentCodeField')), 'SV900');
    await tester.enterText(find.byKey(const Key('studentNameField')), 'An');
    await tester.enterText(
      find.byKey(const Key('studentEmailField')),
      'bad-email',
    );
    await tester.enterText(
      find.byKey(const Key('studentPhoneField')),
      '0909000000',
    );
    await tester.enterText(
      find.byKey(const Key('studentClassField')),
      'CNTT09',
    );
    await tester.enterText(find.byKey(const Key('studentScoreField')), '10.1');
    await tester.tap(find.byKey(const Key('saveStudentButton')));
    await tester.pumpAndSettle();

    expect(find.text('Email không hợp lệ.'), findsOneWidget);
    expect(find.text('Điểm phải nằm trong khoảng 0 đến 10.'), findsOneWidget);
    expect(await repository.getItems(), isEmpty);

    await tester.enterText(
      find.byKey(const Key('studentEmailField')),
      'an@example.com',
    );
    await tester.enterText(find.byKey(const Key('studentScoreField')), '-0.1');
    await tester.tap(find.byKey(const Key('saveStudentButton')));
    await tester.pumpAndSettle();
    expect(find.text('Điểm phải nằm trong khoảng 0 đến 10.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('studentScoreField')), '10');
    await tester.tap(find.byKey(const Key('saveStudentButton')));
    await tester.pumpAndSettle();
    expect((await repository.getItems()).single.averageScore, 10);
  });

  testWidgets('save error stays in the form and does not add a record', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FailingAddRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      MaterialApp(home: StudentListPage(repository: repository)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addStudentButton')));
    await tester.pumpAndSettle();
    await _fillStudentForm(tester);
    await tester.tap(find.byKey(const Key('saveStudentButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('studentFormError')), findsOneWidget);
    expect(find.byKey(const Key('studentCodeField')), findsOneWidget);
    expect(await repository.getItems(), isEmpty);
  });

  testWidgets('save shows loading and ignores another tap while pending', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _DelayedAddRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      MaterialApp(home: StudentListPage(repository: repository)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addStudentButton')));
    await tester.pumpAndSettle();
    await _fillStudentForm(tester);
    await tester.tap(find.byKey(const Key('saveStudentButton')));
    await tester.pump();

    expect(repository.addCallCount, 1);
    expect(
      find.byKey(const Key('studentSaveLoadingIndicator')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('saveStudentButton')))
          .onPressed,
      isNull,
    );

    repository.completeAdd.complete();
    await tester.pumpAndSettle();
    expect(await repository.getItems(), hasLength(1));
  });

  testWidgets('cancelled delete leaves the student unchanged', (tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = MockStudentRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      MaterialApp(home: StudentListPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('deleteStudent-student-001')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cancelDeleteButton')));
    await tester.pumpAndSettle();

    expect(await repository.getItems(), hasLength(6));
    expect(find.text('Nguyễn Minh Anh'), findsOneWidget);
  });

  testWidgets('finishing delete after list disposal does not update dead UI', (
    tester,
  ) async {
    final repository = _DelayedDeleteRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      MaterialApp(home: StudentListPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('deleteStudent-student-001')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmDeleteButton')));
    await tester.pump();
    expect(repository.deleteRequested, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    repository.completeDelete.complete();
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('finishing save after dialog disposal does not update dead UI', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _DelayedAddRepository();
    addTearDown(repository.dispose);
    await tester.pumpWidget(
      MaterialApp(home: StudentListPage(repository: repository)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addStudentButton')));
    await tester.pumpAndSettle();
    await _fillStudentForm(tester);
    await tester.tap(find.byKey(const Key('saveStudentButton')));
    await tester.pump();
    expect(repository.addCallCount, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    repository.completeAdd.complete();
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}

Future<void> _fillStudentForm(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('studentCodeField')), 'SV901');
  await tester.enterText(
    find.byKey(const Key('studentNameField')),
    'Test Student',
  );
  await tester.enterText(
    find.byKey(const Key('studentEmailField')),
    'test@example.com',
  );
  await tester.enterText(
    find.byKey(const Key('studentPhoneField')),
    '0900000000',
  );
  await tester.enterText(find.byKey(const Key('studentClassField')), 'CNTT09');
  await tester.enterText(find.byKey(const Key('studentScoreField')), '7.5');
}

class _LoadingStudentRepository extends MockStudentRepository {
  @override
  Stream<List<Student>> watchItems() => Stream<List<Student>>.multi((_) {});
}

class _ErrorStudentRepository extends MockStudentRepository {
  @override
  Stream<List<Student>> watchItems() =>
      Stream<List<Student>>.error(StateError('Test stream error.'));
}

class _FailingAddRepository extends MockStudentRepository {
  _FailingAddRepository() : super(initialItems: const []);

  @override
  Future<void> addItem(Student item) async {
    throw StateError('Test write error.');
  }
}

class _DelayedAddRepository extends MockStudentRepository {
  _DelayedAddRepository() : super(initialItems: const []);

  final Completer<void> completeAdd = Completer<void>();
  int addCallCount = 0;

  @override
  Future<void> addItem(Student item) async {
    addCallCount++;
    await completeAdd.future;
    await super.addItem(item);
  }
}

class _DelayedDeleteRepository extends MockStudentRepository {
  final Completer<void> completeDelete = Completer<void>();
  bool deleteRequested = false;

  @override
  Future<void> deleteItem(String id) async {
    deleteRequested = true;
    await completeDelete.future;
    await super.deleteItem(id);
  }
}
