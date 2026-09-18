import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planner/core/utils/app_layout.dart';
import 'package:planner/providers/project_provider.dart';
import 'package:planner/screens/projects/screens/projects_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('collapsed project filters lay out on desktop', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ProjectProvider(),
        child: const CupertinoApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(1400, 900)),
            child: AppLayoutHost(child: ProjectsScreen(embedded: true)),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
