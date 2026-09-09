import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        LinearProgressIndicator,
        AlwaysStoppedAnimation,
        Color,
        Theme,
        ThemeData;
import 'package:planner/core/utils/app_colors.dart';
import 'package:planner/core/utils/app_layout.dart';
import 'package:planner/core/utils/no_animation_route.dart';
import 'package:planner/providers/expenses_provider.dart';
import 'package:planner/providers/income_provider.dart';
import 'package:planner/providers/settings_provider.dart';
import 'package:planner/providers/wallet_provider.dart';
import 'package:planner/screens/income/income_screen.dart';
import 'package:planner/screens/shell/app_shell.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/project_provider.dart';
import '../expenses/expenses_screen.dart';
import '../projects/screens/projects_screen.dart';
import '../../models/project.dart';
import '../projects/screens/project_detail_screen.dart';
import '../projects/widgets/project_card.dart';
import '../projects/widgets/task_card.dart';
import 'widgets/home_summary_cards.dart';
import 'widgets/usd_rate_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    projectProvider.onTaskPaidChanged = (task, isPaid) async {
      if (isPaid) {
        await incomeProvider.addIncomeFromTask(task, settings.currency);
      } else {
        await incomeProvider.removeIncomeForTask(task.id);
      }
    };
  }

  void _openProjects() {
    AppShellScope.open(context, AppSection.projects, const ProjectsScreen());
  }

  void _openIncome() {
    AppShellScope.open(context, AppSection.income, const IncomeScreen());
  }

  void _openExpenses() {
    AppShellScope.open(context, AppSection.expenses, const ExpensesScreen());
  }

  void _openProject(Project project) {
    Navigator.of(context).push(
      NoAnimationPageRoute(
        builder: (_) => ProjectDetailScreen(project: project),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout.of(context);
    return Consumer<ProjectProvider>(
      builder: (_, projectProvider, child) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: widget.onMenuTap == null
                ? null
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: widget.onMenuTap,
                    child: const FaIcon(FontAwesomeIcons.bars, size: 22),
                  ),
            middle: Text('appName'.tr()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Selector<SettingsProvider, bool>(
                  selector: (_, s) => s.hideAmounts,
                  builder: (_, hideAmounts, _) => CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => context
                        .read<SettingsProvider>()
                        .setHideAmounts(!hideAmounts),
                    child: FaIcon(
                      hideAmounts
                          ? FontAwesomeIcons.eyeSlash
                          : FontAwesomeIcons.eye,
                      size: 18,
                    ),
                  ),
                ),
                if (!layout.hasSidebar)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _openProjects,
                    child: const FaIcon(FontAwesomeIcons.briefcase, size: 20),
                  ),
              ],
            ),
          ),
          child: SafeArea(
            child: Selector<SettingsProvider, (bool, double, bool)>(
              selector: (_, s) =>
                  (s.hideAmounts, s.cardPadding, s.isExpensesEnabled),
              builder: (context, value, child) {
                final hideAmounts = value.$1;
                final pad = value.$2;
                final expensesEnabled = value.$3;
                final activeTasks = projectProvider.projects
                    .expand(
                      (p) => projectProvider
                          .getTasks(p.id)
                          .where((t) => t.isTimerRunning),
                    )
                    .toList();

                final incomePreview = _buildIncomePreview(context, pad);
                final expensesPreview = expensesEnabled
                    ? _buildExpensesPreview(context, pad)
                    : null;

                return AppLayout.constrain(
                  ListView(
                    padding: const EdgeInsets.only(bottom: 100),
                    children: [
                      _buildWelcomeHeader(context),
                      if (!hideAmounts) const UsdRateWidget(),
                      const HomeSummaryCards(),
                      _buildTaskProgressSummary(context, projectProvider, pad),
                      if (layout.isExpanded && expensesPreview != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: incomePreview),
                              Expanded(child: expensesPreview),
                            ],
                          ),
                        )
                      else ...[
                        incomePreview,
                        ?expensesPreview,
                      ],
                      _buildWalletStrip(context, layout),
                      if (activeTasks.isNotEmpty) ...[
                        _buildSectionHeader('activeTimers'.tr()),
                        ...activeTasks.map(
                          (task) => TaskCard(
                            task: task,
                            onTap: () {
                              Project? project;
                              for (final p in projectProvider.projects) {
                                if (p.id == task.projectId) {
                                  project = p;
                                  break;
                                }
                              }
                              if (project == null) return;
                              _openProject(project);
                            },
                          ),
                        ),
                      ],
                      if (projectProvider.projects.isNotEmpty) ...[
                        _buildSectionHeader(
                          'recentProjects'.tr(),
                          onSeeAll: _openProjects,
                        ),
                        ...projectProvider.projects
                            .take(3)
                            .map(
                              (project) => ProjectCard(
                                project: project,
                                onTap: () => _openProject(project),
                              ),
                            ),
                      ],
                    ],
                  ),
                  maxWidth: AppLayout.maxContentWidth,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncomePreview(BuildContext context, double pad) {
    return Consumer2<IncomeProvider, SettingsProvider>(
      builder: (_, incomeProvider, settings, _) {
        final recent = incomeProvider.recentIncomes(3);
        final total = incomeProvider.incomes.fold<double>(
          0,
          (sum, e) => sum + settings.convert(e.amount, e.currency),
        );
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.separator(context), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow(context),
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
                    'recentIncome'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    onPressed: _openIncome,
                    child: Text(
                      'viewAll'.tr(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              Text(
                settings.formatMoney(total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              if (recent.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...recent.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(e.title, overflow: TextOverflow.ellipsis),
                        ),
                        Text(
                          settings.formatMoney(e.amount, e.currency),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletStrip(BuildContext context, AppLayout layout) {
    return Consumer3<WalletProvider, IncomeProvider, ExpensesProvider>(
      builder: (_, wallet, income, expenses, _) {
        if (wallet.paymentMethods.isEmpty) return const SizedBox.shrink();
        final settings = Provider.of<SettingsProvider>(context, listen: false);
        final chips = wallet.paymentMethods.map((method) {
          final balance = wallet.balanceFor(
            method,
            incomes: income.incomes,
            expenses: expenses.expenses,
            settings: settings,
          );
          return Container(
            width: 180,
            margin: EdgeInsets.only(
              right: layout.hasSidebar ? 0 : 12,
              bottom: layout.hasSidebar ? 12 : 0,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(method.color).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(method.color).withValues(alpha: 0.25),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  settings.formatMoney(balance),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList();

        if (layout.hasSidebar) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Wrap(spacing: 12, runSpacing: 4, children: chips),
          );
        }

        return Container(
          height: 92,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: chips,
          ),
        );
      },
    );
  }

  Widget _buildExpensesPreview(BuildContext context, double pad) {
    return Consumer2<ExpensesProvider, SettingsProvider>(
      builder: (_, expProvider, settings, _) {
        final recentExpenses = expProvider.recentExpenses(3);
        final card = Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.separator(context), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow(context),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    onPressed: _openExpenses,
                    child: Text(
                      'viewAll'.tr(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.expenseGradient,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      settings.formatMoney(
                        expProvider.expenses.fold<double>(
                          0,
                          (sum, e) =>
                              sum + settings.convert(e.amount, e.currency),
                        ),
                      ),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryLabel(context),
                    ),
                  ),
                ],
              ),
              if (recentExpenses.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...recentExpenses.map((e) {
                  final cat = expProvider.getCategoryById(e.categoryId);
                  final catColor = cat != null
                      ? Color(cat.color)
                      : AppColors.expensePrimary;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: catColor,
                            shape: BoxShape.circle,
                          ),
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
                          settings.formatMoney(e.amount, e.currency),
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
        );
        if (AppLayout.of(context).hasSidebar) return card;
        return card.animate().fadeIn(delay: 150.ms, duration: 400.ms);
      },
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'welcomeBack'.tr(),
            style: TextStyle(
              fontSize: 15,
              color: AppColors.secondaryLabel(context),
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

  Widget _buildTaskProgressSummary(
    BuildContext context,
    ProjectProvider provider,
    double pad,
  ) {
    final total = provider.totalTasksCount;
    final completed = provider.completedTasksCount;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.separator(context), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow(context),
            blurRadius: 16,
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
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryLabel(context),
                    ),
                  ),
                ],
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: CupertinoTheme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 12,
              child: Theme(
                data: AppColors.isDark(context)
                    ? ThemeData.dark()
                    : ThemeData.light(),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.elevatedBackground(context),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    CupertinoTheme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSimpleStat(
                context,
                'totalTasks'.tr(),
                total.toString(),
                CupertinoColors.activeBlue,
              ),
              _buildSimpleStat(
                context,
                'pending'.tr(),
                provider.pendingTasksCount.toString(),
                CupertinoColors.systemOrange,
              ),
              _buildSimpleStat(
                context,
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

  Widget _buildSimpleStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
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
          style: TextStyle(
            fontSize: 12,
            color: AppColors.secondaryLabel(context),
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
}
