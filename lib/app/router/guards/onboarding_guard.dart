import 'package:smap/app/router/guards/access_guard.dart';
import 'package:smap/app/router/guards/route_access.dart';

/// First guard: the intro comes before everything else (`onboardingStage`).
class OnboardingGuard extends AccessGuard {
  const OnboardingGuard({
    required super.catalog,
    required super.session,
    required super.preferences,
    super.logger,
  }) : super(stage: onboardingStage, name: 'OnboardingGuard');
}
