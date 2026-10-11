import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/auth/application/forgot_password_logic.dart';
import 'package:smap/features/auth/application/forgot_password_repository.dart';
import 'package:smap/features/auth/presentation/forgot_password/forgot_password_viewmodel.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/feedback/app_status_view.dart';
import 'package:smap/shared/ui/inputs/app_code_input.dart';
import 'package:smap/shared/ui/inputs/app_text_field.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';

part 'widgets/forgot_password_code.dart';
part 'widgets/forgot_password_done.dart';
part 'widgets/forgot_password_email.dart';
part 'widgets/forgot_password_frame.dart';
part 'widgets/forgot_password_password.dart';

/// The gap between the items of a step (pano 2.4: "aralık 20"). Not on the
/// 4-pt scale of `AppSpacing`.
const double _stepGap = 20;

/// Şifremi Unuttum (pano 2.4 kare 1 to 4; flow 13.2): e-mail, the six-digit
/// code, the new password, "Şifren güncellendi".
///
/// Each step has one job and one primary button; the steps replace each other
/// with a 350 ms horizontal slide (a 150 ms fade under "reduce motion"). Back
/// goes one step back and leaves the flow from the first step; the last screen
/// has no back. The route is open only while `FeatureFlags.forgotPasswordEnabled`
/// is on (it is not in the route list otherwise) and needs a
/// `ForgotPasswordRepository` in the locator, which does not exist until the
/// backend has the endpoints (spec §6.3 #7).
///
/// Closing the flow with "Giriş Yap" returns the account's user name, so the
/// sign-in screen has it ready.
@RoutePage()
class ForgotPasswordView extends StackedView<ForgotPasswordViewModel> {
  const ForgotPasswordView({super.key});

  @override
  bool get reactive => false;

  @override
  ForgotPasswordViewModel viewModelBuilder(BuildContext context) =>
      ForgotPasswordViewModel(
        repository: locator<ForgotPasswordRepository>(),
        router: locator<AppRouter>(),
        toast: locator<ToastService>(),
      );

  @override
  Widget builder(
    BuildContext context,
    ForgotPasswordViewModel viewModel,
    Widget? child,
  ) => const _ForgotPasswordPage();
}

typedef _PageData = ({ForgotPasswordStep step, bool forward});

/// The page: the step on screen, swapped with a slide when it changes. The
/// system back button goes back a step instead of closing the flow.
class _ForgotPasswordPage
    extends SelectorViewModelWidget<ForgotPasswordViewModel, _PageData> {
  const _ForgotPasswordPage();

  @override
  _PageData selector(ForgotPasswordViewModel viewModel) =>
      (step: viewModel.step, forward: viewModel.movingForward);

  @override
  Widget build(BuildContext context, _PageData data) {
    final viewModel = getParentViewModel<ForgotPasswordViewModel>(
      context,
      listen: false,
    );
    final step = data.step;
    return PopScope(
      canPop: step == ForgotPasswordStep.email,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) viewModel.back();
      },
      child: Scaffold(
        backgroundColor: context.appColors.bgCanvas,
        body: AnimatedSwitcher(
          duration: context.motion(
            AppMotion.slow,
            reduced: AppMotion.reducedFade,
          ),
          switchInCurve: AppMotion.standard,
          switchOutCurve: AppMotion.standard,
          layoutBuilder: (current, previous) =>
              Stack(fit: StackFit.expand, children: [...previous, ?current]),
          transitionBuilder: (child, animation) => _StepTransition(
            animation: animation,
            entering: child.key == ValueKey(step),
            forward: data.forward,
            child: child,
          ),
          child: KeyedSubtree(
            key: ValueKey(step),
            child: switch (step) {
              ForgotPasswordStep.email => const _EmailStep(),
              ForgotPasswordStep.code => const _CodeStep(),
              ForgotPasswordStep.newPassword => const _NewPasswordStep(),
              ForgotPasswordStep.done => const _DoneStep(),
            },
          ),
        ),
      ),
    );
  }
}

/// The slide between two steps (pano 2.4 "Adımlar arası 350 ms yatay
/// geçiş"): the new step comes in from the side it is ahead on, the old one
/// leaves to the other side; both fade. Under "reduce motion" only the fade
/// stays (the duration is already 150 ms then).
class _StepTransition extends StatelessWidget {
  const _StepTransition({
    required this.animation,
    required this.entering,
    required this.forward,
    required this.child,
  });

  final Animation<double> animation;
  final bool entering;
  final bool forward;
  final Widget child;

  /// How far a step travels, as a share of the screen width.
  static const double _travel = 0.25;

  @override
  Widget build(BuildContext context) {
    final faded = FadeTransition(opacity: animation, child: child);
    if (context.reduceMotion) return faded;
    // The entering step starts ahead of its place; the leaving one ends there.
    final side = (entering == forward) ? 1.0 : -1.0;
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(side * _travel, 0),
        end: Offset.zero,
      ).animate(animation),
      child: faded,
    );
  }
}
