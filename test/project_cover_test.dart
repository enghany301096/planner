import 'package:flutter_test/flutter_test.dart';
import 'package:planner/models/project.dart';

void main() {
  test('Project stores cover type, icon and customer', () {
    final project = Project(
      id: '1',
      name: 'App',
      description: 'Rebuild',
      customer: 'Acme',
      coverType: Project.coverIcon,
      icon: 0xe19f,
    );

    final restored = Project.fromMap(project.toMap());
    expect(restored.customer, 'Acme');
    expect(restored.coverType, Project.coverIcon);
    expect(restored.usesIconCover, isTrue);
    expect(restored.icon, 0xe19f);
  });

  test('Project fromMap defaults cover to image', () {
    final project = Project.fromMap({
      'id': '1',
      'name': 'Legacy',
      'description': '',
    });
    expect(project.coverType, Project.coverImage);
    expect(project.usesIconCover, isFalse);
    expect(project.customer, isNull);
    expect(project.icon, isNull);
  });
}
