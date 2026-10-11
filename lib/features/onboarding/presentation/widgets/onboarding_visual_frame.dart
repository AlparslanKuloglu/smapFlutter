import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/smap_colors.dart';

/// The shadows of the three intro visuals (pano 2.1 kare 2-4; spec §1.12
/// "OnboardingPage görselleri kendi gölgesini taşır"). Only the intro
/// pictures carry them; the app's own surfaces have none.
abstract final class OnboardingShadows {
  /// The phone mock-up of page 1: `0 12 32` navy at 16 %.
  static List<BoxShadow> phone(SmapColors colors) => [
    BoxShadow(
      offset: const Offset(0, 12),
      blurRadius: 32,
      color: colors.primary.withValues(alpha: 0.16),
    ),
  ];

  /// The result card of page 2: `0 12 32` navy at 12 %.
  static List<BoxShadow> resultCard(SmapColors colors) => [
    BoxShadow(
      offset: const Offset(0, 12),
      blurRadius: 32,
      color: colors.primary.withValues(alpha: 0.12),
    ),
  ];

  /// The topic card of page 3: `0 8 24` navy at 10 %.
  static List<BoxShadow> topicCard(SmapColors colors) => [
    BoxShadow(
      offset: const Offset(0, 8),
      blurRadius: 24,
      color: colors.primary.withValues(alpha: 0.10),
    ),
  ];

  /// The info card of page 3: `0 16 32` navy at 18 %.
  static List<BoxShadow> infoCard(SmapColors colors) => [
    BoxShadow(
      offset: const Offset(0, 16),
      blurRadius: 32,
      color: colors.primary.withValues(alpha: 0.18),
    ),
  ];
}

/// The visual parts "appear 250 ms late" (pano 2.1 "Hareket ve haptik",
/// C60): wait 250 ms, then rise 8 pt while fading in over 250 ms. Under
/// "Reduce motion" the visual is simply there.
class OnboardingReveal extends StatelessWidget {
  const OnboardingReveal({required this.child, super.key});

  final Widget child;

  /// How far the visual rises into place.
  static const double _rise = 8;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      // The first half of the run is the delay.
      duration: AppMotion.base * 2,
      curve: const Interval(0.5, 1, curve: AppMotion.enter),
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * _rise),
          child: child,
        ),
      ),
    );
  }
}
