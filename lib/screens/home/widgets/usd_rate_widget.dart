import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';

class UsdRateWidget extends StatefulWidget {
  const UsdRateWidget({super.key});

  @override
  State<UsdRateWidget> createState() => _UsdRateWidgetState();
}

class _UsdRateWidgetState extends State<UsdRateWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-fetch rates if they have never been fetched
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (settings.lastRatesUpdate.isEmpty) {
        settings.fetchAndSaveRates();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final primaryColor = CupertinoTheme.of(context).primaryColor;

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: CupertinoColors.separator.resolveFrom(context),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: CupertinoColors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Pulsing green live dot
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) => Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(
                              alpha: _pulseAnimation.value,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'usdRates'.tr(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                  
                  // Refresh button with loading animation
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(24, 24),
                    onPressed: settings.isFetchingRates
                        ? null
                        : () => settings.fetchAndSaveRates(),
                    child: settings.isFetchingRates
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CupertinoActivityIndicator(radius: 7),
                          )
                        : const Icon(
                            CupertinoIcons.arrow_2_circlepath,
                            size: 16,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Rates Row ───────────────────────────────────────────
              Row(
                children: [
                  // USD to EGP Pill
                  Expanded(
                    child: _buildRatePill(
                      context,
                      flag: '🇺🇸',
                      base: '1 USD',
                      targetFlag: '🇪🇬',
                      rate: '${settings.usdToEgp.toStringAsFixed(2)} L.E',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // USD to SAR Pill
                  Expanded(
                    child: _buildRatePill(
                      context,
                      flag: '🇺🇸',
                      base: '1 USD',
                      targetFlag: '🇸🇦',
                      rate: '${settings.usdToSar.toStringAsFixed(2)} SAR',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              
              // ── Footer Last Updated ─────────────────────────────────
              if (settings.lastRatesUpdate.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${'lastUpdated'.tr()}: ${settings.lastRatesUpdate}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? CupertinoColors.systemGrey3 : CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }

  Widget _buildRatePill(
    BuildContext context, {
    required String flag,
    required String base,
    required String targetFlag,
    required String rate,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : CupertinoColors.systemGrey6.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator.resolveFrom(context),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                base,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
          const Icon(CupertinoIcons.right_chevron, size: 10, color: CupertinoColors.systemGrey3),
          Row(
            children: [
              Text(targetFlag, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                rate,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
