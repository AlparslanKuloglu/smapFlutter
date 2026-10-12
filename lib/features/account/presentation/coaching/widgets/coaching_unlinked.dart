part of '../coaching_view.dart';

/// Gap between the blocks of "Koçun yok" (pano 9.5 kare 3: "içerik aralığı
/// 20"). Not on the 4-pt scale of `AppSpacing`.
const double _blockGap = 20;

typedef _UnlinkedData = ({CoachCodeProblem? problem, bool connecting});

/// "Koçun yok" (pano 9.5 kare 3): the sentence, the masked field, "Koça
/// Bağlan" and "Koçluk Kodu Nedir?".
class _UnlinkedSection
    extends SelectorViewModelWidget<CoachingViewModel, _UnlinkedData> {
  const _UnlinkedSection();

  @override
  _UnlinkedData selector(CoachingViewModel viewModel) =>
      (problem: viewModel.problem, connecting: viewModel.isConnecting);

  @override
  Widget build(BuildContext context, _UnlinkedData data) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.gutter,
      AppSpacing.s16,
      AppSpacing.gutter,
      0,
    ),
    sliver: SliverToBoxAdapter(child: _CodeForm(data: data)),
  );
}

/// The form with the controller the screen owns. The field uppercases and
/// puts the dash itself (`AppInputMasks.coachCode`); "bitti" on the keyboard
/// sends a complete code.
class _CodeForm extends StatefulWidget {
  const _CodeForm({required this.data});

  final _UnlinkedData data;

  @override
  State<_CodeForm> createState() => _CodeFormState();
}

class _CodeFormState extends State<_CodeForm> {
  final TextEditingController _code = TextEditingController();

  CoachingViewModel get _viewModel =>
      getParentViewModel<CoachingViewModel>(context, listen: false);

  @override
  void initState() {
    super.initState();
    _code.addListener(_edited);
  }

  @override
  void dispose() {
    _code
      ..removeListener(_edited)
      ..dispose();
    super.dispose();
  }

  void _edited() => _viewModel.codeEdited(_code.text);

  void _submit() => _viewModel.connect(_code.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final data = widget.data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.coaching_unlinkedIntro,
          style: context.appText.bodyLg.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: _blockGap),
        AppTextField(
          label: l10n.coaching_codeLabel,
          controller: _code,
          hintText: l10n.coaching_codeHint,
          helperText: l10n.coaching_codeHelp,
          errorText: data.problem == CoachCodeProblem.notFound
              ? l10n.coaching_errNotFound
              : null,
          enabled: !data.connecting,
          inputFormatters: [AppInputMasks.coachCode],
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: _blockGap),
        ValueListenableBuilder<bool>(
          valueListenable: _viewModel.codeComplete,
          builder: (context, complete, _) => AppButton(
            label: l10n.coaching_connect,
            loading: data.connecting,
            expand: true,
            onPressed: complete ? _submit : null,
          ),
        ),
        _PulledText(
          child: AppButton(
            label: l10n.coaching_whatIsCode,
            icon: PhosphorIconsRegular.question,
            variant: AppButtonVariant.text,
            onPressed: _viewModel.showCodeInfo,
          ),
        ),
      ],
    );
  }
}
