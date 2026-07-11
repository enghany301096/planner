import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:upgrader/upgrader.dart';
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


void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await EasyLocalization.ensureInitialized();
    await NotificationService().init();
    _registerFcmToken();
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
        ],
        child: EasyLocalization(
          supportedLocales: const [Locale('ar'), Locale('en')],
          path: 'assets/translations',
          fallbackLocale: const Locale('ar'),
          child: const MasrofyApp(),
        ),
      ),
    ),
  );
}

class MasrofyApp extends StatelessWidget {
  const MasrofyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocaleProvider, SettingsProvider>(
      builder: (context, localeProvider, settings, child) {
        return UpgradeAlert(
          dialogStyle: UpgradeDialogStyle.cupertino,
          child: CupertinoApp(
            title: 'appName'.tr(),
            debugShowCheckedModeBanner: false,
            // Bug fix #1: wire dark mode setting to the theme
            theme: settings.isDarkMode
                ? AppThems.darkTheme()
                : AppThems.lightTheme(),
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}

void _registerFcmToken() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.getToken().then((token) {
      log('FCM Token: $token');
    });
  });
}
