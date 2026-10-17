import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/lessons/application/literature_service.dart';
import 'package:smap/features/lessons/presentation/literature/era_detail/era_detail_state.dart';
import 'package:smap/features/lessons/presentation/literature/era_detail/era_detail_viewmodel.dart';
import 'package:smap/features/lessons/presentation/widgets/author_row.dart';
import 'package:smap/features/lessons/presentation/widgets/eksik_tag.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/surfaces/app_accordion.dart';

part 'widgets/era_detail_authors.dart';
part 'widgets/era_detail_body.dart';
part 'widgets/era_detail_title.dart';

/// Dönem detayı (pano 14.5 kare 2 and 3, 14.7 kare 1 and 2; route
/// `/lessons/:lessonId/literature/:eraId`): the screen behind a row of Yazar
/// ve Eserler.
///
/// The era's name with the tag "2 eksik eser" under it, and one accordion
/// (C50, the 7.3 sub-topic card) per sub-subject, each with its own tag "2
/// eksik". The first accordion with a missing work opens and the page scrolls
/// to it in 350 ms (a jump under "Reduce motion"); an open accordion holds the
/// author rows (C28), loaded when it opens and shown as three skeleton rows
/// meanwhile. An author opens the author sheet.
///
/// [lessonId] is the general lesson's id (Türk Dili ve Edebiyatı) and
/// [eraId] the era's, a main subject of `yazarEserMainSubjects`.
@RoutePage()
class LiteratureEraView extends StackedView<EraDetailViewModel> {
  const LiteratureEraView({
    @PathParam('lessonId') required this.lessonId,
    @PathParam('eraId') required this.eraId,
    super.key,
  });

  final String lessonId;
  final String eraId;

  @override
  bool get reactive => false;

  @override
  EraDetailViewModel viewModelBuilder(BuildContext context) =>
      EraDetailViewModel(eraId: eraId, service: locator<LiteratureService>());

  @override
  void onViewModelReady(EraDetailViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    EraDetailViewModel viewModel,
    Widget? child,
  ) => _EraPage(viewModel: viewModel);
}

/// The page. Its one `State` owns what the UI owns: the anchors of the
/// accordions (to scroll to the first one with a missing work) and the
/// listener that does it.
class _EraPage extends StatefulWidget {
  const _EraPage({required this.viewModel});

  final EraDetailViewModel viewModel;

  @override
  State<_EraPage> createState() => _EraPageState();
}

class _EraPageState extends State<_EraPage> {
  final Map<String, GlobalKey> _anchors = {};

  /// Where the accordion sits in the viewport when it is scrolled to: a fifth
  /// down, under the bar.
  static const double _focusAlignment = 0.2;

  @override
  void initState() {
    super.initState();
    widget.viewModel.focusRequest.addListener(_onFocus);
    // Cached sub-subjects set the request before this page is listening.
    _onFocus();
  }

  @override
  void dispose() {
    widget.viewModel.focusRequest.removeListener(_onFocus);
    super.dispose();
  }

  GlobalKey _anchorOf(String subId) =>
      _anchors.putIfAbsent(subId, GlobalKey.new);

  /// The accordion to show is on screen: scroll to it after the frame that
  /// built it (350 ms, standard curve; a jump under "Reduce motion").
  void _onFocus() {
    final target = widget.viewModel.focusRequest.value;
    if (target == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final anchor = _anchors[target.subId]?.currentContext;
      if (!mounted || anchor == null || !anchor.mounted) return;
      Scrollable.ensureVisible(
        anchor,
        alignment: _focusAlignment,
        duration: context.motion(AppMotion.slow, reduced: Duration.zero),
        curve: AppMotion.standard,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _EraAnchors(
      anchorOf: _anchorOf,
      child: Scaffold(
        backgroundColor: context.appColors.bgCanvas,
        body: CustomScrollView(
          slivers: [
            const _EraBar(),
            const _EraTitle(),
            const _EraBody(),
            SliverToBoxAdapter(
              child: SizedBox(
                height: AppBottomBar.heightOf(context) + AppSpacing.s16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hands the anchor of an accordion to its card.
class _EraAnchors extends InheritedWidget {
  const _EraAnchors({required this.anchorOf, required super.child});

  final GlobalKey Function(String subId) anchorOf;

  static GlobalKey of(BuildContext context, String subId) =>
      context.getInheritedWidgetOfExactType<_EraAnchors>()!.anchorOf(subId);

  @override
  bool updateShouldNotify(_EraAnchors oldWidget) => false;
}
