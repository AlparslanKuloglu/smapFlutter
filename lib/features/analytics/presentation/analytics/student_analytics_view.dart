import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/analytics/application/exam_favorites.dart';
import 'package:smap/features/analytics/data/analytics_repository.dart';
import 'package:smap/features/analytics/presentation/analytics/analytics_view.dart';
import 'package:smap/features/analytics/presentation/analytics/analytics_viewmodel.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';

/// Which of Analizlerim's two tabs a coach's student profile shows.
enum StudentAnalyticsPart {
  /// "Analiz": the filter pill, the net chart and the stat boxes (pano 10.4
  /// kare 1, "6.1'in aynısı").
  general,

  /// "Denemeler": the student's exams, newest first (pano 10.4 kare 2,
  /// "6.2 satırları").
  exams,
}

/// The sections of Analizlerim for a coach reading one student (E17; pano
/// 10.4 kare 1 and 2; spec 05 §10.4 "Taşıma kuralı").
///
/// It is the screen of the student's own Analizlerim without its band and
/// scroll view: the same ViewModel with the student's id (every request
/// carries it) and the student's own AYT field, and the same section widgets
/// ([AnalyticsGeneralSliver], [AnalyticsExamsSliver]) as one sliver for the
/// profile's scroll view. The differences are the coach's: the exam list has
/// no type segment, no filter sheet and no favorite star, a row opens the
/// exam detail with the context strip, and there is no camera action.
///
/// Both parts share one ViewModel: keep this widget at the same place of the
/// tree and change [part] when the tab changes, so the loaded answers stay.
/// A request that the backend does not take for a coach's student ends in the
/// sections' own error state; nothing is made up.
class StudentAnalyticsView extends StackedView<AnalyticsViewModel> {
  const StudentAnalyticsView({
    required this.student,
    required this.part,
    super.key,
  });

  final StudentRef student;
  final StudentAnalyticsPart part;

  @override
  bool get reactive => false;

  @override
  AnalyticsViewModel viewModelBuilder(BuildContext context) =>
      AnalyticsViewModel(
        analytics: locator<AnalyticsRepository>(),
        exams: locator<ExamRepository>(),
        connectivity: locator<ConnectivityService>(),
        favorites: ExamFavorites(locator<DevicePreferences>()),
        router: locator<AppRouter>(),
        userField: AytField.fromWire(student.aimType),
        student: student,
      );

  @override
  void onViewModelReady(AnalyticsViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    AnalyticsViewModel viewModel,
    Widget? child,
  ) => switch (part) {
    StudentAnalyticsPart.general => const AnalyticsGeneralSliver(),
    StudentAnalyticsPart.exams => const AnalyticsExamsSliver(),
  };
}
