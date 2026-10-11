import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/cards/data/card_repository.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/lesson_rows.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';
import 'package:smap/features/lessons/presentation/lesson_detail/lesson_detail_state.dart';
import 'package:smap/features/lessons/presentation/lesson_detail/lesson_detail_viewmodel.dart';
import 'package:smap/features/lessons/presentation/stack_lessons_navigator.dart';
import 'package:smap/features/lessons/presentation/widgets/author_row.dart';
import 'package:smap/features/lessons/presentation/widgets/subject_glyph.dart';
import 'package:smap/features/lessons/presentation/widgets/topic_row.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/controls/app_chip.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/feedback/app_empty_state.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';
import 'package:smap/shared/ui/surfaces/app_row_group.dart';

part 'widgets/lesson_detail_authors.dart';
part 'widgets/lesson_detail_filters.dart';
part 'widgets/lesson_detail_header.dart';
part 'widgets/lesson_detail_states.dart';
part 'widgets/lesson_detail_topics.dart';

/// Ders Detayı (pano 7.2 "Ders Detayı · 3 kare", 7.4 "Edebiyat · Yazar ve
/// Eserler", 7.5 kare 2; spec §4.F 7.2 and 7.4; route
/// `/lessons/:lessonId?cat=&eksik=&section=`).
///
/// The back button, the lesson's glyph and name, the "Eksiklerim (31)" chip
/// and the "Kartlarım" button, the category segment with its counters and the
/// list of topic rows (C22) numbered 1 to n. "Eksiklerim" keeps the topics
/// with something missing; the numbers stay those of the full list. A topic
/// opens Konu Detayı.
///
/// Türk Dili ve Edebiyatı has a second segment, Konular and Yazar ve Eserler
/// (kept on the device); the author list opens the author sheet.
///
/// [lessonId] is the general lesson's id; [cat] (`tyt`, `ayt`, `sos2`, `all`)
/// opens a segment ("Tarih-2 → SOS-2 seçili"), without it the device's last
/// exam type; [onlyMissing] opens with the filter on; [section] (`topics`,
/// `authors`) picks the Edebiyat section.
@RoutePage()
class LessonDetailView extends StackedView<LessonDetailViewModel> {
  const LessonDetailView({
    @PathParam('lessonId') required this.lessonId,
    @QueryParam('cat') this.cat,
    @QueryParam('eksik') this.onlyMissing = false,
    @QueryParam('section') this.section,
    super.key,
  });

  final String lessonId;
  final String? cat;
  final bool onlyMissing;
  final String? section;

  @override
  bool get reactive => false;

  @override
  LessonDetailViewModel viewModelBuilder(BuildContext context) =>
      LessonDetailViewModel(
        lessonId: lessonId,
        lessons: locator<LessonsService>(),
        content: locator<LessonContentRepository>(),
        cards: locator<CardRepository>(),
        preferences: locator<DevicePreferences>(),
        navigator: StackLessonsNavigator(context.router),
        toast: locator<ToastService>(),
        cat: LessonCat.parse(cat),
        onlyMissing: onlyMissing,
        section: LiteratureSection.parse(section),
      );

  @override
  void onViewModelReady(LessonDetailViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    LessonDetailViewModel viewModel,
    Widget? child,
  ) => const _LessonDetailPage();
}

/// The page: the bar, the title block, the controls and the section, in one
/// `CustomScrollView`; the tab runs under the bottom bar.
class _LessonDetailPage extends StatelessWidget {
  const _LessonDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        slivers: [
          const _LessonBar(),
          const _LessonTitle(),
          const _LessonSectionBar(),
          const _LessonFilterBar(),
          const _LessonSegmentBar(),
          const _LessonTopicsSection(),
          const _LessonAuthorsSection(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppBottomBar.heightOf(context) + AppSpacing.s16,
            ),
          ),
        ],
      ),
    );
  }
}

/// The name a lesson is written with in the bar and under it.
String _lessonTitle(BuildContext context, LessonHeaderData data) =>
    data.nameKind == LessonRowName.literature
    ? AppLocalizations.of(context).lessons_literatureName
    : data.name;

/// An empty sliver: a section that is not showing.
const Widget _noSliver = SliverToBoxAdapter(child: SizedBox.shrink());
