import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The program screens that live in the Anasayfa tab's stack (pano 3.4 to
/// 3.8; flow 13.3), for the children of `HomeTabRoute` in `shellRoutes`:
///
/// - `/home/program`: Programım, the list (`ProgramListView`);
/// - `/home/program/:programId?view=day|week&date=yyyy-MM-dd`: one program
///   with its Gün and Hafta views and edit mode (`ProgramDetailView`).
///
/// Both keep the bottom bar (Anasayfa stays selected, spec T6.10). Anasayfa's
/// "Programım" opens the list with `context.router.push(const
/// ProgramListRoute())`.
List<AutoRoute> get scheduleHomeTabRoutes => [
  AutoRoute(page: ProgramListRoute.page, path: 'program'),
  AutoRoute(page: ProgramDetailRoute.page, path: 'program/:programId'),
];

/// The full-screen program flow, for `AppRouter.routes` at the root: Yeni
/// Program (`NewProgramView`) covers the shell and its bottom bar (pano 3.5
/// "root navigator, tam ekran, alt çubuk yok").
///
/// The path is `/program/new`, not `/home/program/new` as the spec's route
/// map has it: a root route under the shell's `/home` prefix would be read as
/// the program with the id "new" by `/home/program/:programId`. The flow is
/// pushed, never deep-linked. It completes with the saved program's id.
List<AutoRoute> get scheduleRootRoutes => [
  AutoRoute(page: NewProgramRoute.page, path: '/program/new'),
];
