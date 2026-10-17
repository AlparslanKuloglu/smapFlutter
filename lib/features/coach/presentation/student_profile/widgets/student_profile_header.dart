part of '../student_profile_view.dart';

/// The student's name (24/32 · 700, the page's heading) and, under it,
/// "alparslan.k · 10 deneme" (pano 10.4 "Başlık (top 154)"). A part the
/// student document does not have is not written ("son 5 Eki. 2026" is not
/// in it). The tabs pin when this block has scrolled away. Not drawn while
/// the Program tab is being edited (pano 14.1 kare 3).
class _ProfileHeader
    extends SelectorViewModelWidget<StudentProfileViewModel, StudentProfile?> {
  const _ProfileHeader();

  @override
  StudentProfile? selector(StudentProfileViewModel viewModel) =>
      viewModel.profile.data;

  @override
  Widget build(BuildContext context, StudentProfile? profile) {
    if (profile == null) return _noSliver;
    final l10n = AppLocalizations.of(context);
    final meta = StudentProfileTexts.meta(l10n, profile);
    final anchors = _PageAnchors.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: anchors.edit.editing,
      builder: (context, editing, _) => editing
          ? _noSliver
          : SliverToBoxAdapter(
              child: KeyedSubtree(
                key: anchors.headerKey,
                child: _HeaderBlock(profile: profile, meta: meta),
              ),
            ),
    );
  }
}

/// The name and the meta line under it.
class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock({required this.profile, required this.meta});

  final StudentProfile profile;
  final String? meta;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s8,
        AppSpacing.gutter,
        AppSpacing.s16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              profile.name,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: text.titleLg.copyWith(color: colors.textPrimary),
            ),
          ),
          if (meta case final line?)
            Text(
              line,
              style: text.caption.copyWith(color: colors.textSecondary),
            ),
        ],
      ),
    );
  }
}
