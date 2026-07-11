import 'package:flutter/cupertino.dart';
import 'package:masrofy/core/utils/no_animation_route.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../providers/project_provider.dart';
import '../widgets/project_dialog.dart';
import '../widgets/project_card.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<ProjectProvider>(context, listen: false).loadData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('projects'.tr()),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const FaIcon(FontAwesomeIcons.plus, size: 20),
          onPressed: () => ProjectDialog.show(context),
        ),
      ),
      child: SafeArea(
        child: Consumer<ProjectProvider>(
          builder: (context, provider, child) {
            if (provider.projects.isEmpty) {
              return Center(child: Text('noProjectsYet'.tr()));
            }
            return ListView.builder(
              itemCount: provider.projects.length,
              itemBuilder: (context, index) {
                final project = provider.projects[index];
                return ProjectCard(
                  project: project,
                  onTap: () {
                    Navigator.push(
                      context,
                      NoAnimationPageRoute(
                        builder: (_) => ProjectDetailScreen(project: project),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
