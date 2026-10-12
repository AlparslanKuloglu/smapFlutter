import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The optical scan's route (pano 4.3 to 4.10, 5.1 hand-off; flow 13.4 and
/// 13.5; spec §3.6 `/scan`), for the coordinator to merge into
/// `AppRouter.routes` at the **root**, next to the shells, so the scan covers
/// the shell and its bottom bar:
///
/// ```dart
/// ...scanRootRoutes,
/// ```
///
/// | path | screen |
/// |---|---|
/// | `/scan/flow` | `ScanFlowView`, the whole scan: Çekim, Köşeler, Gönderim, Form Kontrol, Deneme Bulunamadı and the errors, as stages of one route |
///
/// The path is `/scan/flow` while the legacy `/scan` page (`LegacyScanPage`,
/// a shim that runs the gate and replaces itself with this route) is the
/// entry the camera button still pushes. Once the three callers (the shell's
/// camera button, Anasayfa's "İlk Denemeni Okut" and Analizlerim's empty state)
/// call `ScanEntry.start(router)` instead of `push(const LegacyScanRoute())`,
/// delete the shim and its route and give this one the path `/scan`.
///
/// The route is pushed, never deep-linked: it needs the photo of the stage
/// before it. Nothing in it is a tab child.
List<AutoRoute> get scanRootRoutes => [
  AutoRoute(page: ScanFlowRoute.page, path: '/scan/flow'),
];
