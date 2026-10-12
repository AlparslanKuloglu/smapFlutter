import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// The Hesap tab's routes of this task (pano 9.1, 9.2, 9.7; spec §3.6
/// `/account`, `/account/profile`, `/account/agreements`; flow 13.10), for the
/// coordinator to merge into both shells:
///
/// ```dart
/// AutoRoute(page: AccountTabRoute.page, path: 'account', children: accountTabRoutes),
/// AutoRoute(page: CoachAccountTabRoute.page, path: 'account', children: accountTabRoutes),
/// ```
///
/// | path (under the tab) | screen |
/// |---|---|
/// | `` (initial) | `AccountView` (Hesap), the same page for both roles |
/// | `profile` | `ProfileView` |
/// | `agreements` | `ContractsView` |
/// | `agreements/read` | `ContractReaderView(document)` |
///
/// The screens opened from these (E14b: Şifre, Koçluk, Bildirimler) are
/// children of the same tab stack and are listed by that task; Hesabı Sil is
/// a full-screen route on the root stack. `StackAccountNavigator` finds them
/// by route name (`PasswordRoute`, `CoachingRoute`, `NotificationsRoute`,
/// `AccountDeletionRoute`).
///
/// Nothing in this task is a full-screen route, so there are no root routes.
List<AutoRoute> get accountTabRoutes => [
  AutoRoute(page: AccountRoute.page, initial: true),
  AutoRoute(page: ProfileRoute.page, path: 'profile'),
  AutoRoute(page: ContractsRoute.page, path: 'agreements'),
  AutoRoute(page: ContractReaderRoute.page, path: 'agreements/read'),
];
