import 'package:flutter/material.dart';

import 'package:smap/features/analytics/presentation/screens/subject_detail_page.dart';
import 'package:smap/features/legacy/legacy_theme.dart';

/// Links from the program screens (E7) to screens that are not migrated yet.
/// Each goes with its target when that screen task lands (the topic detail is
/// E12's "Konu Detayı", pano 7.3).
abstract final class LegacyLinksE7 {
  /// The legacy topic screen of a program topic: [mainSubjectId] is the
  /// topic's main subject (a task's `mainSubject`), [topicName] its title.
  ///
  /// It opens on the tab's own navigator, above the screen that asked, with
  /// every track shown ("Tümü", filter value 9) because a task keeps no track.
  static Future<void> openTopicDetail(
    BuildContext context, {
    required String mainSubjectId,
    required String topicName,
  }) => Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => LegacyTheme(
        child: SubTopicDetailPage(
          topicId: mainSubjectId,
          topicName: topicName,
          tabFilterValue: 9,
        ),
      ),
    ),
  );
}
