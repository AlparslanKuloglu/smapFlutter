import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/account/application/coaching_logic.dart';
import 'package:smap/features/account/domain/coach_code.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/inputs/app_text_field.dart';
import 'package:smap/shared/ui/inputs/input_masks.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';
import 'package:smap/shared/ui/surfaces/app_notice_box.dart';

/// "Koçunu değiştir" (pano 14.10 kare 2 to 4; T12.21): a small sheet with the
/// title "Koçunu değiştir" and "Kapat", the subtitle "Yeni koçunun verdiği
/// kodu gir.", the masked field "Koçluk kodu" (`AAAA-0000`, help "4 harf ve 4
/// rakam; tire kendiliğinden gelir."), the info box "Mehmet Özkan'la bağlantın
/// kalkar; gelişimini artık göremez. Yeni koçun denemelerini, analizlerini ve
/// programını görür." and the primary "Koçu Değiştir", which stays off until
/// eight characters are typed.
///
/// There is no second confirmation: the box says what happens and the button
/// names the action. While the code is tried (kare 4) the sheet is busy: the
/// button shows its spinner, the field is read only (no lock), and drag,
/// scrim and "Kapat" do not close it. A failure (kare 3) keeps the sheet open
/// with the typed code, puts the reason under the field (not found; the
/// current coach's own code; anything else is "try again"), moves the focus
/// back to the field, and the field plays the error haptic. Success closes
/// the sheet with the new coach; the ViewModel that asked commits it, toasts
/// and refreshes the card. The field reads "Koçluk kodu, 4 harf ve 4 rakam".
/// While [online] is false the offline strip shows above the sheet.
class ChangeCoachSheet extends StatefulWidget {
  const ChangeCoachSheet._({required this.current, required this.submit});

  /// The coach the student has now.
  final CoachLink current;

  /// Tries a code; the sheet shows the failure it answers with.
  final Future<CoachLinkResult> Function(CoachCode code) submit;

  /// Opens the sheet; completes with the new coach, or `null` when it was
  /// closed without one.
  static Future<CoachLink?> show({
    required CoachLink current,
    required Future<CoachLinkResult> Function(CoachCode code) submit,
    ValueListenable<bool>? online,
    BuildContext? context,
  }) => AppSheet.show<CoachLink>(
    context: context,
    online: online,
    // A form: a `full` sheet rides above the keyboard with its button in view.
    size: AppSheetSize.full,
    builder: (_) => ChangeCoachSheet._(current: current, submit: submit),
  );

  @override
  State<ChangeCoachSheet> createState() => _ChangeCoachSheetState();
}

class _ChangeCoachSheetState extends State<ChangeCoachSheet> {
  final TextEditingController _code = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _busy = false;
  bool _ready = false;
  CoachLinkFailure? _failure;

  /// Space between the field and the info box (pano 14.10 kare 2).
  static const double _gap = AppSpacing.s16;

  @override
  void initState() {
    super.initState();
    _code.addListener(_edited);
  }

  @override
  void dispose() {
    _code
      ..removeListener(_edited)
      ..dispose();
    _focus.dispose();
    super.dispose();
  }

  void _edited() {
    final verdict = CoachingRules.verdict(_code.text, current: widget.current);
    final ready = verdict != CoachCodeVerdict.incomplete;
    if (ready == _ready && _failure == null) return;
    setState(() {
      _ready = ready;
      _failure = null;
    });
  }

  Future<void> _submit() async {
    final code = CoachCode.tryParse(_code.text);
    if (code == null || _busy) return;
    if (CoachingRules.verdict(_code.text, current: widget.current) ==
        CoachCodeVerdict.currentCoach) {
      setState(() => _failure = CoachLinkFailure.sameCoach);
      _focus.requestFocus();
      return;
    }
    setState(() {
      _busy = true;
      _failure = null;
    });
    final result = await widget.submit(code);
    if (!mounted) return;
    final coach = result.coach;
    if (coach != null) {
      Navigator.of(context).pop(coach);
      return;
    }
    setState(() {
      _busy = false;
      _failure = result.failure ?? CoachLinkFailure.failed;
    });
    _focus.requestFocus();
  }

  String? _errorText(AppLocalizations l10n) => switch (_failure) {
    null => null,
    CoachLinkFailure.notFound => l10n.coaching_errNotFound,
    CoachLinkFailure.sameCoach => l10n.coachingChange_errSameCoach(
      TurkishSuffix.dative(widget.current.name),
    ),
    CoachLinkFailure.failed => l10n.accountSettings_sendFailed,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppSheetFrame(
      title: l10n.coachingChange_title,
      subtitle: l10n.coachingChange_subtitle,
      busy: _busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: l10n.coaching_codeLabel,
            semanticLabel: l10n.coachingChange_codeA11y,
            controller: _code,
            focusNode: _focus,
            hintText: l10n.coaching_codeHint,
            helperText: l10n.coaching_codeHelp,
            errorText: _errorText(l10n),
            readOnly: _busy,
            readOnlyLock: false,
            inputFormatters: [AppInputMasks.coachCode],
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            autofocus: true,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: _gap),
          AppNoticeBox(
            message: l10n.coachingChange_notice(
              CoachingRules.withSuffix(widget.current.name),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
        ],
      ),
      primary: AppSheetAction(
        label: l10n.coachingChange_action,
        loading: _busy,
        onPressed: _ready ? _submit : null,
      ),
    );
  }
}
