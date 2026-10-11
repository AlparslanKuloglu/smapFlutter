import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/controls/app_checkbox.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// What a confirmation returned: whether the user confirmed and whether the
/// "Bir daha sorma" box was checked. Dismissing the sheet (scrim, drag, back,
/// "Vazgeç") is [cancelled]: "Perdeye dokunmak Vazgeç sayılır" (C72).
@immutable
class ConfirmResult {
  const ConfirmResult({required this.confirmed, this.dontAskAgain = false});

  /// The user pressed the primary action.
  final bool confirmed;

  /// The "Bir daha sorma" box was checked (only offered when the caller
  /// passed `dontAskAgainLabel`); only meaningful when [confirmed].
  final bool dontAskAgain;

  /// Nothing was confirmed.
  static const ConfirmResult cancelled = ConfirmResult(confirmed: false);

  @override
  bool operator ==(Object other) =>
      other is ConfirmResult &&
      other.confirmed == confirmed &&
      other.dontAskAgain == dontAskAgain;

  @override
  int get hashCode => Object.hash(confirmed, dontAskAgain);

  @override
  String toString() =>
      'ConfirmResult(confirmed: $confirmed, dontAskAgain: $dontAskAgain)';
}

/// The confirmation sheet (C72 "ConfirmSheet"; board 1.21 "Onay ve Yakında
/// Sheet'leri" kare 1 and 2; UI guide §5 #25).
///
/// It asks one question and says what will happen: the title is a question
/// in sentence case ("Kartı Bildiklerim'e taşıyalım mı?"), the [message]
/// 15/24 `textSecondary`. The primary action carries the question's verb
/// ("Öğrendim", "Bağlantıyı Kaldır"; never "Evet") and "Vazgeç" is the quiet
/// button under it; both are full width.
///
/// - **normal**: navy primary button; the checkbox row [dontAskAgainLabel]
///   ("Bir daha sorma") is optional. Used for the logout confirmation too.
/// - **danger**: a 40 pt `errorBg` circle with a WarningCircle at the left
///   of the title, the red `danger` primary button on top and "Vazgeç"
///   below with the focus on it, the ring visible. Red is for dangerous
///   confirmations only; no typed word is asked for (Ek D-28).
///
/// The result is a [ConfirmResult]; the ViewModel that asked does the work.
/// It is a small sheet with no close button (the handle and "Vazgeç" are the
/// ways out). Opens in 350 ms like every sheet.
class AppConfirmSheet extends StatefulWidget {
  const AppConfirmSheet._({
    required this.title,
    required this.confirmLabel,
    this.message,
    this.cancelLabel,
    this.danger = false,
    this.dontAskAgainLabel,
  });

  final String title;
  final String confirmLabel;
  final String? message;
  final String? cancelLabel;
  final bool danger;
  final String? dontAskAgainLabel;

  /// Asks [title] and completes with the answer. [cancelLabel] is
  /// "Vazgeç" by default.
  static Future<ConfirmResult> show({
    required String title,
    required String confirmLabel,
    BuildContext? context,
    String? message,
    String? cancelLabel,
    bool danger = false,
    String? dontAskAgainLabel,
  }) async {
    final result = await AppSheet.show<ConfirmResult>(
      context: context,
      builder: (_) => AppConfirmSheet._(
        title: title,
        confirmLabel: confirmLabel,
        message: message,
        cancelLabel: cancelLabel,
        danger: danger,
        dontAskAgainLabel: dontAskAgainLabel,
      ),
    );
    return result ?? ConfirmResult.cancelled;
  }

  @override
  State<AppConfirmSheet> createState() => _AppConfirmSheetState();
}

class _AppConfirmSheetState extends State<AppConfirmSheet> {
  bool _dontAsk = false;

  /// The danger icon circle.
  static const double _iconCircle = 40;
  static const double _iconSize = 22;

  /// Body top padding (C72 "dolgu 20/24/0").
  static const double _topPadding = 20;

  void _answer({required bool confirmed}) {
    Navigator.of(context).pop(
      ConfirmResult(confirmed: confirmed, dontAskAgain: confirmed && _dontAsk),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final danger = widget.danger;
    final hasCheckbox = widget.dontAskAgainLabel != null;

    final title = Semantics(
      header: true,
      child: Text(
        widget.title,
        style: text.titleMd.copyWith(color: colors.textPrimary),
      ),
    );

    final heading = danger
        ? Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ExcludeSemantics(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.errorBg,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(
                      dimension: _iconCircle,
                      child: Center(
                        child: PhosphorIcon(
                          PhosphorIconsRegular.warningCircle,
                          size: _iconSize,
                          color: colors.error,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(child: title),
              ],
            ),
          )
        : title;

    return AppSheetFrame(
      semanticLabel: widget.title,
      showClose: false,
      bodyPadding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        _topPadding,
        AppSpacing.s24,
        0,
      ),
      footerTopPadding: hasCheckbox ? AppSpacing.s12 : AppSpacing.s24,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          if (widget.message case final message?) ...[
            SizedBox(height: danger ? AppSpacing.s12 : AppSpacing.s8),
            Text(
              message,
              style: text.body.copyWith(color: colors.textSecondary),
            ),
          ],
          if (widget.dontAskAgainLabel case final label?) ...[
            const SizedBox(height: AppSpacing.s12),
            AppCheckbox(
              value: _dontAsk,
              label: label,
              focusGapColor: colors.bgRaised,
              onChanged: (value) => setState(() => _dontAsk = value),
            ),
          ],
        ],
      ),
      primary: AppSheetAction(
        label: widget.confirmLabel,
        variant: danger ? AppButtonVariant.danger : AppButtonVariant.primary,
        onPressed: () => _answer(confirmed: true),
      ),
      secondary: AppSheetAction(
        label: widget.cancelLabel ?? l10n.common_cancel,
        variant: AppButtonVariant.quiet,
        autofocus: danger,
        onPressed: () => _answer(confirmed: false),
      ),
    );
  }
}
