import 'package:flutter_test/flutter_test.dart';
import 'package:planner/models/income.dart';
import 'package:planner/models/project_task.dart';

void main() {
  test('paid task fields map to an income record', () {
    final task = ProjectTask(
      id: 'task-1',
      projectId: 'p1',
      name: 'Landing page',
      details: '',
      attachments: const [],
      startDate: DateTime(2026, 1, 1),
      cost: 200,
      currency: 'USD',
      isPaid: true,
      paymentMethodId: 'cash',
    );

    final income = Income(
      id: 'inc-1',
      title: task.name,
      amount: task.cost,
      date: DateTime(2026, 1, 2),
      categoryId: 'inc_projects',
      paymentMethodId: task.paymentMethodId,
      taskId: task.id,
      currency: task.currency,
    );

    expect(income.title, 'Landing page');
    expect(income.amount, 200);
    expect(income.taskId, 'task-1');
    expect(income.currency, 'USD');
    expect(income.paymentMethodId, 'cash');
  });
}
