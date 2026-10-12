import 'package:flutter/material.dart';

import 'package:smap/features/analytics/presentation/screens/coach_analytics_screen.dart';
import 'package:smap/features/legacy/legacy_theme.dart';
import 'package:smap/features/my_students/add_student_dialog.dart';
import 'package:smap/repository/coach_repository.dart';

/// Where the coach home goes while the screen it links to is still the legacy
/// one: a student's analysis (E17) and "Öğrenci Ekle" (E16).
///
/// Each function opens the legacy screen on the root navigator, so it covers
/// the shell and its bar (the legacy screens know nothing of the bar), and the
/// coach home calls it from one place (`_openStudent`, `_openAddStudent` in
/// `coach_home_view.dart`). When the screen task lands, the function is replaced
/// by the route or the sheet and goes from here; this file goes with the last of
/// them. It lives in the legacy folder, where `Navigator`, `showDialog` and
/// `MaterialPageRoute` are allowed.
abstract final class LegacyLinksE15 {
  /// A student's analysis: the legacy screen the old home and student list
  /// opened for a student's analysis, on its first tab.
  ///
  /// The legacy screen takes the avatar as a path under `assets/`
  /// (`avatars/1avatarN3.png`) and draws the initials for an empty one.
  static Future<void> openStudentAnalysis(
    BuildContext context, {
    required String studentId,
    required String studentName,
    String? photo,
  }) => Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => LegacyTheme(
        child: CoachAnalyticsDetailScreen(
          studentName: studentName,
          studentId: studentId,
          initialTabIndex: 0,
          studentImage: _assetPath(photo),
        ),
      ),
    ),
  );

  /// "Öğrenci Ekle": the legacy dialog, which writes through the legacy coach
  /// repository. Completes when it closes; the caller reads the student list
  /// again. Once `AddStudentSheet` (E16) exists the body is
  /// `AddStudentSheet.show(context)`.
  static Future<void> openAddStudent(BuildContext context) =>
      showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            LegacyTheme(child: AddStudentDialog(repository: CoachRepository())),
      );

  static String _assetPath(String? photo) {
    final name = photo?.trim();
    if (name == null || name.isEmpty) return '';
    if (name.startsWith('avatars/')) return name;
    return 'avatars/$name';
  }
}
