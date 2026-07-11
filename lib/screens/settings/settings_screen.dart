import 'package:flutter/cupertino.dart';
import 'package:masrofy/core/utils/no_animation_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/services/database_backup_service.dart';
import '../../core/services/database_helper.dart';
import 'payment_methods_screen.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/project_provider.dart';
import '../../core/widgets/restart_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('settings'.tr())),
          child: SafeArea(
            child: Consumer<SettingsProvider>(
              builder: (_, settings, child) {
                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Language Selection
                    CupertinoListSection.insetGrouped(
                      margin: EdgeInsets.all(8),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'language'.tr(),
                                style: CupertinoTheme.of(
                                  context,
                                ).textTheme.textStyle,
                              ),
                              CupertinoSlidingSegmentedControl<String>(
                                groupValue: context.locale.languageCode,
                                children: {
                                  'en': Text('english'.tr()),
                                  'ar': Text('arabic'.tr()),
                                },
                                onValueChanged: (value) async {
                                  if (value != null &&
                                      value != context.locale.languageCode) {
                                    await showCupertinoDialog(
                                      context: context,
                                      builder: (_) => CupertinoAlertDialog(
                                        title: Text('changeLanguage'.tr()),
                                        content: Text(
                                          'changeLanguageConfirmation'.tr(),
                                        ),
                                        actions: [
                                          CupertinoDialogAction(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            isDestructiveAction: false,
                                            child: Text('cancel'.tr()),
                                          ),
                                          CupertinoDialogAction(
                                            isDefaultAction: true,
                                            child: Text('ok'.tr()),
                                            onPressed: () async {
                                              // Navigator.pop(context);
                                              await localeProvider.setLocale(
                                                context,
                                                Locale(value),
                                              );
                                              if (context.mounted) {
                                                // Reload providers to update translated data
                                                await Provider.of<
                                                      WalletProvider
                                                    >(context, listen: false)
                                                    .loadData();
                                                if (context.mounted) {
                                                  await Provider.of<
                                                        ProjectProvider
                                                      >(context, listen: false)
                                                      .loadData();
                                                }
                                                if (context.mounted) {
                                                  // Pop the dialog
                                                  Navigator.of(context).pop();
                                                  // Pop back to home to refresh the entire view
                                                  Navigator.of(
                                                    context,
                                                  ).popUntil(
                                                    (route) => route.isFirst,
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // Currency Selection
                    CupertinoListSection.insetGrouped(
                      margin: EdgeInsets.all(8),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'currency'.tr(),
                                style: CupertinoTheme.of(
                                  context,
                                ).textTheme.textStyle,
                              ),
                              CupertinoSlidingSegmentedControl<String>(
                                groupValue: settings.currency,
                                children: {
                                  'L.E': Text('L.E'.tr()),
                                  '\$': Text('USD'.tr()),
                                  'SAR': Text('SAR'.tr()),
                                },
                                onValueChanged: (value) {
                                  if (value != null) {
                                    settings.setCurrency(value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Expenses Currency Selection
                    CupertinoListSection.insetGrouped(
                      margin: EdgeInsets.all(8),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'expensesCurrency'.tr(),
                                          style: CupertinoTheme.of(
                                            context,
                                          ).textTheme.textStyle,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'expensesCurrencySubtitle'.tr(),
                                          style: CupertinoTheme.of(context)
                                              .textTheme
                                              .textStyle
                                              .copyWith(
                                                fontSize: 12,
                                                color:
                                                    CupertinoColors.systemGrey,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CupertinoSlidingSegmentedControl<String>(
                                    groupValue: settings.expensesCurrency,
                                    children: {
                                      'USD': Text('USD'.tr()),
                                      'EGP': Text('EGP'.tr()),
                                    },
                                    onValueChanged: (value) {
                                      if (value != null) {
                                        settings.setExpensesCurrency(value);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Hour Cost
                    CupertinoListSection.insetGrouped(
                      margin: EdgeInsets.all(8),
                      children: [
                        CupertinoListTile(
                          title: Text('hourCost'.tr()),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${settings.hourCost} ${settings.currency}'),
                              const SizedBox(width: 8),
                              const CupertinoListTileChevron(),
                            ],
                          ),
                          onTap: () {
                            final controller = TextEditingController(
                              text: settings.hourCost.toString(),
                            );
                            showCupertinoDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                title: Text('editHourCost'.tr()),
                                content: Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: CupertinoTextField(
                                    controller: controller,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    placeholder: 'enterHourCost'.tr(),
                                  ),
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    child: Text('cancel'.tr()),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  CupertinoDialogAction(
                                    child: Text('save'.tr()),
                                    onPressed: () {
                                      final value =
                                          double.tryParse(controller.text) ??
                                          0.0;
                                      settings.setHourCost(value);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // Biometric Auth
                    CupertinoListSection.insetGrouped(
                      margin: EdgeInsets.all(8),
                      children: [
                        CupertinoListTile(
                          title: Text('biometricAuth'.tr()),
                          subtitle: Text('enableBiometric'.tr()),
                          trailing: CupertinoSwitch(
                            value: settings.isBiometricEnabled,
                            onChanged: (value) {
                              settings.setBiometricEnabled(value);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // Printing Settings
                    CupertinoListSection.insetGrouped(
                      header: Text(
                        'printingSettings'.tr(),
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                      margin: const EdgeInsets.all(8),
                      children: [
                        CupertinoListTile(
                          title: Text('showHourCostInPrint'.tr()),
                          trailing: CupertinoSwitch(
                            value: settings.showHourCostInPrint,
                            onChanged: (value) {
                              settings.setShowHourCostInPrint(value);
                            },
                          ),
                        ),
                        CupertinoListTile(
                          title: Text('showTaskTimeInPrint'.tr()),
                          trailing: CupertinoSwitch(
                            value: settings.showTaskTimeInPrint,
                            onChanged: (value) {
                              settings.setShowTaskTimeInPrint(value);
                            },
                          ),
                        ),
                        CupertinoListTile(
                          title: Text('showTaskTypeInPrint'.tr()),
                          trailing: CupertinoSwitch(
                            value: settings.showTaskTypeInPrint,
                            onChanged: (value) {
                              settings.setShowTaskTypeInPrint(value);
                            },
                          ),
                        ),
                        CupertinoListTile(
                          title: Text('showSubtasksInPrint'.tr()),
                          trailing: CupertinoSwitch(
                            value: settings.showSubtasksInPrint,
                            onChanged: (value) {
                              settings.setShowSubtasksInPrint(value);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // ── Modules ──────────────────────────────────────────────
                    CupertinoListSection.insetGrouped(
                      header: Text(
                        'modules'.tr(),
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                      margin: const EdgeInsets.all(8),
                      children: [
                        CupertinoListTile(
                          leading: const FaIcon(
                            FontAwesomeIcons.receipt,
                            color: CupertinoColors.systemPink,
                            size: 20,
                          ),
                          title: Text('expensesModule'.tr()),
                          subtitle: Text('expensesModuleSubtitle'.tr()),
                          trailing: CupertinoSwitch(
                            value: settings.isExpensesEnabled,
                            onChanged: (value) {
                              settings.setExpensesEnabled(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // ── Dark Mode ─────────────────────────────────────────────
                    CupertinoListSection.insetGrouped(
                      margin: const EdgeInsets.all(8),
                      children: [
                        CupertinoListTile(
                          leading: const Icon(
                            CupertinoIcons.moon_fill,
                            color: CupertinoColors.systemPurple,
                          ),
                          title: Text('darkMode'.tr()),
                          trailing: CupertinoSwitch(
                            value: settings.isDarkMode,
                            onChanged: (value) {
                              settings.setDarkMode(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Payment Methods
                    CupertinoListTile(
                      padding: EdgeInsets.all(0),
                      leading: const FaIcon(
                        FontAwesomeIcons.creditCard,
                        color: CupertinoColors.systemTeal,
                        size: 20,
                      ),
                      title: Text('paymentMethods'.tr()),
                      subtitle: Text('paymentMethodsSubtitle'.tr()),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.push(
                          context,
                          NoAnimationPageRoute(
                            builder: (_) => const PaymentMethodsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Database Backup
                    CupertinoListSection.insetGrouped(
                      header: Text(
                        'databaseBackup'.tr(),
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                      margin: const EdgeInsets.all(8),
                      children: [
                        CupertinoListTile(
                          leading: const FaIcon(
                            FontAwesomeIcons.cloudArrowUp,
                            color: CupertinoColors.systemBlue,
                            size: 20,
                          ),
                          title: Text('exportDatabase'.tr()),
                          subtitle: Text('exportDatabaseSubtitle'.tr()),
                          trailing: const CupertinoListTileChevron(),
                          onTap: () async {
                            try {
                              await DatabaseBackupService.createAndShareBackup();
                              if (context.mounted) {
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: Text(
                                      'done'.tr(),
                                      style: CupertinoTheme.of(context)
                                          .textTheme
                                          .textStyle
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                    ),
                                    content: Text(
                                      'backupSuccess'.tr(),
                                      style: CupertinoTheme.of(context)
                                          .textTheme
                                          .textStyle
                                          .copyWith(fontSize: 14),
                                    ),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: Text('ok'.tr()),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: Text(
                                      'invalidInput'.tr(),
                                      style: CupertinoTheme.of(context)
                                          .textTheme
                                          .textStyle
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                    ),
                                    content: Text(
                                      'backupError'.tr(
                                        namedArgs: {'error': e.toString()},
                                      ),
                                      style: CupertinoTheme.of(context)
                                          .textTheme
                                          .textStyle
                                          .copyWith(fontSize: 14),
                                    ),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: Text('ok'.tr()),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        CupertinoListTile(
                          leading: const FaIcon(
                            FontAwesomeIcons.cloudArrowDown,
                            color: CupertinoColors.systemOrange,
                            size: 20,
                          ),
                          title: Text('importDatabase'.tr()),
                          subtitle: Text('importDatabaseSubtitle'.tr()),
                          trailing: const CupertinoListTileChevron(),
                          onTap: () async {
                            try {
                              bool restored =
                                  await DatabaseBackupService.pickAndRestoreBackup();
                              if (restored && context.mounted) {
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: Text(
                                      'done'.tr(),
                                      style: CupertinoTheme.of(context)
                                          .textTheme
                                          .textStyle
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                    ),
                                    content: Text(
                                      'restoreSuccess'.tr(),
                                      style: CupertinoTheme.of(context)
                                          .textTheme
                                          .textStyle
                                          .copyWith(fontSize: 14),
                                    ),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: Text('ok'.tr()),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          RestartWidget.restartApp(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: Text(
                                      'invalidInput'.tr(),
                                      style: CupertinoTheme.of(context)
                                          .textTheme
                                          .textStyle
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                          ),
                                    ),
                                    content: Text(
                                      'restoreError'.tr(
                                        namedArgs: {'error': e.toString()},
                                      ),
                                      style: CupertinoTheme.of(context)
                                          .textTheme
                                          .textStyle
                                          .copyWith(fontSize: 14),
                                    ),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: Text('ok'.tr()),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Reset Database
                    CupertinoListSection.insetGrouped(
                      margin: const EdgeInsets.all(8),
                      children: [
                        CupertinoListTile(
                          leading: const FaIcon(
                            FontAwesomeIcons.trashCan,
                            color: CupertinoColors.systemRed,
                            size: 20,
                          ),
                          title: Text(
                            'resetDatabase'.tr(),
                            style: const TextStyle(
                              color: CupertinoColors.systemRed,
                            ),
                          ),
                          subtitle: Text('resetDatabaseSubtitle'.tr()),
                          onTap: () {
                            showCupertinoDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                title: Text(
                                  'resetDatabaseConfirmTitle'.tr(),
                                  style: CupertinoTheme.of(context)
                                      .textTheme
                                      .textStyle
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                ),
                                content: Text(
                                  'resetDatabaseConfirmMessage'.tr(),
                                  style: CupertinoTheme.of(
                                    context,
                                  ).textTheme.textStyle.copyWith(fontSize: 14),
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    child: Text('cancel'.tr()),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    child: Text('reset'.tr()),
                                    onPressed: () async {
                                      await DatabaseHelper.instance
                                          .resetDatabase();
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        RestartWidget.restartApp(context);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
