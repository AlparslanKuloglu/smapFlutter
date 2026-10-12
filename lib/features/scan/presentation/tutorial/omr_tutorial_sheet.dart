import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/scan/presentation/widgets/omr_illustrations.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/controls/app_checkbox.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// "Formu böyle çek": the how-to-shoot sheet over the camera (pano 4.2; spec
/// §4.C 4.2).
///
/// A tall sheet with the title, the drawing of the form (the answer area in
/// the orange dashed frame, the subject-name strip crossed out in red, three
/// numbered badges), the three steps, and the primary "Anladım". The first
/// time it also carries the checkbox "Bir daha gösterme"; opened with the "?"
/// button it does not ([offerDontShowAgain] false: "tek fark bu").
///
/// It pops a `bool`: whether "Bir daha gösterme" was ticked. A dismissal
/// (drag, scrim) is `null`.
class OmrTutorialSheet extends StatefulWidget {
  const OmrTutorialSheet({required this.offerDontShowAgain, super.key});

  /// Whether the "Bir daha gösterme" checkbox is drawn.
  final bool offerDontShowAgain;

  /// Opens the sheet over the camera. Completes with whether "Bir daha
  /// gösterme" was ticked; `false` when the sheet was dismissed or when the
  /// checkbox was not offered.
  static Future<bool> show({
    required bool offerDontShowAgain,
    BuildContext? context,
  }) async {
    final answer = await AppSheet.show<bool>(
      context: context,
      size: AppSheetSize.full,
      builder: (_) => OmrTutorialSheet(offerDontShowAgain: offerDontShowAgain),
    );
    return answer ?? false;
  }

  @override
  State<OmrTutorialSheet> createState() => _OmrTutorialSheetState();
}

class _OmrTutorialSheetState extends State<OmrTutorialSheet> {
  final ValueNotifier<bool> _dontShowAgain = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _dontShowAgain.dispose();
    super.dispose();
  }

  /// The drawing's box: 12 padding, radius 16 (pano 4.2).
  static const double _drawingPadding = 12;

  /// The body padding of the board: 12, 24, 0.
  static const EdgeInsets _bodyPadding = EdgeInsets.fromLTRB(
    AppSpacing.s24,
    AppSpacing.s12,
    AppSpacing.s24,
    0,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final steps = [
      l10n.scan_tutorialStep1,
      l10n.scan_tutorialStep2,
      l10n.scan_tutorialStep3,
    ];
    return AppSheetFrame(
      title: l10n.scan_tutorialTitle,
      showClose: false,
      bodyPadding: _bodyPadding,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.bgCanvas,
              borderRadius: AppRadius.borderLg,
            ),
            child: const Padding(
              padding: EdgeInsets.all(_drawingPadding),
              child: Center(child: OmrTutorialIllustration()),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          for (final (index, step) in steps.indexed)
            _TutorialStep(number: index + 1, label: step),
          if (widget.offerDontShowAgain)
            ValueListenableBuilder<bool>(
              valueListenable: _dontShowAgain,
              builder: (context, ticked, _) => AppCheckbox(
                value: ticked,
                label: l10n.scan_dontShowAgain,
                focusGapColor: colors.bgRaised,
                onChanged: (value) => _dontShowAgain.value = value,
              ),
            ),
        ],
      ),
      primary: AppSheetAction(
        label: l10n.scan_gotIt,
        onPressed: () => Navigator.of(context).pop(_dontShowAgain.value),
      ),
    );
  }
}

/// One numbered step: a 28 pt `infoBg` circle with the number in `primary`
/// (15/28 · 700) and the sentence at 16/24 (pano 4.2).
class _TutorialStep extends StatelessWidget {
  const _TutorialStep({required this.number, required this.label});

  final int number;
  final String label;

  static const double _circle = 28;

  /// The sentence sits 2 lower than the circle's top (pano 4.2).
  static const double _textTop = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.infoBg,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: _circle,
                child: Center(
                  child: Text(
                    '$number',
                    style: text.bodyStrong.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      height: 28 / 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: _textTop),
              child: Text(
                label,
                style: text.bodyLg.copyWith(color: colors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
