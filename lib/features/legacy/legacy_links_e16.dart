import 'package:flutter/material.dart';

import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/analytics/presentation/screens/coach_analytics_screen.dart';
import 'package:smap/features/home/application/avatar_asset.dart';
import 'package:smap/features/legacy/legacy_theme.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';

/// Where a student of "Öğrencilerim" goes while E17's `StudentProfileRoute`
/// (`/coach/students/:studentId`) is not built: the coach's legacy analysis
/// screen of that student.
///
/// One function, so E17's integration swaps the one call in
/// `StackStudentsNavigator.openStudent` and deletes this file with the legacy
/// screen. The page is pushed on the Öğrencilerim tab's own stack (the
/// navigator of the router that owns the list), so Back returns to the list
/// and the bottom bar stays. The legacy screen knows nothing of the bar (the
/// new tab screens scroll under it), so the page is lifted above it the way
/// the shell lifts a legacy tab, and put under `LegacyTheme` like every
/// legacy route page.
Future<void> openLegacyStudentProfile(
  NavigatorState? navigator, {
  required String studentId,
  required String studentName,
  String? photo,
}) async {
  if (navigator == null) return;
  await navigator.push<void>(
    MaterialPageRoute<void>(
      builder: (_) => _ClearOfBottomBar(
        child: LegacyTheme(
          child: CoachAnalyticsDetailScreen(
            studentName: studentName,
            studentId: studentId,
            initialTabIndex: 0,
            studentImage: legacyStudentImage(photo),
          ),
        ),
      ),
    ),
  );
}

/// The avatar as the legacy screen wants it: a path under `assets/` that it
/// prefixes itself (`avatars/1avatarN3.png`), empty without a photo (it draws
/// the initial then). The one rule (`AvatarAsset`) knows the file name, the
/// folder form and the full asset path.
String legacyStudentImage(String? photo) {
  final path = AvatarAsset.pathOf(photo);
  if (path == null) return '';
  return path.startsWith('assets/') ? path.substring('assets/'.length) : path;
}

/// Lifts a legacy page above the bottom bar (see [openLegacyStudentProfile]).
class _ClearOfBottomBar extends StatelessWidget {
  const _ClearOfBottomBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return ColoredBox(
      color: context.appColors.bgCanvas,
      child: Padding(
        padding: EdgeInsets.only(bottom: AppBottomBar.heightOf(context)),
        child: MediaQuery(
          data: media.copyWith(
            padding: media.padding.copyWith(bottom: 0),
            viewPadding: media.viewPadding.copyWith(bottom: 0),
          ),
          child: child,
        ),
      ),
    );
  }
}
