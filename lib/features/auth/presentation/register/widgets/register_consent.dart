part of '../register_view.dart';

typedef _ConsentData = (SectionState, bool, RegisterIssue?);

/// The one consent line (pano 2.5 kare 2 "Kullanım Koşulları'nı ve KVKK
/// Aydınlatma Metni'ni okudum, kabul ediyorum."), or what stands in for it:
/// a skeleton while the legal texts load, the error box with "Tekrar Dene"
/// when they could not be loaded (pano 2.6 kare 3). The swap takes 250 ms.
class _ConsentSection
    extends SelectorViewModelWidget<RegisterViewModel, _ConsentData> {
  const _ConsentSection();

  @override
  _ConsentData selector(RegisterViewModel viewModel) => (
    viewModel.legal.state,
    viewModel.consent,
    viewModel.issueFor(RegisterField.consent),
  );

  @override
  Widget build(BuildContext context, _ConsentData data) {
    final (state, consent, issue) = data;
    final scope = _RegisterScope.of(context);
    final fade = context.motion(AppMotion.base, reduced: AppMotion.reducedFade);
    final Widget body = switch (state) {
      SectionState.loading => const _ConsentSkeleton(),
      SectionState.ready ||
      SectionState.empty => _ConsentRow(consent: consent, issue: issue),
      SectionState.error || SectionState.offline => const _LegalError(),
    };
    return KeyedSubtree(
      key: scope.anchors[RegisterField.consent],
      child: AnimatedSwitcher(
        duration: fade,
        child: KeyedSubtree(key: ValueKey<Type>(body.runtimeType), child: body),
      ),
    );
  }
}

/// The checkbox with the consent sentence and, under a failed submit, the
/// line "Kaydolmak için metinleri onaylaman gerekiyor." (pano 2.6 kare 2).
class _ConsentRow extends StatelessWidget {
  const _ConsentRow({required this.consent, required this.issue});

  final bool consent;
  final RegisterIssue? issue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<RegisterViewModel>(
      context,
      listen: false,
    );
    final parts = ConsentTextParts.split(
      l10n.register_consentText(
        ConsentTextParts.termsMark,
        ConsentTextParts.kvkkMark,
      ),
      termsLabel: l10n.register_consentTerms,
      kvkkLabel: l10n.register_consentKvkk,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCheckbox(
          value: consent,
          onChanged: viewModel.setConsent,
          labelChild: _ConsentLabel(parts: parts, onOpen: viewModel.openLegal),
        ),
        if (issue case final issue?) ...[
          const SizedBox(height: AppSpacing.s4),
          AppFieldMessage(
            message: registerIssueText(l10n, issue),
            tone: AppFieldMessageTone.error,
          ),
        ],
      ],
    );
  }
}

/// The consent sentence with its two links, underlined `textAction` 700, each
/// opening its text in a sheet (pano 2.5 kare 2). A `State` because tap
/// recognizers must be disposed.
class _ConsentLabel extends StatefulWidget {
  const _ConsentLabel({required this.parts, required this.onOpen});

  final List<ConsentPart> parts;
  final ValueChanged<ConsentLink> onOpen;

  @override
  State<_ConsentLabel> createState() => _ConsentLabelState();
}

class _ConsentLabelState extends State<_ConsentLabel> {
  final List<TapGestureRecognizer> _recognizers = [];

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    _disposeRecognizers();
    final linkStyle = text.bodyStrong.copyWith(
      color: colors.textAction,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: colors.textAction,
    );
    return Text.rich(
      TextSpan(
        style: text.body.copyWith(color: colors.textPrimary),
        children: [
          for (final part in widget.parts)
            if (part.link case final link?)
              TextSpan(
                text: part.text,
                style: linkStyle,
                recognizer: _link(link),
              )
            else
              TextSpan(text: part.text),
        ],
      ),
    );
  }

  TapGestureRecognizer _link(ConsentLink link) {
    final recognizer = TapGestureRecognizer()
      ..onTap = () => widget.onOpen(link);
    _recognizers.add(recognizer);
    return recognizer;
  }
}

/// The consent row while the legal texts load: a box and two lines.
class _ConsentSkeleton extends StatelessWidget {
  const _ConsentSkeleton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppSkeleton(
      semanticLabel: l10n.register_legalLoading,
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: AppCheckbox.box, height: AppCheckbox.box),
          SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SkeletonBox(),
                SizedBox(height: AppSpacing.s8),
                SkeletonBox(width: 160),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Sözleşme metinleri yüklenemedi. …" with "Tekrar Dene" (pano 2.6 kare 3).
class _LegalError extends StatelessWidget {
  const _LegalError();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<RegisterViewModel>(
      context,
      listen: false,
    );
    return AppNoticeBox(
      tone: AppNoticeTone.error,
      message: l10n.register_legalLoadFailed,
      actionLabel: l10n.common_retry,
      onAction: viewModel.loadLegal,
    );
  }
}
