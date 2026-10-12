import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:smap/core/theme/smap_theme.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/scan/presentation/scan_entry.dart';
import 'package:smap/features/scan/presentation/widgets/camera_tones.dart';

/// "Okut": the entry the camera buttons still push (`LegacyScanRoute`, the root
/// route `/scan`; pano 1.19 "Kamera sekme değildir", spec §3.2), now a shim in
/// front of the new scan (`features/scan`).
///
/// It shows the camera's dark page for the moment the gate runs (the
/// permission primer, the refused-permission sheet or the maintenance note
/// open over it), then replaces itself with the scan (`ScanFlowRoute`), or
/// closes itself when the student chose not to go on ("Sonra", "Vazgeç",
/// "Tamam"). The coordinator removes this page and its route when the three
/// callers (the shell's camera button, Anasayfa's "İlk Denemeni Okut", Analizlerim's
/// empty state) call `ScanEntry.start(router)` directly, which also lets the
/// gate's sheets open over the screen the student was on, as the boards draw
/// them.
@RoutePage()
class LegacyScanPage extends StatefulWidget {
  const LegacyScanPage({super.key});

  @override
  State<LegacyScanPage> createState() => _LegacyScanPageState();
}

class _LegacyScanPageState extends State<LegacyScanPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_run());
    });
  }

  Future<void> _run() async {
    final router = context.router;
    final opened = await ScanEntry.start(router, replaceCurrent: true);
    if (!opened && mounted) await router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: SmapTheme.dark(),
      child: Builder(
        builder: (context) => ColoredBox(color: context.appColors.cameraGround),
      ),
    );
  }
}
