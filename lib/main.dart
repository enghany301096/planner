import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:planner/firebase_options.dart';
import 'package:planner/providers/income_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:upgrader/upgrader.dart';
import 'core/utils/app_layout.dart';
import 'core/utils/app_thems.dart';
import 'providers/settings_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/project_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/expenses_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';
import 'screens/splash/splash_screen.dart';
import 'core/widgets/restart_widget.dart';
import 'core/widgets/app_lock_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _registerFcmHandlers();
  } catch (e) {
    log('Firebase initialization failed: $e');
  }
  try {
    await EasyLocalization.ensureInitialized();
    await NotificationService().init();
  } catch (e) {
    log('Initialization Error: $e');
  }

  runApp(
    RestartWidget(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => WalletProvider()..loadData()),
          ChangeNotifierProvider(create: (_) => ProjectProvider()..loadData()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => ExpensesProvider()..loadData()),
          ChangeNotifierProvider(create: (_) => IncomeProvider()..loadData()),
        ],
        child: EasyLocalization(
          supportedLocales: const [Locale('ar'), Locale('en')],
          path: 'assets/translations',
          fallbackLocale: const Locale('ar'),
          child: const PlannerApp(),
        ),
      ),
    ),
  );
}

class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.select<SettingsProvider, bool>(
      (s) => s.isDarkMode,
    );
    return UpgradeAlert(
      dialogStyle: UpgradeDialogStyle.cupertino,
      child: CupertinoApp(
        title: 'appName'.tr(),
        debugShowCheckedModeBanner: false,
        theme: isDarkMode ? AppThems.darkTheme() : AppThems.lightTheme(),
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        home: const SplashScreen(),
        scrollBehavior: const AppScrollBehavior(),
        builder: (context, child) => AppLayoutHost(
          child: AppLockGate(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}

void _registerFcmHandlers() {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      FirebaseMessaging.onMessage.listen((message) {
        final title = message.notification?.title ?? message.data['title'];
        final body = message.notification?.body ?? message.data['body'];
        if (title != null || body != null) {
          NotificationService().showNotification(
            title: title ?? 'Smart Planner',
            body: body ?? '',
          );
        }
      });
    } catch (e) {
      log('FCM setup failed: $e');
    }
  });
}
