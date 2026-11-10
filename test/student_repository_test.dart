import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:giua_ky/data/repositories/mock_student_repository.dart';
import 'package:giua_ky/domain/models/student.dart';

void main() {
  group('MockStudentRepository', () {
    test(
      'supports create, read, update, and delete with repository IDs',
      () async {
        final repository = MockStudentRepository();
        addTearDown(repository.dispose);

        final original = _student(id: 'caller-id');
        await repository.addItem(original);
        final itemsAfterCreate = await repository.getItems();
        expect(itemsAfterCreate, hasLength(7));

        final created = itemsAfterCreate.last;
        expect(created.id, isNot('caller-id'));
        expect(created.id, isNotEmpty);
        expect(await repository.getItemById(created.id), created);

        final updated = created.copyWith(name: 'Updated name');
        await repository.updateItem(updated);
        expect(
          (await repository.getItemById(created.id))?.name,
          'Updated name',
        );

        await repository.deleteItem(created.id);
        expect(await repository.getItemById(created.id), isNull);
        expect(await repository.getItems(), hasLength(6));
      },
    );

    test('searches code, name, class, and email case-insensitively', () async {
      final repository = MockStudentRepository();
      addTearDown(repository.dispose);

      expect((await repository.searchItems('sv003')).single.name, 'Lê Thu Hà');
      expect(
        (await repository.searchItems('THU HÀ')).single.studentCode,
        'SV003',
      );
      expect((await repository.searchItems('cntt01')), hasLength(2));
      expect(
        (await repository.searchItems('ngocmai@example.com')).single.name,
        'Võ Ngọc Mai',
      );
      expect(await repository.searchItems('  '), hasLength(6));
    });

    test('watch emits current snapshot first and every later change', () async {
      final repository = MockStudentRepository();
      addTearDown(repository.dispose);
      final iterator = StreamIterator(repository.watchItems());
      addTearDown(iterator.cancel);

      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current, hasLength(6));

      await repository.addItem(_student());
      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current, hasLength(7));

      final firstId = iterator.current.first.id;
      await repository.deleteItem(firstId);
      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current, hasLength(6));
    });

    test('dispose closes the stream and rejects later operations', () async {
      final repository = MockStudentRepository();
      final iterator = StreamIterator(repository.watchItems());

      expect(await iterator.moveNext(), isTrue);
      final nextEvent = iterator.moveNext();
      await repository.dispose();

      expect(await nextEvent, isFalse);
      await iterator.cancel();
      await expectLater(repository.getItems(), throwsA(isA<StateError>()));
      expect(repository.watchItems(), emitsError(isA<StateError>()));
    });
  });
}

Student _student({String id = ''}) {
  return Student(
    id: id,
    studentCode: 'SV900',
    name: 'Test Student',
    email: 'test@example.com',
    phone: '0909000000',
    className: 'CNTT09',
    averageScore: 7.5,
    createdAt: DateTime.utc(2025, 1, 1),
  );
}
