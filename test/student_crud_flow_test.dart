import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giua_ky/app.dart';
import 'package:giua_ky/data/repositories/mock_auth_repository.dart';
import 'package:giua_ky/data/repositories/mock_student_repository.dart';

void main() {
  testWidgets('dashboard navigation and student CRUD flow use repository', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final authRepository = MockAuthRepository(simulatedDelay: Duration.zero);
    await authRepository.login('admin', '123456');
    final studentRepository = MockStudentRepository(initialItems: []);
    addTearDown(studentRepository.dispose);

    await tester.pumpWidget(
      CrudTemplateApp(
        authRepository: authRepository,
        studentRepository: studentRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboardStatistics')), findsOneWidget);
    await tester.tap(find.byKey(const Key('openStudentListButton')));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có sinh viên nào.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('addStudentButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('studentCodeField')), 'SV900');
    await tester.enterText(find.byKey(const Key('studentNameField')), 'Lê An');
    await tester.enterText(
      find.byKey(const Key('studentEmailField')),
      'an@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('studentPhoneField')),
      '0909000000',
    );
    await tester.enterText(
      find.byKey(const Key('studentClassField')),
      'CNTT09',
    );
    await tester.enterText(find.byKey(const Key('studentScoreField')), '8.5');
    await tester.tap(find.byKey(const Key('saveStudentButton')));
    await tester.pumpAndSettle();

    expect(find.text('Lê An'), findsOneWidget);
    final addedStudent = (await studentRepository.getItems()).single;
    expect(addedStudent.id, isNotEmpty);

    await tester.tap(find.text('Lê An'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('studentDetailName')), findsOneWidget);

    await tester.tap(find.byKey(const Key('detailEditButton')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('studentNameField')),
      'Lê An Updated',
    );
    await tester.tap(find.byKey(const Key('saveStudentButton')));
    await tester.pumpAndSettle();
    expect(find.text('Lê An Updated'), findsOneWidget);

    await tester.tap(find.byKey(const Key('detailDeleteButton')));
    await tester.pumpAndSettle();
    expect(find.text('Xác nhận xóa'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirmDeleteButton')));
    await tester.pumpAndSettle();

    expect(find.text('Chưa có sinh viên nào.'), findsOneWidget);
    expect(await studentRepository.getItems(), isEmpty);
  });
}
