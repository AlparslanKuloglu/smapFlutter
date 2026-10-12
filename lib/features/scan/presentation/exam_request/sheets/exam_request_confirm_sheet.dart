import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// "Talep oluşturulsun mu?" (pano 4.9 kare 3; the normal ConfirmSheet of board
/// 1.21 with a summary): the title, a `bgCanvas` box with the two answers as a
/// definition list ("Yayınevi" 13/20 · 600 over the value 16/24 · 600, a hairline
/// between, 12 above and below each), "Analizin hazır olunca Analizlerim ›
/// Denemelerim'de görünür." (15/24, `textSecondary`), the primary "Talebi
/// Gönder" and the quiet "Vazgeç".
///
/// It pops `true` for "Talebi Gönder"; "Vazgeç", the scrim and a drag are
/// `false`. Sending is the screen's job.
class ExamRequestConfirmSheet extends StatelessWidget {
  const ExamRequestConfirmSheet({
    required this.publisher,
    required this.examName,
    super.key,
  });

  final String publisher;
  final String examName;

  /// Opens the sheet; completes `true` when the request was confirmed.
  static Future<bool> show({
    required String publisher,
    required String examName,
    BuildContext? context,
  }) async {
    final answer = await AppSheet.show<bool>(
      context: context,
      builder: (_) =>
          ExamRequestConfirmSheet(publisher: publisher, examName: examName),
    );
    return answer ?? false;
  }

  /// The summary box's padding (pano 4.9: 4 / 16) and the rows' (12 / 0).
  /// The body starts 20 under the handle (pano 4.9 kare 3).
  static const double _titleTop = 20;

  static const EdgeInsets _boxPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.s16,
    vertical: AppSpacing.s4,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    return AppSheetFrame(
      semanticLabel: l10n.scan_enfConfirmTitle,
      showClose: false,
      bodyPadding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        _titleTop,
        AppSpacing.s24,
        0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.scan_enfConfirmTitle,
              style: text.titleMd.copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.bgCanvas,
              borderRadius: AppRadius.borderMd,
            ),
            child: Padding(
              padding: _boxPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SummaryRow(
                    label: l10n.scan_fieldPublisher,
                    value: publisher,
                  ),
                  ColoredBox(
                    color: colors.borderSubtle,
                    child: const SizedBox(height: 1),
                  ),
                  _SummaryRow(label: l10n.scan_fieldExamName, value: examName),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            l10n.scan_enfConfirmNote,
            style: text.body.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
      footerTopPadding: AppSpacing.s24,
      primary: AppSheetAction(
        label: l10n.scan_sendRequest,
        onPressed: () => Navigator.of(context).pop(true),
      ),
      secondary: AppSheetAction(
        label: l10n.common_cancel,
        variant: AppButtonVariant.quiet,
        onPressed: () => Navigator.of(context).pop(false),
      ),
    );
  }
}

/// One answer of the summary: its label (13/20 · 600, `textSecondary`) over the
/// value (16/24 · 600), 12 above and below.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  /// The label to the value (pano 4.9: 2).
  static const double _labelGap = 2;

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: text.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: _labelGap),
          Text(
            value,
            style: text.bodyLg.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
