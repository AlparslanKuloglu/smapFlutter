import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/cards/data/card_repository.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/lessons/application/topic_outline.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';
import 'package:smap/features/lessons/presentation/lessons_navigator.dart';
import 'package:smap/features/lessons/presentation/topic_detail/topic_detail_state.dart';
import 'package:smap/features/lessons/presentation/topic_detail/topic_detail_viewmodel.dart';
import 'package:smap/features/lessons/presentation/widgets/eksik_tag.dart';
import 'package:smap/features/lessons/presentation/widgets/example_box.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/feedback/app_empty_state.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/app_state_level.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/surfaces/app_accordion.dart';

part 'widgets/topic_detail_body.dart';
part 'widgets/topic_detail_header.dart';
part 'widgets/topic_detail_item.dart';
part 'widgets/topic_detail_states.dart';

/// Konu Detayı (pano 7.3 "Konu Detayı · 3 kare", 7.5 kare 3, 7.6 koyu; spec
/// §4.F 7.3; route `/lessons/:lessonId/topics/:topicId?focus=&cat=`).
///
/// The reading screen of a topic: its name, "Türkçe · TYT · 1. konu", "5 alt
/// başlık · 25 madde" and one accordion card per sub-topic (C50), each holding
/// the numbered items: an open item shows its definition, the example in its
/// own box (C51) and "Kartı Aç", which opens the card sheet. A missing item
/// wears the amber "Eksik" tag, a sub-topic counts them. With `focus=
/// firstMissing` the first missing item is open and the screen scrolls to it
/// in 350 ms (a jump under "Reduce motion").
///
/// [lessonId] is the general lesson's id and [topicId] the main subject's;
/// [cat] (`tyt`, `ayt`, `sos2`, `all`) is the category the topic is read
/// under, without it the device's last exam type (or "Tümü" for a lesson
/// without tracks).
@RoutePage()
class TopicDetailView extends StackedView<TopicDetailViewModel> {
  const TopicDetailView({
    @PathParam('lessonId') required this.lessonId,
    @PathParam('topicId') required this.topicId,
    @QueryParam('focus') this.focus = 'firstMissing',
    @QueryParam('cat') this.cat,
    super.key,
  });

  final String lessonId;
  final String topicId;
  final String? focus;
  final String? cat;

  @override
  bool get reactive => false;

  @override
  TopicDetailViewModel viewModelBuilder(BuildContext context) =>
      TopicDetailViewModel(
        lessonId: lessonId,
        topicId: topicId,
        lessons: locator<LessonsService>(),
        content: locator<LessonContentRepository>(),
        cards: locator<CardRepository>(),
        preferences: locator<DevicePreferences>(),
        toast: locator<ToastService>(),
        focus: focus,
        cat: LessonCat.parse(cat),
      );

  @override
  void onViewModelReady(TopicDetailViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    TopicDetailViewModel viewModel,
    Widget? child,
  ) => _TopicPage(viewModel: viewModel);
}

/// The page. Its one `State` owns what the UI owns: the anchors of the items
/// (to scroll to the first missing one) and the listener that does it.
class _TopicPage extends StatefulWidget {
  const _TopicPage({required this.viewModel});

  final TopicDetailViewModel viewModel;

  @override
  State<_TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<_TopicPage> {
  final Map<String, GlobalKey> _anchors = {};

  /// Where the first missing item sits in the viewport when it is scrolled
  /// to: a fifth down, under the bar.
  static const double _focusAlignment = 0.2;

  @override
  void initState() {
    super.initState();
    widget.viewModel.focusRequest.addListener(_onFocus);
  }

  @override
  void dispose() {
    widget.viewModel.focusRequest.removeListener(_onFocus);
    super.dispose();
  }

  GlobalKey _anchorOf(String itemKey) =>
      _anchors.putIfAbsent(itemKey, GlobalKey.new);

  /// The first missing item is on screen: scroll to it after the frame that
  /// built it (350 ms, standard curve; a jump under "Reduce motion").
  void _onFocus() {
    final target = widget.viewModel.focusRequest.value;
    if (target == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final anchor = _anchors[target.itemKey]?.currentContext;
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
    return _TopicAnchors(
      anchorOf: _anchorOf,
      child: Scaffold(
        backgroundColor: context.appColors.bgCanvas,
        body: CustomScrollView(
          slivers: [
            const _TopicBar(),
            const _TopicTitle(),
            const _TopicBody(),
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

/// Hands the anchor of an item to its tile.
class _TopicAnchors extends InheritedWidget {
  const _TopicAnchors({required this.anchorOf, required super.child});

  final GlobalKey Function(String itemKey) anchorOf;

  static GlobalKey of(BuildContext context, String itemKey) =>
      context.getInheritedWidgetOfExactType<_TopicAnchors>()!.anchorOf(itemKey);

  @override
  bool updateShouldNotify(_TopicAnchors oldWidget) => false;
}
