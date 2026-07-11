import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show LinearProgressIndicator, AlwaysStoppedAnimation, Color;
import 'package:masrofy/core/utils/app_colors.dart';
import 'package:masrofy/core/utils/no_animation_route.dart';
import 'package:masrofy/providers/expenses_provider.dart';
import 'package:masrofy/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/locale_provider.dart';
import '../settings/settings_screen.dart';
import '../expenses/expenses_screen.dart';
import '../projects/screens/projects_screen.dart';
import '../projects/screens/project_detail_screen.dart';
import '../projects/widgets/project_card.dart';
import '../projects/widgets/task_card.dart';
import '../../providers/project_provider.dart';
import 'widgets/usd_rate_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _loadDataFuture;
  bool _isDrawerOpen = false;

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Wire expense auto-creation callback
    final projectProvider =
        Provider.of<ProjectProvider>(context, listen: false);
    final expensesProvider =
        Provider.of<ExpensesProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    projectProvider.onTaskPaidChanged = (task, isPaid) async {
      if (!settings.isExpensesEnabled) return;
      if (isPaid) {
        await expensesProvider.addExpenseFromTask(task, settings.currency);
      } else {
        await expensesProvider.removeExpenseForTask(task.id);
      }
    };
  }

  Future<void> _loadData() async {
    await Future.wait([
      Provider.of<ProjectProvider>(context, listen: false).loadData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocaleProvider, ProjectProvider>(
      builder: (_, localeProvider, projectProvider, child) {
        return FutureBuilder(
          future: _loadDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CupertinoPageScaffold(
                child: Center(child: CupertinoActivityIndicator()),
              );
            }

            return Stack(
              children: [
                // Main Content
                CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    leading: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _toggleDrawer,
                      child: const FaIcon(FontAwesomeIcons.bars, size: 22),
                    ),
                    middle: Text('appName'.tr()),
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const FaIcon(FontAwesomeIcons.briefcase, size: 20),
                      onPressed: () {
                        Navigator.of(context).push(
                          NoAnimationPageRoute(
                            builder: (_) => const ProjectsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  child: SafeArea(
                    child: Consumer<SettingsProvider>(
                      builder: (context, settings, child) {
                        // Get active timers from all projects
                        final activeTasks = projectProvider.projects
                            .expand(
                              (p) => projectProvider
                                  .getTasks(p.id)
                                  .where((t) => t.isTimerRunning),
                            )
                            .toList();

                        return ListView(
                          padding: const EdgeInsets.only(bottom: 100),
                          children: [
                            _buildWelcomeHeader(context),
                            const UsdRateWidget(),
                            _buildEarningsDashboard(
                              context,
                              projectProvider,
                              settings,
                            ),
                            _buildTaskProgressSummary(context, projectProvider),
                            if (settings.isExpensesEnabled)
                              _buildExpensesPreview(context),

                            if (activeTasks.isNotEmpty) ...[
                              _buildSectionHeader('activeTimers'.tr()),
                              ...activeTasks.map(
                                (task) => TaskCard(
                                  task: task,
                                  onTap: () {
                                    final project = projectProvider.projects
                                        .firstWhere(
                                          (p) => p.id == task.projectId,
                                        );
                                    Navigator.of(context).push(
                                      NoAnimationPageRoute(
                                        builder: (_) => ProjectDetailScreen(
                                          project: project,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],

                            if (projectProvider.projects.isNotEmpty) ...[
                              _buildSectionHeader(
                                'recentProjects'.tr(),
                                onSeeAll: () {
                                  Navigator.of(context).push(
                                    NoAnimationPageRoute(
                                      builder: (_) => const ProjectsScreen(),
                                    ),
                                  );
                                },
                              ),
                              ...projectProvider.projects
                                  .take(3)
                                  .map(
                                    (project) => ProjectCard(
                                      project: project,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          NoAnimationPageRoute(
                                            builder: (_) => ProjectDetailScreen(
                                              project: project,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Drawer Overlay
                if (_isDrawerOpen)
                  GestureDetector(
                    onTap: _toggleDrawer,
                    child: Container(
                      color: CupertinoColors.black.withValues(alpha: 0.3),
                    ),
                  ),

                // Drawer Pane
                _buildDrawer(context),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildExpensesPreview(BuildContext context) {
    return Consumer2<ExpensesProvider, SettingsProvider>(
      builder: (_, expProvider, settings, __) {
        final recentExpenses = expProvider.recentExpenses(3);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: CupertinoColors.separator.resolveFrom(context),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'recentExpenses'.tr(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    onPressed: () => Navigator.of(context).push(
                      NoAnimationPageRoute(
                          builder: (_) => const ExpensesScreen()),
                    ),
                    child: Text('viewAll'.tr(),
                        style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: AppColors.expenseGradient),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${settings.currency} ${expProvider.totalExpenses.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${expProvider.expenses.length} ${'expenseRecords'.tr()}',
                    style: const TextStyle(
                        fontSize: 12, color: CupertinoColors.systemGrey),
                  ),
                ],
              ),
              if (recentExpenses.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...recentExpenses.map((e) {
                  final cat = expProvider.getCategoryById(e.categoryId);
                  final catColor =
                      cat != null ? Color(cat.color) : AppColors.expensePrimary;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: catColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.title,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${e.currency} ${e.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: catColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ).animate().fadeIn(delay: 150.ms, duration: 400.ms);
      },
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'welcomeBack'.tr(),
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'dashboardOverview'.tr(),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsDashboard(
    BuildContext context,
    ProjectProvider provider,
    SettingsProvider settings,
  ) {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildEarningCard(
            context,
            'totalEarnings'.tr(),
            provider.totalEarnings,
            settings.currency,
            [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
            FontAwesomeIcons.calculator,
          ),
          _buildEarningCard(
            context,
            'collected'.tr(),
            provider.paidEarnings,
            settings.currency,
            [const Color(0xFF10B981), const Color(0xFF34D399)],
            FontAwesomeIcons.circleCheck,
          ),
          _buildEarningCard(
            context,
            'pendingPayment'.tr(),
            provider.unpaidEarnings,
            settings.currency,
            [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
            FontAwesomeIcons.clockRotateLeft,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningCard(
    BuildContext context,
    String title,
    double amount,
    String currency,
    List<Color> colors,
    FaIconData icon,
  ) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              FaIcon(
                icon,
                color: CupertinoColors.white.withValues(alpha: 0.8),
                size: 20,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$currency${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'updatedJustNow'.tr(),
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskProgressSummary(
    BuildContext context,
    ProjectProvider provider,
  ) {
    final total = provider.totalTasksCount;
    final completed = provider.completedTasksCount;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'tasksProgress'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed / $total ${'tasksCompleted'.tr()}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 12,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: CupertinoColors.systemGrey6,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  CupertinoColors.activeBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSimpleStat(
                'totalTasks'.tr(),
                total.toString(),
                CupertinoColors.activeBlue,
              ),
              _buildSimpleStat(
                'pending'.tr(),
                provider.pendingTasksCount.toString(),
                CupertinoColors.systemOrange,
              ),
              _buildSimpleStat(
                'workingOn'.tr(),
                provider.inProgressTasksCount.toString(),
                CupertinoColors.systemGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (onSeeAll != null)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onSeeAll,
              child: Text('viewAll'.tr(), style: const TextStyle(fontSize: 14)),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return AnimatedPositionedDirectional(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      start: _isDrawerOpen ? 0 : -280,
      top: 0,
      bottom: 0,
      width: 280,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground
              .resolveFrom(context)
              .withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: SafeArea(
              child: Column(
                children: [
                  _buildDrawerHeader(context),
                  const SizedBox(height: 20),
                  _buildDrawerItem(
                    icon: FontAwesomeIcons.briefcase,
                    title: 'projects'.tr(),
                    onTap: () {
                      _toggleDrawer();
                      Navigator.of(context).push(
                        NoAnimationPageRoute(
                          builder: (_) => const ProjectsScreen(),
                        ),
                      );
                    },
                  ),
                  Consumer<SettingsProvider>(
                    builder: (_, settings, __) => settings.isExpensesEnabled
                        ? _buildDrawerItem(
                            icon: FontAwesomeIcons.receipt,
                            title: 'expenses'.tr(),
                            onTap: () {
                              _toggleDrawer();
                              Navigator.of(context).push(
                                NoAnimationPageRoute(
                                  builder: (_) => const ExpensesScreen(),
                                ),
                              );
                            },
                          )
                        : const SizedBox.shrink(),
                  ),
                  _buildDrawerItem(
                    icon: FontAwesomeIcons.gear,
                    title: 'settings'.tr(),
                    onTap: () {
                      _toggleDrawer();
                      Navigator.of(context).push(
                        NoAnimationPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'v 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: CupertinoColors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const FaIcon(
              FontAwesomeIcons.checkToSlot,
              color: CupertinoColors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'appName'.tr(),
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required FaIconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return CupertinoListTile(
      leading: FaIcon(icon, size: 20, color: CupertinoColors.systemGrey),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}

// Add these to your translations if they don't exist:
// "welcomeBack": "Welcome Back 👋",
// "dashboardOverview": "Dashboard",
// "collected": "Collected",
// "pendingPayment": "Pending",
// "updatedJustNow": "Updated just now",
// "tasksProgress": "Tasks Progress",
// "tasksCompleted": "Tasks completed",
// "workingOn": "In Progress",
// "pending": "Pending"
