import 'package:flutter/cupertino.dart';
import 'package:masrofy/core/utils/no_animation_route.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/settings_provider.dart';
import '../../core/services/biometric_service.dart';
import '../home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isLoading = false;
  bool _hasCheckedAuth = false;

  Future<void> _checkAuth() async {
    setState(() => _isLoading = true);
    bool isAuthenticated = await _biometricService.authenticate();
    setState(() => _isLoading = false);

    if (isAuthenticated) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        NoAnimationPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // Show error or retry button
      // For now, we just stay here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        if (!settings.areSettingsLoaded) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          );
        }

        if (!settings.isBiometricEnabled) {
          Future.microtask(() {
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                NoAnimationPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          });
          return const CupertinoPageScaffold(child: SizedBox());
        }

        // Logic check
        if (!_hasCheckedAuth) {
          _hasCheckedAuth = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkAuth();
          });
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
                    // Fingerprint Icon with Animation
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
                        )
                        .shimmer(
                          duration: const Duration(milliseconds: 2000),
                          color: CupertinoColors.white.withValues(alpha: 0.5),
                        ),

                    const SizedBox(height: 40),

                    // Welcome Text
                    Text(
                          'welcomeBack'.tr(),
                          style: CupertinoTheme.of(context)
                              .textTheme
                              .navLargeTitleTextStyle
                              .copyWith(
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 800))
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: const Duration(milliseconds: 800),
                        ),

                    const SizedBox(height: 16),

                    // Instruction Text
                    Text(
                          'pleaseAuthenticate'.tr(),
                          style: CupertinoTheme.of(context).textTheme.textStyle
                              .copyWith(
                                color: CupertinoColors.white.withValues(
                                  alpha: 0.9,
                                ),
                                fontSize: 16,
                              ),
                        )
                        .animate()
                        .fadeIn(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 200),
                        )
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 200),
                        ),

                    const SizedBox(height: 60),

                    // Unlock Button
                    if (!_isLoading)
                      CupertinoButton.filled(
                            onPressed: _checkAuth,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.lockOpen,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text('unlock'.tr()),
                              ],
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(
                            duration: const Duration(milliseconds: 2000),
                            color: CupertinoColors.white.withValues(alpha: 0.3),
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
