import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/features/analytics/presentation/provider/analytics_view_provider.dart';
import 'package:smap/features/analytics/presentation/widgets/analytics_tabs.dart';
import 'package:smap/features/analytics/presentation/widgets/general_tab.dart';
import 'package:smap/features/analytics/presentation/widgets/general_filter_panel.dart';
import 'package:smap/features/analytics/presentation/widgets/my_test_results_tab.dart';
import 'package:smap/features/analytics/presentation/widgets/section_placeholder.dart';
import 'package:smap/repository/analysis_repository.dart';

// analytics_view.dart

class AnalyticsView extends StatefulWidget {
  final String? studentId;
  final int? initialTabIndex;

  const AnalyticsView({super.key, this.studentId, this.initialTabIndex});
  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  late final AnalyticsViewNotifier _notifier;

  @override
  void initState() {
    super.initState();
    // Notifier ve ilk istek SADECE 1 KEZ burada oluşturulur
    _notifier = AnalyticsViewNotifier(
      AnalysisRepository(studentId: widget.studentId),
      initialTabIndex: widget.initialTabIndex,
    );
  }

  @override
  void didUpdateWidget(covariant AnalyticsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabIndex != null &&
        widget.initialTabIndex != oldWidget.initialTabIndex &&
        widget.initialTabIndex != 0) {
      _notifier.onTopTabTap(
        widget.initialTabIndex!,
        context,
      ); // context eklendi
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _notifier, // Var olan notifier kullanılır
      child: Consumer<AnalyticsViewNotifier>(
        builder: (context, notifier, _) {
          final state = notifier.state;
          return ColoredBox(
            color: AppColors.background,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  AnalyticsTabs(
                    selectedIndex: state.topTabIndex,
                    tabs: const ['Genel', 'Denemelerim', 'Analiz', 'Harita'],
                    // notifier.onTopTabTap yerine context'i de alan bir closure (isimsiz fonksiyon) geçiyoruz:
                    onTabTap: (index) => notifier.onTopTabTap(index, context),
                    generalExpanded:
                        state.topTabIndex == 0 && state.generalFilterOpen,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        IndexedStack(
                          index: state.topTabIndex,
                          children: [
                            GeneralTab(data: state.generalData),
                            MyTestResultsTab(),
                            const SectionPlaceholder(title: 'Analiz'),
                            const SectionPlaceholder(title: 'Harita'),
                          ],
                        ),
                        if (state.topTabIndex == 0 &&
                            state.generalFilterOpen) ...[
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: notifier.closeGeneralFilter,
                              behavior: HitTestBehavior.translucent,
                              child: const SizedBox.expand(),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: GeneralFilterPanel(
                              examType: state.examType,
                              aytGroup: state.aytGroup,
                              selectedLesson: state.selectedLesson,
                              selectedLessonName: state.selectedLessonName,
                              onExamTypeChanged: notifier.setExamType,
                              onAytGroupChanged: notifier.setAytGroup,
                              onLessonChanged: (id, name) {
                                notifier.setLesson(id, name);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
