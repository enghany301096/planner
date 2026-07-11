import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:masrofy/models/project_task.dart';
import 'package:masrofy/providers/project_provider.dart';
import 'package:masrofy/providers/wallet_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.onTap,
    required this.task,
    this.isSelectionMode = false,
    this.selectedTaskIds = const {},
  });
  final Function()? onTap;
  final bool isSelectionMode;
  final Set<String> selectedTaskIds;
  final ProjectTask task;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    if (widget.task.isTimerRunning) {
      _startTicker();
    }
  }

  @override
  void didUpdateWidget(TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.isTimerRunning != oldWidget.task.isTimerRunning) {
      if (widget.task.isTimerRunning) {
        _startTicker();
      } else {
        _stopTicker();
      }
    }
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }

  void _startTicker() {
    _stopTicker();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    int currentSeconds = task.timeSpentInSeconds;
    if (task.isTimerRunning && task.lastStartTime != null) {
      currentSeconds += DateTime.now()
          .difference(task.lastStartTime!)
          .inSeconds;
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border:
              widget.isSelectionMode && widget.selectedTaskIds.contains(task.id)
              ? Border.all(color: CupertinoColors.activeBlue, width: 2)
              : null,
        ),
        child: Row(
          children: [
            if (widget.isSelectionMode)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: FaIcon(
                  widget.selectedTaskIds.contains(task.id)
                      ? FontAwesomeIcons.solidCircleCheck
                      : FontAwesomeIcons.circle,
                  color: widget.selectedTaskIds.contains(task.id)
                      ? CupertinoColors.activeBlue
                      : CupertinoColors.systemGrey,
                  size: 20,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${task.cost} ${task.currency.tr()}',
                            style: const TextStyle(
                              color: CupertinoColors.systemGreen,
                            ),
                          ),
                          if (task.estimatedTime > 0)
                            Text(
                              '${task.estimatedTime} ${'hours'.tr()}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: task.status == 'done'
                              ? CupertinoColors.systemGreen.withValues(alpha: 0.1)
                              : (task.status == 'inProgress'
                                    ? CupertinoColors.systemOrange.withValues(
                                        alpha: 0.1,
                                      )
                                    : CupertinoColors.systemGrey.withValues(
                                        alpha: 0.1,
                                      )),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          task.status.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: task.status == 'done'
                                ? CupertinoColors.systemGreen
                                : (task.status == 'inProgress'
                                      ? CupertinoColors.systemOrange
                                      : CupertinoColors.systemGrey),
                          ),
                        ),
                      ),
                      Spacer(),
                      // Timer Display
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: task.isTimerRunning
                              ? CupertinoColors.activeBlue.withValues(alpha: 0.1)
                              : CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: task.isTimerRunning
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.systemGrey4,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.clock,
                              size: 12,
                              color: task.isTimerRunning
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.systemGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(currentSeconds),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFeatures: [FontFeature.tabularFigures()],
                                color: task.isTimerRunning
                                    ? CupertinoColors.activeBlue
                                    : CupertinoColors.label,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Timer Button
                      GestureDetector(
                        onTap: () {
                          // Prevent triggering row tap
                          Provider.of<ProjectProvider>(
                            context,
                            listen: false,
                          ).toggleTaskTimer(task.id, task.projectId);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: task.isTimerRunning
                                ? CupertinoColors.destructiveRed.withValues(
                                    alpha: 0.1,
                                  )
                                : CupertinoColors.activeBlue.withValues(alpha: 0.1),
                          ),
                          child: FaIcon(
                            task.isTimerRunning
                                ? FontAwesomeIcons.stop
                                : FontAwesomeIcons.play,
                            size: 12,
                            color: task.isTimerRunning
                                ? CupertinoColors.destructiveRed
                                : CupertinoColors.activeBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (task.timerStartAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 2, right: 2),
                        child: FaIcon(
                          FontAwesomeIcons.clockRotateLeft,
                          size: 10,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${'timerStart'.tr()}: ${DateFormat('HH:mm', 'en').format(task.timerStartAt!)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      if (task.timerEndAt != null) ...[
                        Text(
                          ' - ${'timerEnd'.tr()}: ${DateFormat('HH:mm', 'en').format(task.timerEndAt!)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (task.details.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        task.details,
                        maxLines: 2,
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  if (task.subTasks.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final doneCount = task.subTasks
                            .where((s) => s['isDone'] == true)
                            .length;
                        final totalCount = task.subTasks.length;
                        final progress = doneCount / totalCount;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'todoList'.tr(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                                Text(
                                  '$doneCount/$totalCount (${(progress * 100).toStringAsFixed(0)}%)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.activeBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 6,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemGrey6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: progress == 1.0
                                        ? CupertinoColors.activeGreen
                                        : CupertinoColors.activeBlue,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      buildTypeTag(task.type),
                      buildPaymentTag(context, task),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentTag(BuildContext context, ProjectTask task) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, _) {
        final paymentMethod = walletProvider.paymentMethods
            .where((m) => m.id == task.paymentMethodId)
            .firstOrNull;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: task.isPaid
                ? CupertinoColors.systemGreen.withValues(alpha: 0.1)
                : CupertinoColors.systemOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                task.isPaid
                    ? FontAwesomeIcons.circleCheck
                    : FontAwesomeIcons.circleInfo,
                size: 10,
                color: task.isPaid
                    ? CupertinoColors.systemGreen
                    : CupertinoColors.systemOrange,
              ),
              const SizedBox(width: 4),
              Text(
                task.isPaid
                    ? (paymentMethod?.name ?? 'paid'.tr())
                    : 'unpaid'.tr(),
                style: TextStyle(
                  fontSize: 10,
                  color: task.isPaid
                      ? CupertinoColors.systemGreen
                      : CupertinoColors.systemOrange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget buildTypeTag(String type) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      type.tr(),
      style: const TextStyle(fontSize: 12, color: CupertinoColors.systemBlue),
    ),
  );
}
