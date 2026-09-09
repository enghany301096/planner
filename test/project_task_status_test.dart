import 'package:flutter_test/flutter_test.dart';
import 'package:planner/models/project_task.dart';

void main() {
  test('legacy todo status becomes toDo', () {
    final task = ProjectTask.fromMap({
      'id': '1',
      'projectId': 'p',
      'name': 'Task',
      'details': '',
      'attachments': '[]',
      'startDate': DateTime(2026, 1, 1).toIso8601String(),
      'cost': 10.0,
      'status': 'todo',
      'subTasks': '[]',
    });
    expect(task.status, 'toDo');
  });

  test('default status is toDo', () {
    final task = ProjectTask(
      id: '1',
      projectId: 'p',
      name: 'Task',
      details: '',
      attachments: const [],
      startDate: DateTime(2026, 1, 1),
      cost: 0,
    );
    expect(task.status, 'toDo');
    expect(task.isArchived, isFalse);
    expect(task.canArchive, isFalse);
  });

  test('canArchive only when completed, paid, and not archived', () {
    final base = ProjectTask(
      id: '1',
      projectId: 'p',
      name: 'Task',
      details: '',
      attachments: const [],
      startDate: DateTime(2026, 1, 1),
      cost: 10,
      status: 'done',
      isCompleted: true,
      isPaid: true,
    );
    expect(base.canArchive, isTrue);
    expect(base.copyWith(isArchived: true).canArchive, isFalse);
    expect(base.copyWith(isPaid: false).canArchive, isFalse);
    expect(
      base.copyWith(isCompleted: false, status: 'toDo').canArchive,
      isFalse,
    );
  });
}
