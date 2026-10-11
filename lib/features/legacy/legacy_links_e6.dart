import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/domain/models/general_lessons.dart' as legacy;
import 'package:smap/features/analytics/presentation/screens/edebiyat_lesson_detail_page.dart'
    show EdebiyatLessonDetailPage;
import 'package:smap/features/analytics/presentation/screens/lesson_detail_page.dart'
    show LessonDetailPage;
import 'package:smap/features/analytics/presentation/screens/my_test_result_detail_screen.dart';
import 'package:smap/features/analytics/presentation/screens/subject_detail_page.dart'
    show SubTopicDetailPage;
import 'package:smap/features/home/presentation/screens/my_schedule_page/day_selection_page/day_selection_page.dart';
import 'package:smap/features/home/presentation/screens/my_schedule_page/my_schedule_page.dart';
import 'package:smap/features/legacy/legacy_theme.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/repository/analysis_repository.dart';
import 'package:smap/repository/weekly_repository.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/indicators/app_spinner.dart';
import 'package:smap/core/constants/lesson_constants.dart';

/// Where the new home screen (E6, pano 3.1) goes while the screens it links to
/// are still the legacy ones: Deneme Detay (E10), Ders Detayı and Konu Detayı
/// (E12) and Programım (E7).
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

  /// The lesson [lessonId] (a general lesson's id): the legacy lesson detail
  /// with the track of "Derslerim"'s last TYT/AYT choice (TYT at first,
  /// assumption 6.6) instead of the old "TYT, AYT or SOS-2" dialog.
  static Future<void> openLessonDetail(
    BuildContext context, {
    required String lessonId,
  }) {
    final spec = LessonCatalog.byId(lessonId);
    if (spec == null) return Future.value();
    final lesson = legacy.GeneralLesson(
      id: spec.id,
      name: spec.name,
      image: '',
      order: spec.order,
      isTytAyt: spec.hasTrackChoice,
      isMindMap: spec.isWebOnly,
    );
    if (spec.isLiterature) {
      return _push(
        context,
        EdebiyatLessonDetailPage(lesson: lesson, examType: 'noExamType'),
      );
    }
    if (!spec.hasTrackChoice) {
      return _push(
        context,
        LessonDetailPage(
          lesson: lesson,
          examType: 'noExamType',
          defaultFilterValue: _allTracksFilter,
          lessonFullName: spec.name,
        ),
      );
    }
    final ayt = _lastExamType() == 'ayt';
    return _push(
      context,
      LessonDetailPage(
        lesson: lesson,
        examType: ayt ? 'AYT' : 'TYT',
        defaultFilterValue: ayt ? (spec.ids.hasSos2 ? 3 : 2) : 1,
        lessonFullName: '${ayt ? 'AYT' : 'TYT'} ${spec.name}',
      ),
    );
  }

  /// The topic of a planned task: the legacy sub-topic page of the main
  /// subject [topicId]. Without a main subject the lesson opens instead.
  static Future<void> openTopic(
    BuildContext context, {
    required String? topicId,
    required String topicName,
    String? lessonId,
  }) {
    if (topicId == null || topicId.isEmpty) {
      return lessonId == null
          ? Future.value()
          : openLessonDetail(context, lessonId: lessonId);
    }
    return _push(
      context,
      SubTopicDetailPage(
        topicId: topicId,
        topicName: topicName,
        tabFilterValue: _allTracksFilter,
      ),
    );
  }

  /// "Programım": the legacy program list.
  static Future<void> openProgram(BuildContext context) =>
      _push(context, const _LegacyProgramPage());

  /// "Haftalık Programını Kur": the legacy new-program flow (day selection).
  static Future<void> openProgramSetup(BuildContext context) {
    final repository = WeeklyRepository();
    return DaySelectionPage.open(
      context,
      repository: repository,
      allLessons: AppLessons.allLessons,
    );
  }

  /// The filter value "Tümü" of the legacy screens (`defaultFilterValue` 9).
  static const int _allTracksFilter = 9;

  static String? _lastExamType() {
    if (!locator.isRegistered<DevicePreferences>()) return null;
    return locator<DevicePreferences>().getString(
      DevicePreferences.lessonsExamTypeKey,
    );
  }

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

/// "Programım" (legacy): the program list; its "add" button opens the day
/// selection.
class _LegacyProgramPage extends StatelessWidget {
  const _LegacyProgramPage();

  @override
  Widget build(BuildContext context) => _LegacyFrame(child: MySchedulePage());
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
