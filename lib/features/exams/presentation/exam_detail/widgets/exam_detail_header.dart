part of '../exam_detail_view.dart';

/// What the bar selects: the exam's name and type, for the short title.
typedef _BarData = (String? name, NetExamType? kind);

/// The bar of Deneme Detay (pano 5.3 kare 1 and 2): Back, and the exam's name
/// once the header has scrolled away ("Türkiye Geneli Deneme 6", two lines at
/// most). The header takes the place of the large title.
class _ExamBar extends SelectorViewModelWidget<ExamDetailViewModel, _BarData> {
  const _ExamBar();

  @override
  _BarData selector(ExamDetailViewModel viewModel) =>
      (viewModel.header?.name, viewModel.header?.kind);

  @override
  Widget build(BuildContext context, _BarData data) {
    final (name, kind) = data;
    return AppDetailBar(title: _examTitle(context, name, kind));
  }
}

/// The exam's name; "AYT denemesi" for a result the server did not name
/// (pano 6.2), nothing while there is no result.
String _examTitle(BuildContext context, String? name, NetExamType? kind) {
  if (name != null) return name;
  if (kind == null) return '';
  return AppLocalizations.of(context).analytics_examUntitled(kind.label);
}

/// The strip of a coach's student screen (C83; Tur 12 "Koç bağlamı"): pinned
/// right under the bar. The student's class and field are E17's.
class _ExamContextStrip extends StatelessWidget {
  const _ExamContextStrip({required this.student});

  final StudentRef student;

  @override
  Widget build(BuildContext context) =>
      PinnedHeaderSliver(child: AppContextStrip(student: student));
}

/// The header block or its skeleton (pano 5.3, 5.8 kare 1); nothing when the
/// screen failed.
class _ExamHeaderSection
    extends
        SelectorViewModelWidget<
          ExamDetailViewModel,
          (SectionState, ExamHeaderModel?, String?)
        > {
  const _ExamHeaderSection();

  @override
  (SectionState, ExamHeaderModel?, String?) selector(
    ExamDetailViewModel viewModel,
  ) => (viewModel.screenState, viewModel.header, viewModel.coverUrl);

  @override
  Widget build(
    BuildContext context,
    (SectionState, ExamHeaderModel?, String?) data,
  ) {
    final (state, header, coverUrl) = data;
    final key = _PageAnchors.of(context).headerKey;
    if (state == SectionState.loading) return _HeaderSkeleton(anchorKey: key);
    if (header == null) return _noSliver;
    return SliverToBoxAdapter(
      child: KeyedSubtree(
        key: key,
        child: _HeaderBlock(header: header, coverUrl: coverUrl),
      ),
    );
  }
}

/// The header (C26 `ExamHeader`, `detail` variant; pano 5.3 kare 1): padding
/// 16 at the sides, 12 under the bar's row is the bar's own; 16 under the
/// block before the tabs. The score card shows only with data for the
/// student's score type (pano 5.3 kare 3: a TYT without points has none).
class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock({required this.header, required this.coverUrl});

  final ExamHeaderModel header;
  final String? coverUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final score = header.score;
    final field = score?.field;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        _sectionGap,
      ),
      child: Semantics(
        container: true,
        child: ExamHeader.detail(
          name: _examTitle(context, header.name, header.kind),
          typeLabel: header.typeLabel,
          net: header.net,
          counts: header.counts,
          date: header.date,
          publisher: header.publisher,
          coverUrl: coverUrl,
          scoreFieldName: score == null
              ? null
              : field == null
              ? NetExamType.tyt.label
              : _fieldName(l10n, field),
          score: score?.point,
          rank: score?.rank,
          scoreHam: score?.pointHam,
          rankHam: score?.rankHam,
        ),
      ),
    );
  }
}

/// "Eşit Ağırlık", "Sayısal" or "Sözel".
String _fieldName(AppLocalizations l10n, AytField field) => switch (field) {
  AytField.equalWeight => l10n.analytics_fieldEqualWeight,
  AytField.numeric => l10n.analytics_fieldNumeric,
  AytField.verbal => l10n.analytics_fieldVerbal,
};

/// The header while the result loads (pano 5.8 kare 1): the cover, three text
/// lines, the net, the three counters and the score block; the sizes are the
/// board's.
class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton({required this.anchorKey});

  /// The key the page measures the header by.
  final GlobalKey anchorKey;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: KeyedSubtree(
      key: anchorKey,
      child: const Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          _sectionGap,
        ),
        child: AppSkeleton(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 48, height: 64),
                  SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 110, height: 16),
                        SizedBox(height: AppSpacing.s8),
                        SkeletonBox(width: 220, height: 24),
                        SizedBox(height: AppSpacing.s8),
                        SkeletonBox(width: 90, height: 16),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s16),
              SkeletonBox(width: 120, height: 40),
              SizedBox(height: AppSpacing.s16),
              Row(
                children: [
                  Expanded(child: SkeletonBox(height: 52)),
                  SizedBox(width: AppSpacing.s12),
                  Expanded(child: SkeletonBox(height: 52)),
                  SizedBox(width: AppSpacing.s12),
                  Expanded(child: SkeletonBox(height: 52)),
                ],
              ),
              SizedBox(height: AppSpacing.s16),
              SizedBox(
                width: double.infinity,
                child: SkeletonBox(height: 96, radius: AppRadius.lg),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
