import 'package:flutter/material.dart';

import 'package:smap/features/analytics/presentation/screens/coach_analytics_screen.dart';
import 'package:smap/features/home/application/avatar_asset.dart';
import 'package:smap/features/legacy/legacy_theme.dart';

/// "Öğrencinin verileri" of Görüşme Detayı (pano 10.5 kare 3) until Öğrenci
/// Profili (E17, pano 10.4) exists: the legacy analysis screen of the student,
/// full screen on the root [navigator] (it knows nothing of the bottom bar).
///
/// The one function E17 deletes together with the legacy screen; the call
/// site is `StackMeetingsNavigator.openStudentData`, which then pushes
/// `StudentProfileRoute` instead.
Future<void> openLegacyStudentData(
  NavigatorState navigator, {
  required String studentId,
  required String name,
  String? photo,
}) {
  // The legacy screen puts "assets/" in front of the file it is given.
  final asset = AvatarAsset.pathOf(photo);
  final image = asset == null ? '' : asset.replaceFirst('assets/', '');
  return navigator.push<void>(
    MaterialPageRoute<void>(
      builder: (_) => LegacyTheme(
        child: CoachAnalyticsDetailScreen(
          studentName: name,
          studentId: studentId,
          initialTabIndex: 0,
          studentImage: image,
        ),
      ),
    ),
  );
}
