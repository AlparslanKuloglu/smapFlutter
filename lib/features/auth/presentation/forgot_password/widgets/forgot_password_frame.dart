part of '../forgot_password_view.dart';

/// The shell of the first three steps (pano 2.4 kare 1 to 3): the back button,
/// the title (24/32), the sentence under it (15/24, secondary, 6 below), and
/// the form 20 below, 24 from the sides.
///
/// It scrolls, so the form stays reachable above the keyboard and at large
/// text. Back asks the ViewModel, which goes one step back.
class _StepFrame extends StatelessWidget {
  const _StepFrame({
    required this.title,
    required this.children,
    this.description,
  });

  final String title;
  final String? description;
  final List<Widget> children;

  /// Space between the title and the sentence under it.
  static const double _descriptionTop = 6;

  @override
  Widget build(BuildContext context) {
    final viewModel = getParentViewModel<ForgotPasswordViewModel>(
      context,
      listen: false,
    );
    final colors = context.appColors;
    final description = this.description;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        AppDetailBar(
          title: title,
          gutter: AppSpacing.gutterAuth,
          onLeading: viewModel.back,
        ),
        LargeTitleSliver(title: title, gutter: AppSpacing.gutterAuth),
        if (description != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.gutterAuth,
                right: AppSpacing.gutterAuth,
                top: _descriptionTop,
              ),
              child: Text(
                description,
                style: context.appText.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutterAuth,
            _stepGap,
            AppSpacing.gutterAuth,
            bottom + AppSpacing.s24,
          ),
          sliver: SliverList.separated(
            itemCount: children.length,
            separatorBuilder: (_, _) => const SizedBox(height: _stepGap),
            itemBuilder: (_, index) => children[index],
          ),
        ),
      ],
    );
  }
}
