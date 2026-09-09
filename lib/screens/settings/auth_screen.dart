import 'package:flutter/cupertino.dart';
import 'package:planner/core/utils/no_animation_route.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/settings_provider.dart';
import '../../core/services/biometric_service.dart';
import '../shell/app_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.isOverlay = false});

  final bool isOverlay;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isLoading = false;
  bool _hasCheckedAuth = false;

  void _goHome() {
    if (!mounted) return;
    context.read<SettingsProvider>().unlockApp();
    if (widget.isOverlay) return;
    Navigator.of(
      context,
    ).pushReplacement(NoAnimationPageRoute(builder: (_) => const AppShell()));
  }

  Future<void> _checkAuth() async {
    setState(() => _isLoading = true);
    final isAuthenticated = await _biometricService.authenticate();
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (isAuthenticated) {
      _goHome();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<SettingsProvider>(context);
    if (!settings.areSettingsLoaded || _hasCheckedAuth) return;
    _hasCheckedAuth = true;
    if (!settings.isBiometricEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _goHome());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        if (!settings.areSettingsLoaded || !settings.isBiometricEnabled) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        return CupertinoPageScaffold(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                          FontAwesomeIcons.shield,
                          size: 100,
                          color: CupertinoColors.white,
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(
                          duration: const Duration(milliseconds: 1500),
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.1, 1.1),
                          curve: Curves.easeInOut,
                        )
                        .then()
                        .scale(
                          duration: const Duration(milliseconds: 1500),
                          begin: const Offset(1.1, 1.1),
                          end: const Offset(1.0, 1.0),
                          curve: Curves.easeInOut,
                        ),
                    const SizedBox(height: 40),
                    Text(
                      'welcomeBack'.tr(),
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navLargeTitleTextStyle
                          .copyWith(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'pleaseAuthenticate'.tr(),
                      style: CupertinoTheme.of(context).textTheme.textStyle
                          .copyWith(
                            color: CupertinoColors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(height: 60),
                    if (!_isLoading)
                      CupertinoButton.filled(
                        onPressed: _checkAuth,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FaIcon(FontAwesomeIcons.lockOpen, size: 18),
                            const SizedBox(width: 8),
                            Text('unlock'.tr()),
                          ],
                        ),
                      )
                    else
                      const CupertinoActivityIndicator(
                        radius: 20,
                        color: CupertinoColors.white,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
