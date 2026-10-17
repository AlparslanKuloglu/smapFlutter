import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/coach/application/add_student_rules.dart';
import 'package:smap/features/coach/application/coach_code_actions.dart';
import 'package:smap/features/coach/application/student_avatars.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';
import 'package:smap/shared/ui/inputs/app_text_field.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// "Zeynep Kaya eklendi" (pano 10.3 kare 3 "Eklendi"; Tur 12 D, brief 14.8 kare
/// 2), the small sheet that shows the login of the student just added, once.
///
/// The head: the chosen avatar (48, at the left of the title), "Zeynep Kaya
/// eklendi" 20/28 · 700, "Giriş bilgilerini öğrencine ilet." 13/20
/// `textSecondary` and "Kapat". The
/// body (16 down, 24 at the sides, 16 apart): "Kullanıcı adı" (read only) and
/// "Şifre" (masked, with the eye) with "Bu ekranı kapatınca şifre yeniden
/// gösterilmez."; the primary "Bilgileri Paylaş" (the system share sheet with
/// the login in a sentence) and the quiet "Tamam". Showing the password once
/// keeps it from travelling in a screenshot; the server never sends it back,
/// it is the one the form had.
///
/// "Tamam" closes the sheet; the flow that opened it ([AddStudentSheet.show])
/// answers with the toast and the refresh of the list.
class CredentialsSheet extends StatelessWidget {
  const CredentialsSheet._({required this.added, required this.codeActions});

  final AddedStudent added;
  final CoachCodeActions codeActions;

  /// Opens the sheet; completes when it is closed (by "Tamam", "Kapat" or a
  /// drag).
  static Future<void> show(
    AddedStudent added, {
    required CoachCodeActions codeActions,
    BuildContext? context,
  }) => AppSheet.show<void>(
    context: context,
    builder: (_) => CredentialsSheet._(added: added, codeActions: codeActions),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppSheetFrame(
      header: _CredentialsHeader(added: added),
      semanticLabel: l10n.addStudent_addedTitle(added.fullName),
      body: _CredentialsBody(added: added, codeActions: codeActions),
    );
  }
}

/// The head of the sheet: avatar, title and subtitle, and the close button
/// (the frame's own title row, with the avatar the design brief asks for).
class _CredentialsHeader extends StatelessWidget {
  const _CredentialsHeader({required this.added});

  final AddedStudent added;

  /// The close button's box and its pull toward the top (as the frame's).
  static const double _closeBox = 32;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final asset = StudentAvatars.assetOf(added.avatarIndex ?? -1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s12,
        AppSpacing.s12,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (asset != null) ...[
            AppAvatar(
              name: added.fullName,
              image: AssetImage(asset),
              size: AppAvatarSize.tile,
              decorative: true,
            ),
            const SizedBox(width: AppSpacing.s12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.addStudent_addedTitle(added.fullName),
                    style: text.titleMd.copyWith(color: colors.textPrimary),
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  l10n.addStudent_addedSubtitle,
                  style: text.caption.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(
            width: AppSize.touch,
            height: _closeBox,
            child: OverflowBox(
              minHeight: AppSize.touch,
              maxHeight: AppSize.touch,
              child: AppIconButton(
                icon: PhosphorIconsRegular.x,
                semanticLabel: l10n.common_close,
                variant: AppIconButtonVariant.close,
                focusGapColor: colors.bgRaised,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The two fields, the share button and "Tamam". It owns the fields'
/// controllers (UI guide §6 rule 9).
class _CredentialsBody extends StatefulWidget {
  const _CredentialsBody({required this.added, required this.codeActions});

  final AddedStudent added;
  final CoachCodeActions codeActions;

  @override
  State<_CredentialsBody> createState() => _CredentialsBodyState();
}

class _CredentialsBodyState extends State<_CredentialsBody> {
  late final TextEditingController _userName = TextEditingController(
    text: widget.added.userName,
  );
  late final TextEditingController _password = TextEditingController(
    text: widget.added.password,
  );

  /// The password field shows its eye but is never edited: it cannot take the
  /// focus, so no keyboard opens over the sheet.
  final FocusNode _inert = FocusNode(
    canRequestFocus: false,
    skipTraversal: true,
  );

  @override
  void dispose() {
    _userName.dispose();
    _password.dispose();
    _inert.dispose();
    super.dispose();
  }

  /// The rectangle of the share button on screen, for an iPad's popover.
  static Rect? _originOf(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: l10n.addStudent_username,
          controller: _userName,
          readOnly: true,
        ),
        const SizedBox(height: AppSpacing.s16),
        AppTextField(
          label: l10n.addStudent_password,
          controller: _password,
          focusNode: _inert,
          password: true,
          helperText: l10n.addStudent_addedNote,
        ),
        const SizedBox(height: AppSpacing.s16),
        Builder(
          builder: (buttonContext) => AppButton(
            label: l10n.addStudent_shareCredentials,
            icon: PhosphorIconsRegular.shareNetwork,
            expand: true,
            focusGapColor: context.appColors.bgRaised,
            onPressed: () => widget.codeActions.share(
              l10n.addStudent_credentialsShareText(
                widget.added.userName,
                widget.added.password,
              ),
              origin: _originOf(buttonContext),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        AppButton(
          label: l10n.common_ok,
          variant: AppButtonVariant.quiet,
          expand: true,
          focusGapColor: context.appColors.bgRaised,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
