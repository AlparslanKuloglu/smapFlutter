import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/analytics/presentation/screens/my_test_result_detail_screen.dart';
import 'package:smap/features/legacy/legacy_theme.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/repository/analysis_repository.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/indicators/app_spinner.dart';

/// Where the new screens go while the screen they link to is still the legacy
/// one: Deneme Detay (E10).
///
/// Each function opens the legacy screen on the root navigator, so it covers
/// the shell and its bar (the legacy screens know nothing of the bar), and the
/// home screen calls it from one place (`HomeNavigation`). When the screen
/// task lands, the function is replaced by the route and goes from here; this
/// file goes with the last of them. It lives in the legacy folder, where
/// `Navigator` and `MaterialPageRoute` are allowed.
abstract final class LegacyLinksE6 {
  /// The exam [examId] ("Analizi Gör"): the legacy result detail.
  ///
  /// The legacy screen reads the exam object of the Denemelerim list, so a
  /// small page fetches the list, finds the exam and shows it.
  static Future<void> openExamDetail(
    BuildContext context, {
    required String examId,
  }) => _push(context, _LegacyExamDetailLoader(examId: examId));

  static Future<void> _push(BuildContext context, Widget page) =>
      Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(builder: (_) => LegacyTheme(child: page)),
      );
}

/// A legacy page's frame while it has no bar of its own: the back button
/// above the content.
class _LegacyFrame extends StatelessWidget {
  const _LegacyFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.appColors.bgCanvas,
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AppIconButton(
              icon: PhosphorIconsRegular.caretLeft,
              semanticLabel: AppLocalizations.of(context).nav_back,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    ),
  );
}

/// Fetches the Denemelerim list, picks the exam and shows the legacy result
/// detail.
class _LegacyExamDetailLoader extends StatefulWidget {
  const _LegacyExamDetailLoader({required this.examId});

  final String examId;

  @override
  State<_LegacyExamDetailLoader> createState() =>
      _LegacyExamDetailLoaderState();
}

class _LegacyExamDetailLoaderState extends State<_LegacyExamDetailLoader> {
  final AnalysisRepository _repository = AnalysisRepository();
  Map<String, dynamic>? _exam;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      for (var page = 1; page <= 3; page++) {
        final answer = await _repository.getMyMockExams(page: page);
        final list = answer['enrichedMockExams'];
        if (list is! List || list.isEmpty) break;
        for (final item in list) {
          if (item is Map<String, dynamic> &&
              item['_id']?.toString() == widget.examId) {
            if (mounted) setState(() => _exam = item);
            return;
          }
        }
      }
    } on Object {
      // Falls through to the error state.
    }
    if (mounted && _exam == null) setState(() => _failed = true);
  }

  @override
  Widget build(BuildContext context) {
    final exam = _exam;
    if (exam != null) return MyTestResultDetailScreen(data: exam);
    final l10n = AppLocalizations.of(context);
    return _LegacyFrame(
      child: _failed
          ? Padding(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              child: AppErrorState.section(
                message: l10n.errors_network,
                onRetry: _load,
              ),
            )
          : Center(child: AppSpinner(semanticLabel: l10n.kit_loading)),
    );
  }
}
