part of '../contract_reader_view.dart';

/// "Sürüm 1.2.0" under the bar (pano 9.7 kare 2): 13/20 `textSecondary`.
class _ReaderVersion extends StatelessWidget {
  const _ReaderVersion({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Text(
        version,
        style: context.appText.caption.copyWith(
          color: context.appColors.textSecondary,
        ),
      ),
    );
  }
}

/// The text of the document, drawn in the app's reading type (pano 9.7 kare
/// 2): paragraphs `bodyReading` 16/26 with 10 under them, headings 17/24 ·
/// 700 with margin 20 above and 6 below.
class _ReaderText extends StatelessWidget {
  const _ReaderText({required this.html});

  final String html;

  /// Heading margins and the gap after a paragraph (pano 9.7 kare 2).
  static const double _headingTop = 20;
  static const double _headingBottom = 6;
  static const double _paragraphGap = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final heading =
        Style.fromTextStyle(
          text.barTitle.copyWith(color: colors.textPrimary),
        ).copyWith(
          margin: Margins.only(top: _headingTop, bottom: _headingBottom),
        );
    return Html(
      data: html,
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
    );
  }
}

/// The document has no text.
class _ReaderEmpty extends StatelessWidget {
  const _ReaderEmpty();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context).account_readerEmpty,
      style: context.appText.bodyReading.copyWith(
        color: context.appColors.textSecondary,
      ),
    );
  }
}
