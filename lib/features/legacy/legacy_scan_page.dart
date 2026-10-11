import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import 'package:smap/features/legacy/legacy_theme.dart';
import 'package:smap/views/optic_mark_detection_view/optic_mark_detection_view.dart';

/// "Okut": the legacy OMR flow (`OpticMarkDetectionView2`) as a full-screen
/// page of the root router (`/scan`; pano 1.19 "Kamera sekme değildir", spec
/// §3.2), until the scan screens (4.x) replace it.
///
/// It sits on the root stack above the shell, so the bottom bar is covered
/// for the whole flow; the legacy flow's own pushes (`MaterialPageRoute`,
/// `popUntil(isFirst)`) run on the root navigator as they did before, with
/// the shell as the first route.
@RoutePage()
class LegacyScanPage extends StatelessWidget {
  const LegacyScanPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const LegacyTheme(child: OpticMarkDetectionView2());
}
