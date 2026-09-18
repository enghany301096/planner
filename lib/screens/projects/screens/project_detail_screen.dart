import 'package:flutter/cupertino.dart';
import 'package:planner/core/utils/app_colors.dart';
import 'package:planner/core/utils/no_animation_route.dart';

import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../providers/project_provider.dart';
import '../../../models/project.dart';

import 'add_task_screen.dart';
import '../widgets/task_card.dart';
import '../../../core/services/pdf_service.dart';
import '../../../providers/settings_provider.dart';
import '../../../models/project_task.dart';
import '../widgets/project_dialog.dart';
import '../widgets/project_members_sheet.dart';
import '../widgets/voice_task_sheet.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  final bool embedded;

  const ProjectDetailScreen({
    super.key,
    required this.project,
    this.embedded = false,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedTaskIds = {};
  String _selectedType = 'all';
  String _selectedPaymentStatus = 'all';
  String _selectedMemberId = 'all';
  bool _filtersExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectProvider>(
        context,
        listen: false,
      ).loadTasks(widget.project.id);
    });
  }

  @override
  void didUpdateWidget(ProjectDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.id == widget.project.id) return;
    _isSelectionMode = false;
    _selectedTaskIds.clear();
    _selectedType = 'all';
    _selectedPaymentStatus = 'all';
    _selectedMemberId = 'all';
    _filtersExpanded = false;
    Provider.of<ProjectProvider>(
      context,
      listen: false,
    ).loadTasks(widget.project.id);
  }

  Future<void> _generatePdf(List<ProjectTask> tasks) async {
    final pdfService = PdfService();
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    await pdfService.printProjectInvoice(
      widget.project,
      tasks,
      context.locale,
      currency: settingsProvider.currency,
      showHourCost: settingsProvider.showHourCostInPrint,
      showTaskType: settingsProvider.showTaskTypeInPrint,
      showTaskTime: settingsProvider.showTaskTimeInPrint,
      showSubtasks: settingsProvider.showSubtasksInPrint,
    );
  }

  Future<void> _sharePdf(
    List<ProjectTask> tasks, {
    Rect? sharePositionOrigin,
  }) async {
    final pdfService = PdfService();
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    await pdfService.shareProjectInvoice(
      widget.project,
      tasks,
      context.locale,
      currency: settingsProvider.currency,
      showHourCost: settingsProvider.showHourCostInPrint,
      showTaskType: settingsProvider.showTaskTypeInPrint,
      showTaskTime: settingsProvider.showTaskTimeInPrint,
      showSubtasks: settingsProvider.showSubtasksInPrint,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  void _confirmArchive(BuildContext context, {Set<String>? ids}) {
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    final eligible = provider
        .getTasks(widget.project.id)
        .where((t) => t.canArchive)
        .where((t) => ids == null || ids.contains(t.id))
        .length;

    if (eligible == 0) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('archiveTasks'.tr()),
          content: Text('onlyCompletedPaidCanArchive'.tr()),
          actions: [
            CupertinoDialogAction(
              child: Text('ok'.tr()),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('archiveTasks'.tr()),
        content: Text(
          'archiveTasksConfirm'.tr(namedArgs: {'count': '$eligible'}),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('cancel'.tr()),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: Text('archiveAction'.tr()),
            onPressed: () {
              provider.archiveTasks(widget.project.id, ids: ids);
              Navigator.pop(context);
              if (_isSelectionMode) {
                setState(() {
                  _isSelectionMode = false;
                  _selectedTaskIds.clear();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProject(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('deleteProject'.tr()),
        content: Text('deleteProjectConfirm'.tr()),
        actions: [
          CupertinoDialogAction(
            child: Text('cancel'.tr()),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('delete'.tr()),
            onPressed: () {
              Provider.of<ProjectProvider>(
                context,
                listen: false,
              ).deleteProject(widget.project.id);
              Navigator.pop(context); // Close dialog
              if (!widget.embedded && Navigator.of(context).canPop()) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  bool get _hasFilters =>
      _selectedType != 'all' ||
      _selectedPaymentStatus != 'all' ||
      _selectedMemberId != 'all';

  int get _activeFilterCount =>
      (_selectedType != 'all' ? 1 : 0) +
      (_selectedPaymentStatus != 'all' ? 1 : 0) +
      (_selectedMemberId != 'all' ? 1 : 0);

  void _clearFilters() {
    setState(() {
      _selectedType = 'all';
      _selectedPaymentStatus = 'all';
      _selectedMemberId = 'all';
    });
  }

  Widget _buildFilters() {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 4),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: () =>
                  setState(() => _filtersExpanded = !_filtersExpanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    _filtersExpanded
                        ? FontAwesomeIcons.chevronUp
                        : FontAwesomeIcons.sliders,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text('filterProjects'.tr()),
                  if (_hasFilters) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _activeFilterCount.toString(),
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          crossFadeState: _filtersExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _buildFilterPanel(),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildFilterPanel() {
    final members = context.watch<ProjectProvider>().getMembers(
      widget.project.id,
    );
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.elevatedBackground(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.separator(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'all'.tr(),
                  isSelected: _selectedType == 'all',
                  onTap: () => setState(() => _selectedType = 'all'),
                ),
                _buildFilterChip(
                  label: 'newFeature'.tr(),
                  isSelected: _selectedType == 'newFeature',
                  onTap: () => setState(() => _selectedType = 'newFeature'),
                ),
                _buildFilterChip(
                  label: 'bug'.tr(),
                  isSelected: _selectedType == 'bug',
                  onTap: () => setState(() => _selectedType = 'bug'),
                ),
                _buildFilterChip(
                  label: 'enhancement'.tr(),
                  isSelected: _selectedType == 'enhancement',
                  onTap: () => setState(() => _selectedType = 'enhancement'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'all'.tr(),
                  isSelected: _selectedPaymentStatus == 'all',
                  onTap: () => setState(() => _selectedPaymentStatus = 'all'),
                ),
                _buildFilterChip(
                  label: 'paid'.tr(),
                  isSelected: _selectedPaymentStatus == 'paid',
                  onTap: () => setState(() => _selectedPaymentStatus = 'paid'),
                ),
                _buildFilterChip(
                  label: 'unpaid'.tr(),
                  isSelected: _selectedPaymentStatus == 'unpaid',
                  onTap: () =>
                      setState(() => _selectedPaymentStatus = 'unpaid'),
                ),
              ],
            ),
          ),
          if (members.isNotEmpty) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'allMembers'.tr(),
                    isSelected: _selectedMemberId == 'all',
                    onTap: () => setState(() => _selectedMemberId = 'all'),
                  ),
                  ...members.map(
                    (m) => _buildFilterChip(
                      label: m.name,
                      isSelected: _selectedMemberId == m.id,
                      onTap: () => setState(() => _selectedMemberId = m.id),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_hasFilters)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: CupertinoButton(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
                onPressed: _clearFilters,
                child: Text('clearFilters'.tr()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? CupertinoColors.activeBlue
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? CupertinoColors.white : CupertinoColors.label,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        final project = provider.projects.firstWhere(
          (p) => p.id == widget.project.id,
          orElse: () => widget.project,
        );
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(project.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isSelectionMode) ...[
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const FaIcon(FontAwesomeIcons.userGroup, size: 18),
                    onPressed: () =>
                        ProjectMembersSheet.show(context, widget.project.id),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const FaIcon(FontAwesomeIcons.penToSquare, size: 20),
                    onPressed: () =>
                        ProjectDialog.show(context, project: project),
                  ),
                  if (provider.archivableCount(widget.project.id) > 0)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const FaIcon(
                        FontAwesomeIcons.boxArchive,
                        size: 18,
                      ),
                      onPressed: () => _confirmArchive(context),
                    ),
                ],
                if (_isSelectionMode) ...[
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const FaIcon(
                      FontAwesomeIcons.trashCan,
                      color: CupertinoColors.destructiveRed,
                      size: 20,
                    ),
                    onPressed: () {
                      if (_selectedTaskIds.isEmpty) return;
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: Text('deleteTasks'.tr()),
                          content: Text('deleteTasksConfirm'.tr()),
                          actions: [
                            CupertinoDialogAction(
                              child: Text('cancel'.tr()),
                              onPressed: () => Navigator.pop(context),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              child: Text('delete'.tr()),
                              onPressed: () {
                                final provider = Provider.of<ProjectProvider>(
                                  context,
                                  listen: false,
                                );
                                for (var id in _selectedTaskIds) {
                                  provider.deleteTask(id, widget.project.id);
                                }
                                setState(() {
                                  _isSelectionMode = false;
                                  _selectedTaskIds.clear();
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      size: 20,
                      color: CupertinoColors.activeGreen,
                    ),
                    onPressed: () {
                      if (_selectedTaskIds.isEmpty) return;
                      final provider = Provider.of<ProjectProvider>(
                        context,
                        listen: false,
                      );
                      final allTasks = provider.getTasks(widget.project.id);
                      final selectedTasks = allTasks
                          .where((t) => _selectedTaskIds.contains(t.id))
                          .toList();
                      if (selectedTasks.isNotEmpty) {
                        _sharePdf(
                          selectedTasks,
                          sharePositionOrigin: _shareOrigin(context),
                        );
                        setState(() {
                          _isSelectionMode = false;
                          _selectedTaskIds.clear();
                        });
                      }
                    },
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const FaIcon(FontAwesomeIcons.print, size: 20),
                    onPressed: () {
                      if (_selectedTaskIds.isEmpty) return;
                      final provider = Provider.of<ProjectProvider>(
                        context,
                        listen: false,
                      );
                      final allTasks = provider.getTasks(widget.project.id);
                      final selectedTasks = allTasks
                          .where((t) => _selectedTaskIds.contains(t.id))
                          .toList();
                      if (selectedTasks.isNotEmpty) {
                        _generatePdf(selectedTasks);
                        setState(() {
                          _isSelectionMode = false;
                          _selectedTaskIds.clear();
                        });
                      }
                    },
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const FaIcon(FontAwesomeIcons.boxArchive, size: 18),
                    onPressed: () {
                      if (_selectedTaskIds.isEmpty) return;
                      _confirmArchive(
                        context,
                        ids: Set<String>.from(_selectedTaskIds),
                      );
                    },
                  ),
                ],
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(_isSelectionMode ? 'cancel'.tr() : 'select'.tr()),
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = !_isSelectionMode;
                      _selectedTaskIds.clear();
                    });
                  },
                ),
                if (!_isSelectionMode)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const FaIcon(FontAwesomeIcons.trashCan, size: 20),
                    onPressed: () => _confirmDeleteProject(context),
                  ),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    if (project.customer != null &&
                        project.customer!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            project.customer!,
                            style: const TextStyle(
                              color: CupertinoColors.secondaryLabel,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    _buildFilters(),
                    Expanded(
                      child: Consumer<ProjectProvider>(
                        builder: (_, provider, child) {
                          var tasks = provider.activeTasks(widget.project.id);

                          // Apply Filters
                          if (_selectedType != 'all') {
                            tasks = tasks
                                .where((t) => t.type == _selectedType)
                                .toList();
                          }

                          if (_selectedPaymentStatus != 'all') {
                            final isPaidFilter =
                                _selectedPaymentStatus == 'paid';
                            tasks = tasks
                                .where((t) => t.isPaid == isPaidFilter)
                                .toList();
                          }

                          if (_selectedMemberId != 'all') {
                            tasks = tasks
                                .where(
                                  (t) =>
                                      t.assigneeIds.contains(_selectedMemberId),
                                )
                                .toList();
                          }

                          if (tasks.isEmpty) {
                            return Center(child: Text('noData'.tr()));
                          }

                          return ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (_, index) {
                              final task = tasks[index];
                              return TaskCard(
                                task: task,
                                isSelectionMode: _isSelectionMode,
                                selectedTaskIds: _selectedTaskIds,
                                onTap: () {
                                  if (_isSelectionMode) {
                                    setState(() {
                                      if (_selectedTaskIds.contains(task.id)) {
                                        _selectedTaskIds.remove(task.id);
                                      } else {
                                        _selectedTaskIds.add(task.id);
                                      }
                                    });
                                  } else {
                                    Navigator.push(
                                      context,
                                      NoAnimationPageRoute(
                                        builder: (_) => AddTaskScreen(
                                          projectId: widget.project.id,
                                          task: task,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoButton.filled(
                              padding: EdgeInsets.zero,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(CupertinoIcons.add, size: 18),
                                  const SizedBox(width: 6),
                                  Text('addTask'.tr()),
                                ],
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  NoAnimationPageRoute(
                                    builder: (_) => AddTaskScreen(
                                      projectId: widget.project.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              showCupertinoModalPopup(
                                context: context,
                                builder: (_) => VoiceTaskSheet(
                                  projectId: widget.project.id,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8B5CF6),
                                    Color(0xFFEC4899),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEC4899)
                                        .withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    CupertinoIcons.mic_fill,
                                    color: CupertinoColors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'voiceCreate'.tr(),
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Floating Share/Print buttons for all tasks
                if (!_isSelectionMode)
                  Consumer<ProjectProvider>(
                    builder: (context, provider, _) {
                      final tasks = provider.activeTasks(widget.project.id);
                      if (tasks.isEmpty) return const SizedBox.shrink();

                      return Positioned(
                        bottom: 80,
                        right: 16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => _sharePdf(
                                tasks,
                                sharePositionOrigin: _shareOrigin(context),
                              ),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: CupertinoColors.activeGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.whatsapp,
                                    color: CupertinoColors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => _generatePdf(tasks),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey.withValues(
                                    alpha: 0.8,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.print,
                                    color: CupertinoColors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Rect? _shareOrigin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}
