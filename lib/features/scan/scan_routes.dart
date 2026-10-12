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
/// | `/scan` | `ScanFlowView`, the whole scan: Çekim, Köşeler, Gönderim, Form Kontrol, Deneme Bulunamadı and the errors, as stages of one route |
///
/// "Okut" opens it through `ScanEntry.start(router)`, which runs the gate
/// (permission primer, refused permission, maintenance) over the screen the
/// student is on first.
///
/// The route is pushed, never deep-linked: it needs the photo of the stage
/// before it. Nothing in it is a tab child.
List<AutoRoute> get scanRootRoutes => [
  AutoRoute(page: ScanFlowRoute.page, path: '/scan'),
];
