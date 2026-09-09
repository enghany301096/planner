import 'package:flutter_test/flutter_test.dart';
import 'package:planner/models/project_member.dart';
import 'package:planner/models/project_task.dart';

void main() {
  test('ProjectMember initials from full name', () {
    const member = ProjectMember(
      id: 'm1',
      projectId: 'p1',
      name: 'Hany Ali',
      color: 0xFF6366F1,
    );
    expect(member.initials, 'HA');
  });

  test('ProjectTask keeps assigneeIds via copyWith and fromMap', () {
    final task = ProjectTask(
      id: 't1',
      projectId: 'p1',
      name: 'Fix login',
      details: '',
      attachments: const [],
      startDate: DateTime(2026, 1, 1),
      cost: 0,
      type: 'bug',
      status: 'done',
      assigneeIds: const ['m1', 'm2'],
    );

    expect(task.assigneeIds, ['m1', 'm2']);
    expect(task.copyWith(status: 'inProgress').assigneeIds, ['m1', 'm2']);
    expect(task.copyWith(assigneeIds: const ['m1']).assigneeIds, ['m1']);

    final restored = ProjectTask.fromMap(task.toMap(), assigneeIds: ['m2']);
    expect(restored.assigneeIds, ['m2']);
    expect(restored.type, 'bug');
    expect(restored.status, 'done');
  });

  test('filter tasks by assignee id', () {
    final tasks = [
      ProjectTask(
        id: '1',
        projectId: 'p',
        name: 'A',
        details: '',
        attachments: const [],
        startDate: DateTime(2026, 1, 1),
        cost: 0,
        assigneeIds: const ['m1'],
      ),
      ProjectTask(
        id: '2',
        projectId: 'p',
        name: 'B',
        details: '',
        attachments: const [],
        startDate: DateTime(2026, 1, 1),
        cost: 0,
        assigneeIds: const ['m2'],
      ),
    ];
    final filtered = tasks.where((t) => t.assigneeIds.contains('m1')).toList();
    expect(filtered.length, 1);
    expect(filtered.first.id, '1');
  });
}
