import 'package:flutter/cupertino.dart';
import 'package:planner/core/utils/app_colors.dart';
import 'package:planner/core/utils/app_layout.dart';
import 'package:planner/core/utils/no_animation_route.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../providers/project_provider.dart';
import '../../../models/project.dart';
import '../widgets/project_dialog.dart';
import '../widgets/project_card.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String? _selectedId;

  void _openProject(Project project) {
    if (widget.embedded) {
      setState(() => _selectedId = project.id);
      return;
    }
    Navigator.push(
      context,
      NoAnimationPageRoute(
        builder: (_) => ProjectDetailScreen(project: project),
      ),
    );
  }

  Widget _list(ProjectProvider provider, {required bool showHeader}) {
    final list = provider.projects.isEmpty
        ? Center(child: Text('noProjectsYet'.tr()))
        : ListView.builder(
            itemCount: provider.projects.length,
            itemBuilder: (context, index) {
              final project = provider.projects[index];
              return ProjectCard(
                project: project,
                onTap: () => _openProject(project),
              );
            },
          );
    if (!showHeader) return list;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'projects'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const FaIcon(FontAwesomeIcons.plus, size: 18),
                onPressed: () => ProjectDialog.show(context),
              ),
            ],
          ),
        ),
        Expanded(child: list),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final split = widget.embedded && AppLayout.of(context).isExpanded;
    return CupertinoPageScaffold(
      navigationBar: split
          ? null
          : CupertinoNavigationBar(
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
            if (split) {
              Project? selected;
              if (_selectedId != null) {
                for (final project in provider.projects) {
                  if (project.id == _selectedId) {
                    selected = project;
                    break;
                  }
                }
              }
              return Row(
                children: [
                  SizedBox(
                    width: 360,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: BorderDirectional(
                          end: BorderSide(
                            color: AppColors.separator(context),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: _list(provider, showHeader: true),
                    ),
                  ),
                  Expanded(
                    child: selected == null
                        ? Center(child: Text('selectProject'.tr()))
                        : ProjectDetailScreen(
                            key: ValueKey(selected.id),
                            project: selected,
                            embedded: true,
                          ),
                  ),
                ],
              );
            }
            return _list(provider, showHeader: false);
          },
        ),
      ),
    );
  }
}
