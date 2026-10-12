import 'package:flutter/material.dart';

import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/account/application/coaching_logic.dart';
import 'package:smap/features/account/domain/coach_code.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/inputs/app_text_field.dart';
import 'package:smap/shared/ui/inputs/input_masks.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';
import 'package:smap/shared/ui/surfaces/app_notice_box.dart';

/// "Koçunu değiştir" (Tur 12 F, 14.10 kare 2; no board yet, built from the
/// kit): a medium sheet with a title and "Kapat", a warning box that says
/// what changes, the masked field "Yeni koçunun kodu" and the primary "Koçu
/// Değiştir".
///
/// There is no second confirmation sheet: the warning is in this one. While
/// the code is tried the sheet is busy (the close button hides, drag and scrim
/// do not close it, the field is read only); on a failure it stays open with
/// the typed code and the reason under the field (not found; the code of the
/// current coach; anything else is "try again"). Success closes it with the
/// new coach; the ViewModel that asked commits it and toasts.
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
    BuildContext? context,
  }) => AppSheet.show<CoachLink>(
    context: context,
    size: AppSheetSize.medium,
    builder: (_) => ChangeCoachSheet._(current: current, submit: submit),
  );

  @override
  State<ChangeCoachSheet> createState() => _ChangeCoachSheetState();
}

class _ChangeCoachSheetState extends State<ChangeCoachSheet> {
  final TextEditingController _code = TextEditingController();
  bool _busy = false;
  bool _ready = false;
  CoachLinkFailure? _failure;

  /// Space between the warning, the field and the button (kit sheet bodies
  /// space their items 20 apart).
  static const double _gap = 20;

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
      AppHaptics.error();
      setState(() => _failure = CoachLinkFailure.sameCoach);
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
    AppHaptics.error();
    setState(() {
      _busy = false;
      _failure = result.failure ?? CoachLinkFailure.failed;
    });
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
      busy: _busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppNoticeBox(
            message: l10n.coachingChange_warning(widget.current.name),
            tone: AppNoticeTone.warning,
          ),
          const SizedBox(height: _gap),
          AppTextField(
            label: l10n.coachingChange_codeLabel,
            controller: _code,
            hintText: l10n.coaching_codeHint,
            helperText: l10n.coaching_codeHelp,
            errorText: _errorText(l10n),
            inputFormatters: [AppInputMasks.coachCode],
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            autofocus: true,
            onSubmitted: (_) => _submit(),
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
