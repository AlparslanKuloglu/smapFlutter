import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/account/application/account_header.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/account/presentation/account_texts.dart';
import 'package:smap/features/auth/application/register/username_input_formatter.dart';
import 'package:smap/features/auth/application/register/username_live_check.dart';
import 'package:smap/features/coach/application/add_student_rules.dart';
import 'package:smap/features/coach/application/coach_code_actions.dart';
import 'package:smap/features/coach/application/coach_students_service.dart';
import 'package:smap/features/coach/application/student_avatars.dart';
import 'package:smap/features/coach/data/coach_student_repository.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/coach/presentation/add_student/add_student_texts.dart';
import 'package:smap/features/coach/presentation/add_student/add_student_viewmodel.dart';
import 'package:smap/features/coach/presentation/add_student/credentials_sheet.dart';
import 'package:smap/features/coach/presentation/widgets/code_card.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/buttons/app_bar_action.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/controls/app_chip.dart';
import 'package:smap/shared/ui/identity/app_avatar_picker.dart';
import 'package:smap/shared/ui/inputs/app_select_field.dart';
import 'package:smap/shared/ui/inputs/app_text_field.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';
import 'package:smap/shared/ui/surfaces/app_notice_box.dart';

part 'widgets/add_student_avatar.dart';
part 'widgets/add_student_code.dart';
part 'widgets/add_student_identity.dart';
part 'widgets/add_student_password.dart';
part 'widgets/add_student_school.dart';
part 'widgets/add_student_submit.dart';

/// "Öğrenci ekle" (pano 10.3 "Öğrenci Ekle · 3 kare"; spec §4.I 10.3; Tur 12 D
/// for the avatar; flow 13.11), the long sheet the Plus of Öğrencilerim and
/// "Öğrenci Ekle" of the coach home open.
///
/// Title "Öğrenci ekle", subtitle "Hesabını sen aç ya da kodunu paylaş." and
/// "Kapat". The form (kare 1): the seven avatars (the first is chosen), "Ad"
/// and "Soyad" side by side, "Kullanıcı adı" with "Kontrol Et" and its live
/// answer, "Şifre" with "Oluştur" and the eye, "Sınıf" and "Alan" side by side
/// (the track is passive in the 9th and 10th grade), the primary "Öğrenciyi
/// Kaydet". Below it, between two rules, "ya da": the coaching code card (kare
/// 2), for the student who links with the code; it is there only when the coach
/// has a code. While the student is saved the sheet is busy (the close button
/// hides, drag and scrim do not close it, the fields are read only); a failure
/// keeps the sheet open with what was typed.
///
/// [show] runs the whole flow: the form, then the credentials sheet of kare 3
/// ([CredentialsSheet]); "Tamam" ends it with the toast "Zeynep Kaya eklendi."
/// and a refresh of the list from the server. The saved student already joined
/// the session's list (`CoachStudentsService.addStudent`).
class AddStudentSheet extends StatelessWidget {
  const AddStudentSheet._();

  /// Opens the flow; completes with the student that was added, or `null`
  /// when the coach left the form without saving. Without a [context] the
  /// sheets open on the router's navigator (`AppSheet.navigatorKey`).
  static Future<CoachStudentDto?> show([BuildContext? context]) async {
    final added = await AppSheet.show<AddedStudent>(
      context: context,
      size: AppSheetSize.full,
      builder: (_) => const AddStudentSheet._(),
    );
    if (added == null) return null;
    final toast = locator<ToastService>();
    final students = locator<CoachStudentsService>();
    await CredentialsSheet.show(
      added,
      codeActions: CoachCodeActions.system(toast: toast),
      context: context != null && context.mounted ? context : null,
    );
    // The student is saved either way; the sheet closed with "Tamam" or was
    // dragged away. The success haptic played when it was saved.
    toast.success((l) => l.students_added(added.fullName), haptic: false);
    unawaited(students.load(forceRefresh: true));
    return added.student;
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AddStudentViewModel>.nonReactive(
      viewModelBuilder: () => AddStudentViewModel(
        checkUsername: (name) async =>
            locator<CoachStudentRepository>().checkUsername(name),
        addStudent: locator<CoachStudentsService>().addStudent,
        codeActions: CoachCodeActions.system(toast: locator<ToastService>()),
        coachCode: _coachCode(),
      ),
      builder: (context, viewModel, _) => _AddStudentHost(viewModel: viewModel),
    );
  }

  /// The coaching code of the signed-in coach, as the account writes it.
  static String? _coachCode() {
    final user = locator<CurrentUserService>().user;
    return user == null ? null : AccountHeader.of(user).coachCode;
  }
}

/// What the sections share: the text controllers, the focus nodes (so the
/// ViewModel can send focus to the first wrong field) and one anchor per field
/// to scroll to.
class _AddStudentScope extends InheritedWidget {
  const _AddStudentScope({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.password,
    required this.focus,
    required this.anchors,
    required super.child,
  });

  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController username;
  final TextEditingController password;
  final Map<AddStudentField, FocusNode> focus;
  final Map<AddStudentField, GlobalKey> anchors;

  static _AddStudentScope of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_AddStudentScope>()!;

  @override
  bool updateShouldNotify(_AddStudentScope oldWidget) => false;
}

/// The one `State`: the controllers and focus nodes (UI guide §6 rule 9); it
/// turns focus requests into focus and a 350 ms scroll.
class _AddStudentHost extends StatefulWidget {
  const _AddStudentHost({required this.viewModel});

  final AddStudentViewModel viewModel;

  @override
  State<_AddStudentHost> createState() => _AddStudentHostState();
}

class _AddStudentHostState extends State<_AddStudentHost> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final Map<AddStudentField, FocusNode> _focus = {
    for (final field in AddStudentField.values) field: FocusNode(),
  };
  final Map<AddStudentField, GlobalKey> _anchors = {
    for (final field in AddStudentField.values) field: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    widget.viewModel.focusRequest.addListener(_onFocusRequest);
    for (final entry in _focus.entries) {
      entry.value.addListener(() {
        if (!entry.value.hasFocus) widget.viewModel.blur(entry.key);
      });
    }
  }

  @override
  void dispose() {
    widget.viewModel.focusRequest.removeListener(_onFocusRequest);
    for (final controller in [_firstName, _lastName, _username, _password]) {
      controller.dispose();
    }
    for (final node in _focus.values) {
      node.dispose();
    }
    super.dispose();
  }

  /// Scrolls the field into view (350 ms; straight there under "reduce
  /// motion") and gives it focus.
  void _onFocusRequest() {
    final request = widget.viewModel.focusRequest.value;
    if (request == null) return;
    final anchor = _anchors[request.field]?.currentContext;
    if (anchor != null) {
      Scrollable.ensureVisible(
        anchor,
        alignment: _alignBelowHeader,
        duration: context.motion(AppMotion.slow, reduced: Duration.zero),
        curve: AppMotion.standard,
      );
    }
    _focus[request.field]?.requestFocus();
  }

  /// Low enough to clear the sheet's title (about 150 of 874).
  static const double _alignBelowHeader = 0.15;

  @override
  Widget build(BuildContext context) {
    return _AddStudentScope(
      firstName: _firstName,
      lastName: _lastName,
      username: _username,
      password: _password,
      focus: _focus,
      anchors: _anchors,
      child: const _AddStudentFrame(),
    );
  }
}

/// The sheet frame: the title, the form and the busy state while a student is
/// saved (pano 1.20 kare 5; 10.3 "Gönderim sırasında 1.20 meşgul durumu").
class _AddStudentFrame
    extends SelectorViewModelWidget<AddStudentViewModel, bool> {
  const _AddStudentFrame();

  @override
  bool selector(AddStudentViewModel viewModel) => viewModel.submitting;

  @override
  Widget build(BuildContext context, bool submitting) {
    final l10n = AppLocalizations.of(context);
    return AppSheetFrame(
      title: l10n.addStudent_title,
      subtitle: l10n.addStudent_subtitle,
      busy: submitting,
      bodyPadding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s12,
        AppSpacing.s24,
        0,
      ),
      body: const _AddStudentForm(),
    );
  }
}

/// The gap between two fields and between the sections (pano 10.3 "satırlar
/// arası 16").
const double _addStudentGap = AppSpacing.s16;

/// The gap above the "ya da" section (pano 10.3 "padding 20 24 0").
const double _addStudentSectionGap = 20;

/// The gap between the two fields of a row (pano 10.3 "aralık 12").
const double _addStudentColumnGap = AppSpacing.s12;

/// The fields in screen order with 16 between them (pano 10.3 kare 1), then
/// the "ya da" section with the coaching code (kare 2).
class _AddStudentForm extends StatelessWidget {
  const _AddStudentForm();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AvatarSection(),
        SizedBox(height: _addStudentGap),
        _NameRow(),
        SizedBox(height: _addStudentGap),
        _UsernameRow(),
        SizedBox(height: _addStudentGap),
        _PasswordRow(),
        SizedBox(height: _addStudentGap),
        _SchoolRow(),
        SizedBox(height: _addStudentGap),
        _SaveSection(),
        _CodeSection(),
      ],
    );
  }
}

/// Where the box of a field starts under its label: the 14/20 label line and
/// the 8 under it, at the current text scale. An action beside a field
/// ("Kontrol Et", "Oluştur") starts there so it sits level with the box.
double _labelBlock(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(20) + AppSpacing.s8;
