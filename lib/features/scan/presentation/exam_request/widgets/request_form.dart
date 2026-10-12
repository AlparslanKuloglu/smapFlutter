part of '../scan_request_view.dart';

/// The request form page (pano 4.9 kare 1 and 2): Kapat, the title, the
/// sentence, the info card, the two fields and the pinned primary button.
///
/// Its one `State` owns what the UI owns: the two text controllers and focus
/// nodes (the ViewModel keeps the values and the errors, and asks for a focus
/// through `focusRequest` after a submit with an error: "Odak ilk hatalı
/// alana gider").
class _RequestFormPage extends StatefulWidget {
  const _RequestFormPage({super.key});

  @override
  State<_RequestFormPage> createState() => _RequestFormPageState();
}

class _RequestFormPageState extends State<_RequestFormPage> {
  final TextEditingController _publisher = TextEditingController();
  final TextEditingController _examName = TextEditingController();
  final FocusNode _publisherFocus = FocusNode();
  final FocusNode _examNameFocus = FocusNode();
  ScanRequestViewModel? _vm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = getParentViewModel<ScanRequestViewModel>(context, listen: false);
    if (!identical(vm, _vm)) {
      _vm?.focusRequest.removeListener(_onFocusRequest);
      _vm = vm..focusRequest.addListener(_onFocusRequest);
    }
  }

  void _onFocusRequest() {
    switch (_vm?.focusRequest.value) {
      case ExamRequestError.publisherRequired:
        _publisherFocus.requestFocus();
      case ExamRequestError.examNameRequired:
        _examNameFocus.requestFocus();
      case null:
        break;
    }
  }

  @override
  void dispose() {
    _vm?.focusRequest.removeListener(_onFocusRequest);
    _publisher.dispose();
    _examName.dispose();
    _publisherFocus.dispose();
    _examNameFocus.dispose();
    super.dispose();
  }

  /// The X sits 8 above the safe area edge on the board (y 54 of 62).
  static const double _lift = 8;

  /// Above the info card (pano 4.9: 20) and above the fields (28).
  static const double _cardGap = 20;
  static const double _fieldsGap = 28;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final vm = _vm!;
    final safe = MediaQuery.paddingOf(context);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              top: safe.top > _lift ? safe.top - _lift : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.s4),
                  child: AppIconButton(
                    icon: PhosphorIconsRegular.x,
                    semanticLabel: l10n.common_close,
                    onPressed: vm.close,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.scan_enfTitle,
                          style: text.titleLg.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        l10n.scan_enfBody,
                        style: text.body.copyWith(color: colors.textSecondary),
                      ),
                      const SizedBox(height: _cardGap),
                      const _SavedCard(),
                      const SizedBox(height: _fieldsGap),
                      _RequestFields(
                        publisher: _publisher,
                        examName: _examName,
                        publisherFocus: _publisherFocus,
                        examNameFocus: _examNameFocus,
                      ),
                      const SizedBox(height: AppSpacing.s24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const _RequestSubmit(),
      ],
    );
  }
}

/// The info card (pano 4.9): `bgSurface`, 12 / 16 padding, 12 between the Clock
/// (24, `info`) and "Cevapların kaydedildi. Yeniden okutman gerekmez." (15/24).
class _SavedCard extends StatelessWidget {
  const _SavedCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.borderLg,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: PhosphorIcon(
                PhosphorIconsRegular.clock,
                size: AppSize.icon,
                color: colors.info,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                l10n.scan_enfSaved,
                style: text.body.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

typedef _FieldErrors = (ExamRequestError?, ExamRequestError?);

/// The gap between the two fields (pano 4.9: 20).
const double _fieldGap = 20;

/// "Yayınevi" and "Deneme adı" (pano 4.9): labelled fields with the example
/// only as a placeholder, 20 apart, and the error under an empty one after a
/// submit ("Yayınevini yaz." / "Deneme adını yaz.").
class _RequestFields
    extends SelectorViewModelWidget<ScanRequestViewModel, _FieldErrors> {
  const _RequestFields({
    required this.publisher,
    required this.examName,
    required this.publisherFocus,
    required this.examNameFocus,
  });

  final TextEditingController publisher;
  final TextEditingController examName;
  final FocusNode publisherFocus;
  final FocusNode examNameFocus;

  @override
  _FieldErrors selector(ScanRequestViewModel viewModel) =>
      (viewModel.publisherError, viewModel.examNameError);

  @override
  Widget build(BuildContext context, _FieldErrors errors) {
    final l10n = AppLocalizations.of(context);
    final vm = getParentViewModel<ScanRequestViewModel>(context, listen: false);
    final (publisherError, examNameError) = errors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: l10n.scan_fieldPublisher,
          hintText: l10n.scan_fieldPublisherHint,
          controller: publisher,
          focusNode: publisherFocus,
          errorText: publisherError == null
              ? null
              : l10n.scan_errPublisherRequired,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          onChanged: vm.publisherChanged,
          onSubmitted: (_) => examNameFocus.requestFocus(),
        ),
        const SizedBox(height: _fieldGap),
        AppTextField(
          label: l10n.scan_fieldExamName,
          hintText: l10n.scan_fieldExamNameHint,
          controller: examName,
          focusNode: examNameFocus,
          errorText: examNameError == null
              ? null
              : l10n.scan_errExamNameRequired,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          onChanged: vm.examNameChanged,
          onSubmitted: (_) => vm.submit(),
        ),
      ],
    );
  }
}

/// "Analizimi Hazırlayın" pinned under the form, above the keyboard (pano 4.9
/// "klavye açıkken klavyenin üstünde kalır"): 16 from the sides, the bottom
/// safe area (or the keyboard) below.
class _RequestSubmit
    extends SelectorViewModelWidget<ScanRequestViewModel, bool> {
  const _RequestSubmit();

  @override
  bool selector(ScanRequestViewModel viewModel) => viewModel.sending;

  @override
  Widget build(BuildContext context, bool busy) {
    final l10n = AppLocalizations.of(context);
    final vm = getParentViewModel<ScanRequestViewModel>(context, listen: false);
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    final bottom = keyboard > 0
        ? keyboard + AppSpacing.s16
        : media.padding.bottom + AppSpacing.s8;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s8,
        AppSpacing.s16,
        bottom,
      ),
      child: AppButton(
        label: l10n.scan_enfSubmit,
        expand: true,
        loading: busy,
        onPressed: busy ? null : vm.submit,
      ),
    );
  }
}
