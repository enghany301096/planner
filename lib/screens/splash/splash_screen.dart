import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:planner/core/utils/fixed_assets.dart';
import 'package:planner/core/utils/no_animation_route.dart';
import 'package:planner/providers/locale_provider.dart';
import 'package:planner/providers/settings_provider.dart';
import 'package:planner/screens/settings/auth_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for animations to play a bit
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = context.locale;
    final navigator = Navigator.of(context);
    final started = DateTime.now();
    while (!settings.areSettingsLoaded &&
        DateTime.now().difference(started) < const Duration(seconds: 3)) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    final nextLocale = localeProvider.locale;
    if (mounted && nextLocale != null && nextLocale != currentLocale) {
      await context.setLocale(nextLocale);
    }
    if (!mounted) return;
    navigator.pushReplacement(
      NoAnimationPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Stack(
          children: [
            // Floating background blobs for depth
            Positioned(
              top: -50,
              right: -50,
              child:
                  Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .move(
                        duration: 4.seconds,
                        begin: const Offset(0, 0),
                        end: const Offset(-20, 30),
                      ),
            ),

            Positioned(
              bottom: 100,
              left: -30,
              child:
                  Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.03),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .move(
                        duration: 5.seconds,
                        begin: const Offset(0, 0),
                        end: const Offset(30, -20),
                      ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  Container(
                        width: 120,
                        height: 120,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Image.asset(FixedAssets.appIcon),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(duration: 800.ms, curve: Curves.elasticOut)
                      .shimmer(delay: 1200.ms, duration: 1800.ms),

                  const SizedBox(height: 30),

                  // App Name
                  Text(
                        'appName'.tr(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 800.ms)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic)
                      .shimmer(delay: 1500.ms, duration: 1500.ms),

                  const SizedBox(height: 10),

                  // Slogan
                  Text(
                    'trackYourWealth'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 1.2,
                    ),
                  ).animate().fadeIn(delay: 1000.ms, duration: 800.ms),
                ],
              ),
            ),

            // Loading state
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const CupertinoActivityIndicator(
                    color: Colors.white,
                  ).animate().fadeIn(delay: 1500.ms),
                  const SizedBox(height: 16),
                  Container(
                    width: 120,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ).animate().scaleX(
                          delay: 1200.ms,
                          duration: 1800.ms,
                          begin: 0,
                          end: 1,
                          curve: Curves.easeInOutQuart,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
