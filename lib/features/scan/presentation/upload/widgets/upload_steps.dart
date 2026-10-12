part of '../scan_upload_view.dart';

/// What one row of the step list shows (pano 4.5, spec C69).
enum _StepState {
  /// A navy disc with a check: finished, written in the past tense.
  done,

  /// The spinner: this is what is happening now.
  running,

  /// A 2 pt ring: waiting.
  waiting,

  /// A red WarningCircle: this step failed.
  failed,
}

/// The step list (pano 4.5; spec C69 "SmapStepList"): a card with three rows
/// of 56 pt (16 / 0 padding, 12 between the mark and the label), a divider
/// between them. The row that is running is 600 weight and, while it uploads,
/// carries the percentage on the right and an 8 pt orange bar under its label
/// that follows the real upload; waiting rows are `textSecondary`; a failed
/// row is 600 in the error color.
///
/// The progress listens to a [ValueNotifier]; the failure and the prepared
/// state are ordinary selectors. The list is one live region: the screen
/// reader hears the step change, and the percentage every 10 %.
class _UploadSteps extends ViewModelWidget<ScanUploadViewModel> {
  const _UploadSteps();

  @override
  bool get reactive => false;

  @override
  Widget build(BuildContext context, ScanUploadViewModel viewModel) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => ValueListenableBuilder<ScanJobProgress>(
        valueListenable: viewModel.progress,
        builder: (context, progress, _) => _StepList(
          progress: progress,
          failed: viewModel.failure != null,
          prepared: viewModel.prepared,
        ),
      ),
    );
  }
}

class _StepList extends StatelessWidget {
  const _StepList({
    required this.progress,
    required this.failed,
    required this.prepared,
  });

  final ScanJobProgress progress;
  final bool failed;
  final bool prepared;

  /// The percentage announced to the screen reader moves in steps of 10.
  static const int _announceStep = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final sending = progress.step == ScanJobStep.sending;
    final reading = progress.step == ScanJobStep.reading;
    final firstDone = failed
        ? prepared
        : progress.step != ScanJobStep.preparing;

    final first = _StepRow(
      state: firstDone ? _StepState.done : _StepState.running,
      label: firstDone ? l10n.scan_stepPrepared : l10n.scan_stepPreparing,
    );
    final second = failed
        ? _StepRow(state: _StepState.failed, label: l10n.scan_stepSendFailed)
        : _StepRow(
            state: reading
                ? _StepState.done
                : (sending ? _StepState.running : _StepState.waiting),
            label: reading
                ? l10n.scan_stepSent
                : (sending ? l10n.scan_stepSending : l10n.scan_stepToSend),
            percent: sending ? progress.percent : null,
          );
    final third = _StepRow(
      state: reading && !failed ? _StepState.running : _StepState.waiting,
      label: reading && !failed ? l10n.scan_stepReading : l10n.scan_stepToRead,
    );

    final announced = sending
        ? progress.percent ~/ _announceStep * _announceStep
        : null;
    final summary = failed
        ? l10n.scan_stepSendFailed
        : switch (progress.step) {
            ScanJobStep.preparing => l10n.scan_stepPreparing,
            ScanJobStep.sending =>
              '${l10n.scan_stepSending} ${l10n.scan_percent(TrFormat.sira(announced ?? 0))}',
            ScanJobStep.reading => l10n.scan_stepReading,
          };

    return Semantics(
      container: true,
      liveRegion: true,
      label: '${l10n.scan_uploadProgressA11y}: $summary',
      explicitChildNodes: false,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: AppRadius.borderLg,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
          child: Column(
            children: [
              first,
              const _StepDivider(),
              second,
              const _StepDivider(),
              third,
            ],
          ),
        ),
      ),
    );
  }
}

class _StepDivider extends StatelessWidget {
  const _StepDivider();

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.appColors.borderSubtle,
    child: const SizedBox(height: 1, width: double.infinity),
  );
}

/// One row: the mark (24), the label (16/24), the percentage at the right and,
/// under the label of a running upload, the 8 pt bar.
class _StepRow extends StatelessWidget {
  const _StepRow({required this.state, required this.label, this.percent});

  final _StepState state;
  final String label;

  /// The upload's percentage; only the sending row has one.
  final int? percent;

  /// The mark's edge.
  static const double _mark = 24;

  /// The bar's height (8 on this screen; the kit's accent bar is 4).
  static const double _bar = 8;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final waiting = state == _StepState.waiting;
    final failed = state == _StepState.failed;
    final style = text.bodyLg.copyWith(
      color: failed
          ? colors.error
          : (waiting ? colors.textSecondary : colors.textPrimary),
      fontWeight: waiting || state == _StepState.done
          ? FontWeight.w400
          : FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox.square(
            dimension: _mark,
            child: _StepMark(state: state),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(label, style: style)),
                    if (percent != null)
                      Text(
                        l10n.scan_percent(TrFormat.sira(percent!)),
                        style: text.bodyLg.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                if (percent != null) ...[
                  const SizedBox(height: AppSpacing.s8),
                  AppLinearProgress(
                    value: percent!,
                    total: 100,
                    height: _bar,
                    animate: false,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The 24 pt mark of a step (spec C69): a navy disc with a 14 pt check, the
/// spinner, the 2 pt ring, or the red warning.
class _StepMark extends StatelessWidget {
  const _StepMark({required this.state});

  final _StepState state;

  static const double _check = 14;
  static const double _ring = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fade = context.motion(AppMotion.base, reduced: AppMotion.fast);
    return AnimatedSwitcher(
      duration: fade,
      child: switch (state) {
        _StepState.done => SizedBox.square(
          key: const ValueKey('done'),
          dimension: _StepRow._mark,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: PhosphorIcon(
                PhosphorIconsBold.check,
                size: _check,
                color: colors.onPrimary,
              ),
            ),
          ),
        ),
        _StepState.running => AppSpinner(
          key: const ValueKey('running'),
          color: colors.primary,
          trackColor: colors.borderStrong,
          semanticLabel: AppLocalizations.of(context).scan_inProgressA11y,
        ),
        _StepState.waiting => SizedBox.square(
          key: const ValueKey('waiting'),
          dimension: _StepRow._mark,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.borderStrong, width: _ring),
            ),
          ),
        ),
        _StepState.failed => PhosphorIcon(
          PhosphorIconsRegular.warningCircle,
          key: const ValueKey('failed'),
          size: 24,
          color: colors.error,
        ),
      },
    );
  }
}
