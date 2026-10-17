import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/domain/user_role.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/auth/application/register/consent_text_parts.dart';
import 'package:smap/features/auth/application/register/register_legal_texts.dart';
import 'package:smap/features/auth/application/register/register_rules.dart';
import 'package:smap/features/auth/application/register/username_input_formatter.dart';
import 'package:smap/features/auth/application/register/username_live_check.dart';
import 'package:smap/features/auth/data/auth_repository.dart';
import 'package:smap/features/auth/presentation/register/register_navigator.dart';
import 'package:smap/features/auth/presentation/register/register_notice.dart';
import 'package:smap/features/auth/presentation/register/register_texts.dart';
import 'package:smap/features/auth/presentation/register/register_viewmodel.dart';
import 'package:smap/features/auth/presentation/register/sheets/legal_text_sheet.dart';
import 'package:smap/features/coach/data/coach_student_repository.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/session_manager.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/controls/app_checkbox.dart';
import 'package:smap/shared/ui/controls/app_chip.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/identity/app_avatar_picker.dart';
import 'package:smap/shared/ui/inputs/app_field_frame.dart';
import 'package:smap/shared/ui/inputs/app_select_field.dart';
import 'package:smap/shared/ui/inputs/app_text_field.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/band_math.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';
import 'package:smap/shared/ui/surfaces/app_notice_box.dart';

part 'widgets/register_form.dart';
part 'widgets/register_role_bar.dart';
part 'widgets/register_identity.dart';
part 'widgets/register_password.dart';
part 'widgets/register_school.dart';
part 'widgets/register_consent.dart';
part 'widgets/register_submit.dart';

/// The sign-up screen (pano 2.5 "Kayıt · 3 kare", pano 2.6 "Kayıt ·
/// Durumlar"; spec §4.A "2.5–2.6"; route `/auth/register`).
///
/// "Kayıt ol" as the large title, the role segment that stays under the bar
/// once the title has scrolled away, the seven avatars, the fields, the grade
/// and track (a student) or the coaching code note (a coach), the one consent
/// line and "Kayıt Ol". Closed `FeatureFlags.coachSignUpEnabled`: no role
/// segment, always a student. [role], [grade] and [track] are what the person
/// picked on the welcome screens (pano 2.2 "Seçtiklerin kayıt formuna
/// gelir"); all optional.
@RoutePage()
class RegisterView extends StackedView<RegisterViewModel> {
  const RegisterView({this.role, this.grade, this.track, super.key});

  final UserRole? role;
  final SchoolGrade? grade;
  final StudyTrack? track;

  @override
  bool get reactive => false;

  @override
  RegisterViewModel viewModelBuilder(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RegisterViewModel(
      navigator: RouterRegisterNavigator(locator<AppRouter>()),
      checkUsername: (name) async =>
          locator<CoachStudentRepository>().checkUsername(name),
      loadLegalDocuments: locator<AccountRepository>().getLegalDocuments,
      register: locator<AuthRepository>().register,
      signIn: locator<SessionManager>().signIn,
      clearOnboardingDraft: () => locator<DevicePreferences>().remove(
        DevicePreferences.onboardingDraftKey,
      ),
      openLegalText: (document) => LegalTextSheet.show(
        document,
        fallbackTitle: document.name == RegisterLegalTexts.termsName
            ? l10n.register_consentTerms
            : l10n.register_consentKvkk,
      ),
      role: role,
      grade: grade,
      track: track,
    );
  }

  @override
  void onViewModelReady(RegisterViewModel viewModel) =>
      viewModel.loadLegal().ignore();

  @override
  Widget builder(
    BuildContext context,
    RegisterViewModel viewModel,
    Widget? child,
  ) => _RegisterPage(viewModel: viewModel);
}

/// The one `State`: the controllers, focus nodes and scroll controller (UI
/// guide §6 rule 9); it turns focus requests into focus and a 350 ms scroll.
class _RegisterPage extends StatefulWidget {
  const _RegisterPage({required this.viewModel});

  final RegisterViewModel viewModel;

  @override
  State<_RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<_RegisterPage> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordRepeat = TextEditingController();
  final ValueNotifier<bool> _roleStuck = ValueNotifier<bool>(false);
  final Map<RegisterField, FocusNode> _focus = {
    for (final field in RegisterField.values)
      if (field != RegisterField.consent) field: FocusNode(),
  };
  final Map<RegisterField, GlobalKey> _anchors = {
    for (final field in RegisterField.values) field: GlobalKey(),
  };

  /// The scroll offset at which the role segment reaches the bar.
  double _stuckAt = double.infinity;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    widget.viewModel.focusRequest.addListener(_onFocusRequest);
    for (final entry in _focus.entries) {
      entry.value.addListener(() {
        if (!entry.value.hasFocus) widget.viewModel.blur(entry.key);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stuckAt = _registerStuckAt(context, widget.viewModel.coachSignUpEnabled);
    _onScroll();
  }

  @override
  void dispose() {
    widget.viewModel.focusRequest.removeListener(_onFocusRequest);
    _scroll.dispose();
    _roleStuck.dispose();
    for (final controller in [
      _fullName,
      _username,
      _email,
      _password,
      _passwordRepeat,
    ]) {
      controller.dispose();
    }
    for (final node in _focus.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    _roleStuck.value = _scroll.offset >= _stuckAt - 0.5;
  }

  /// Scrolls the field into view (350 ms; straight there under "reduce
  /// motion", pano 2.6 "Hareket ve haptik") and gives it focus.
  void _onFocusRequest() {
    final request = widget.viewModel.focusRequest.value;
    if (request == null) return;
    final anchor = _anchors[request.field]?.currentContext;
    if (anchor != null) {
      Scrollable.ensureVisible(
        anchor,
        alignment: _alignBelowBars,
        duration: context.motion(AppMotion.slow, reduced: Duration.zero),
        curve: AppMotion.standard,
      );
    }
    _focus[request.field]?.requestFocus();
  }

  /// Low enough to clear the bar and the role segment (about 170 of 874).
  static const double _alignBelowBars = 0.25;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return _RegisterScope(
      fullName: _fullName,
      username: _username,
      email: _email,
      password: _password,
      passwordRepeat: _passwordRepeat,
      focus: _focus,
      anchors: _anchors,
      roleStuck: _roleStuck,
      child: Scaffold(
        backgroundColor: context.appColors.bgCanvas,
        body: CustomScrollView(
          controller: _scroll,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            AppDetailBar(title: l10n.register_title, gutter: _registerGutter),
            LargeTitleSliver(
              title: l10n.register_title,
              gutter: _registerGutter,
            ),
            if (widget.viewModel.coachSignUpEnabled) ...const [
              SliverToBoxAdapter(child: SizedBox(height: _registerTitleGap)),
              PinnedHeaderSliver(child: _RoleBar()),
            ],
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                _registerGutter,
                _registerFieldGap,
                _registerGutter,
                bottom + AppSpacing.s32,
              ),
              sliver: const SliverToBoxAdapter(child: _RegisterForm()),
            ),
          ],
        ),
      ),
    );
  }
}
