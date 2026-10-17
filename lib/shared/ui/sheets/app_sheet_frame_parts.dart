part of 'app_sheet_frame.dart';

/// Handle and title row.
class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.header,
    required this.showClose,
    required this.busy,
    required this.onClose,
  });

  final String? title;
  final String? subtitle;
  final Widget? header;
  final bool showClose;
  final bool busy;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final fade = context.motion(AppMotion.fast, reduced: AppMotion.fast);

    final titleRow =
        header ??
        (title == null && subtitle == null
            ? null
            : Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s24,
                  AppSpacing.s12,
                  AppSpacing.s12,
                  0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title case final value?)
                            Semantics(
                              header: true,
                              child: Text(
                                value,
                                style: text.titleMd.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          if (subtitle case final value?) ...[
                            const SizedBox(height: AppSpacing.s4),
                            Text(
                              value,
                              style: text.body.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showClose && !busy)
                      SizedBox(
                        width: AppSize.touch,
                        height: AppSheetFrame._closeBox,
                        child: OverflowBox(
                          minHeight: AppSize.touch,
                          maxHeight: AppSize.touch,
                          child: AppIconButton(
                            icon: PhosphorIconsRegular.x,
                            semanticLabel: l10n.common_close,
                            variant: AppIconButtonVariant.close,
                            focusGapColor: colors.bgRaised,
                            onPressed: onClose,
                          ),
                        ),
                      )
                    else if (showClose)
                      const SizedBox(width: AppSize.touch),
                  ],
                ),
              ));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: SizedBox(
            height: AppSheetFrame.handleStrip,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: fade,
                width: AppSize.sheetHandleWidth,
                height: AppSize.sheetHandleHeight,
                decoration: BoxDecoration(
                  color: busy ? colors.bgSunken : colors.borderStrong,
                  borderRadius: AppRadius.borderFull,
                ),
              ),
            ),
          ),
        ),
        ?titleRow,
      ],
    );
  }
}

/// The fixed button band.
class _Footer extends StatelessWidget {
  const _Footer({
    required this.primary,
    required this.secondary,
    required this.busy,
    required this.topPadding,
    required this.bottomPadding,
    required this.underFooter,
    required this.gapColor,
  });

  final AppSheetAction? primary;
  final AppSheetAction? secondary;
  final bool busy;
  final double topPadding;
  final double bottomPadding;
  final ValueListenable<bool> underFooter;
  final Color gapColor;

  Widget _button(AppSheetAction action, {required bool locked}) {
    return AppButton(
      label: action.label,
      onPressed: locked ? null : action.onPressed,
      variant: action.variant,
      icon: action.icon,
      trailingIcon: action.trailingIcon,
      loading: action.loading || (locked && action == primary),
      expand: true,
      autofocus: action.autofocus,
      focusGapColor: gapColor,
      disabledReason: action.disabledReason,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final actions = [?primary, ?secondary];
    final content = actions.isEmpty
        ? SizedBox(height: bottomPadding)
        : Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s24,
              topPadding,
              AppSpacing.s24,
              bottomPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, action) in actions.indexed) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.s12),
                  _button(
                    action,
                    // A busy sheet keeps the primary's spinner and silences
                    // the rest.
                    locked: busy,
                  ),
                ],
              ],
            ),
          );
    return ValueListenableBuilder<bool>(
      valueListenable: underFooter,
      builder: (context, scrolled, child) => DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: scrolled ? colors.borderSubtle : colors.borderSubtle.clear,
            ),
          ),
        ),
        child: child,
      ),
      child: content,
    );
  }
}
