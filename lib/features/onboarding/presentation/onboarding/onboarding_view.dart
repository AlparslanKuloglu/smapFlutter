import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/domain/user_role.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/onboarding/application/camera_permission.dart';
import 'package:smap/features/onboarding/application/onboarding_draft.dart';
import 'package:smap/features/onboarding/application/onboarding_flow.dart';
import 'package:smap/features/onboarding/data/camera_permission_gateway.dart';
import 'package:smap/features/onboarding/onboarding_navigation.dart';
import 'package:smap/features/onboarding/presentation/onboarding/onboarding_viewmodel.dart';
import 'package:smap/features/onboarding/presentation/widgets/onboarding_analysis_visual.dart';
import 'package:smap/features/onboarding/presentation/widgets/onboarding_gaps_visual.dart';
import 'package:smap/features/onboarding/presentation/widgets/onboarding_scan_visual.dart';
import 'package:smap/features/onboarding/presentation/widgets/onboarding_visual_frame.dart';
import 'package:smap/features/onboarding/presentation/widgets/role_option.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/controls/app_chip.dart';
import 'package:smap/shared/ui/controls/app_chip_group.dart';
import 'package:smap/shared/ui/feedback/app_status_view.dart';
import 'package:smap/shared/ui/indicators/app_page_dots.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';
import 'package:smap/shared/ui/surfaces/app_notice_box.dart';
import 'package:smap/gen/assets.gen.dart';

part 'widgets/onboarding_camera.dart';
part 'widgets/onboarding_grade.dart';
part 'widgets/onboarding_intro.dart';
part 'widgets/onboarding_role.dart';
part 'widgets/onboarding_step_frame.dart';

/// The intro flow (route `/onboarding/intro`, `OnboardingRoute`): the three
/// intro pages, the role question, grade and track, and the camera
/// primer (pano 2.1 kare 2-4, 2.2 kare 1-4; flow 13.1).
///
/// One route with inner steps (spec §3.6 lists `/onboarding/intro`, `role`,
/// `grade` and `camera` as separate paths): the steps share their picks and
/// their Back, a closed app reopens at the step it was on, and the guards see
/// one "intro" route that is open until the flow ends. The step switches with
/// a 350 ms slide and fade (a 150 ms fade under "Reduce motion"). Back works
/// on every step and keeps the picks; the first intro page has nowhere to go
/// back to.
///
/// The root is non-reactive; the step switcher and each step select what
/// they show from [OnboardingViewModel].
@RoutePage()
class OnboardingView extends StackedView<OnboardingViewModel> {
  const OnboardingView({super.key});

  @override
  bool get reactive => false;

  @override
  OnboardingViewModel viewModelBuilder(BuildContext context) =>
      OnboardingViewModel(
        draft: OnboardingDraftStore(locator<DevicePreferences>()),
        preferences: locator<DevicePreferences>(),
        camera: const PermissionHandlerCameraPermission(),
        navigator: RouterOnboardingNavigator(locator<AppRouter>()),
      );

  @override
  void onViewModelReady(OnboardingViewModel viewModel) => viewModel.start();

  @override
  Widget builder(
    BuildContext context,
    OnboardingViewModel viewModel,
    Widget? child,
  ) => _OnboardingPage(viewModel: viewModel);
}

/// Owns what only the UI can: the intro's `PageController`, the app
/// lifecycle (a camera permission given in the settings is noticed on the way
/// back) and the system Back.
class _OnboardingPage extends StatefulWidget {
  const _OnboardingPage({required this.viewModel});

  final OnboardingViewModel viewModel;

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage>
    with WidgetsBindingObserver {
  late final PageController _pages;
  late OnboardingStep _lastStep;

  OnboardingViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _pages = PageController(initialPage: _vm.introPage.value);
    _lastStep = _vm.step;
    _vm.introPage.addListener(_followPage);
    _vm.addListener(_onViewModel);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _vm.removeListener(_onViewModel);
    _vm.introPage.removeListener(_followPage);
    _pages.dispose();
    super.dispose();
  }

  /// "Devam Et" and Back change the page number; the pager follows (350 ms
  /// standard; under "Reduce motion" it jumps and the page fades in).
  void _followPage() {
    final target = _vm.introPage.value;
    if (!_pages.hasClients || _pages.page?.round() == target) return;
    if (context.reduceMotion) {
      _pages.jumpToPage(target);
    } else {
      _pages
          .animateToPage(
            target,
            duration: AppMotion.slow,
            curve: AppMotion.standard,
          )
          .ignore();
    }
  }

  /// Coming back to the intro builds a new pager; it starts at the page the
  /// user left.
  void _onViewModel() {
    final step = _vm.step;
    if (step == OnboardingStep.intro && _lastStep != OnboardingStep.intro) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pages.hasClients) {
          _pages.jumpToPage(_vm.introPage.value);
        }
      });
    }
    _lastStep = step;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _vm.onResumed().ignore();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // At the first intro page there is nowhere to go: the app closes.
        if (!_vm.back()) SystemNavigator.pop().ignore();
      },
      child: Scaffold(
        backgroundColor: context.appColors.bgCanvas,
        body: AppSystemOverlayRegion(
          kind: AppSystemOverlayKind.bar,
          child: _StepSwitcher(pages: _pages),
        ),
      ),
    );
  }
}

/// Shows the current step and moves between steps (350 ms: the incoming step
/// slides in a little from the side it comes from while both fade; a plain
/// 150 ms fade under "Reduce motion").
class _StepSwitcher
    extends
        SelectorViewModelWidget<OnboardingViewModel, (OnboardingStep, bool)> {
  const _StepSwitcher({required this.pages});

  final PageController pages;

  /// How far a step slides, as a share of its width.
  static const double _slide = 0.08;

  @override
  (OnboardingStep, bool) selector(OnboardingViewModel viewModel) =>
      (viewModel.step, viewModel.forward);

  @override
  Widget build(BuildContext context, (OnboardingStep, bool) data) {
    final (step, forward) = data;
    final reduced = context.reduceMotion;
    final from = Offset(forward ? _slide : -_slide, 0);
    return AnimatedSwitcher(
      duration: context.motion(AppMotion.slow, reduced: AppMotion.reducedFade),
      switchInCurve: AppMotion.standard,
      switchOutCurve: AppMotion.exit,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: reduced
            ? child
            : SlideTransition(
                position: Tween<Offset>(
                  begin: from,
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
      ),
      child: ColoredBox(
        key: ValueKey(step),
        color: context.appColors.bgCanvas,
        child: switch (step) {
          OnboardingStep.intro => _IntroStep(pages: pages),
          OnboardingStep.role => const _RoleStep(),
          OnboardingStep.grade => const _GradeStep(),
          OnboardingStep.camera => const _CameraStep(),
        },
      ),
    );
  }
}
