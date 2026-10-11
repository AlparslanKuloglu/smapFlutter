import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/account/data/dtos/legal_document_dto.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// A legal text opened from the sign-up consent line (pano 2.5 kare 2 "Tek
/// satır onay; bağlantılar metni sheet'te açar"; spec §3.4 "Sözleşme metni ·
/// full").
///
/// A full sheet: the document's title ("Kullanım Koşulları"), "Sürüm 1.2.0"
/// under it and the text itself, which the server sends as HTML and which is
/// drawn in the app's reading type (`bodyReading` 16/26, headings 17/24 ·
/// 700; pano 9.7 kare 2), not as a web view. It is only read: closing is the
/// "Kapat" button or a drag.
class LegalTextSheet extends StatelessWidget {
  const LegalTextSheet({required this.document, this.fallbackTitle, super.key});

  final LegalDocumentDto document;

  /// The title when the document has none.
  final String? fallbackTitle;

  /// Heading margins and the gap after a paragraph (pano 9.7 kare 2: "margin
  /// 20 0 6", "margin 0 0 10").
  static const double _headingTop = 20;
  static const double _headingBottom = 6;
  static const double _paragraphGap = 10;

  /// Opens [document] on the root navigator; completes when it is closed.
  static Future<void> show(
    LegalDocumentDto document, {
    String? fallbackTitle,
  }) => AppSheet.show<void>(
    size: AppSheetSize.full,
    builder: (_) =>
        LegalTextSheet(document: document, fallbackTitle: fallbackTitle),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final content = document.content?.trim() ?? '';
    final version = document.version;
    final heading =
        Style.fromTextStyle(
          text.barTitle.copyWith(color: colors.textPrimary),
        ).copyWith(
          margin: Margins.only(top: _headingTop, bottom: _headingBottom),
        );
    return AppSheetFrame(
      title: document.title ?? fallbackTitle,
      subtitle: version == null ? null : l10n.register_legalVersion(version),
      body: content.isEmpty
          ? Text(
              l10n.register_legalEmpty,
              style: text.bodyReading.copyWith(color: colors.textSecondary),
            )
          : Html(
              data: content,
              style: {
                'body': Style.fromTextStyle(
                  text.bodyReading.copyWith(color: colors.textPrimary),
                ).copyWith(margin: Margins.zero, padding: HtmlPaddings.zero),
                'p': Style(margin: Margins.only(bottom: _paragraphGap)),
                'h1': heading,
                'h2': heading,
                'h3': heading,
                'a': Style(color: colors.textAction),
              },
            ),
      bodyPadding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s8,
        AppSpacing.s24,
        AppSpacing.s24,
      ),
    );
  }
}
