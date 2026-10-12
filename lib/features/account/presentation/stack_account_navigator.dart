import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/features/account/application/legal_entries.dart';
import 'package:smap/features/account/presentation/account_navigator.dart';

/// An [AccountNavigator] on the stack of the page that owns the ViewModel:
/// Profil, Sözleşmeler and the screens of E14b are pushed on the Hesap tab's
/// own stack, so the bottom bar stays and Back walks it (pano 1.19 "sekme
/// başına yığın"); a full-screen route (Hesabı Sil) is found further up.
///
/// The E14b routes are named by their generated names (`PasswordRoute`,
/// `CoachingRoute`, `NotificationsRoute`, `AccountDeletionRoute`) so this file
/// compiles before those pages exist; [canOpen] asks the routers whether a
/// route of that name is in their collections, so a page that is not
/// registered is neither drawn nor tapped. Once E14b has landed, the names
/// can become the typed route classes.
class StackAccountNavigator implements AccountNavigator {
  const StackAccountNavigator(this._router);

  final StackRouter _router;

  static const Map<AccountDestination, String> _names = {
    AccountDestination.password: 'PasswordRoute',
    AccountDestination.coaching: 'CoachingRoute',
    AccountDestination.notifications: 'NotificationsRoute',
    AccountDestination.deletion: 'AccountDeletionRoute',
  };

  @override
  bool canOpen(AccountDestination destination) {
    final name = _names[destination]!;
    RoutingController? controller = _router;
    while (controller != null) {
      if (controller.routeCollection.containsKey(name)) return true;
      controller = controller.parent();
    }
    return false;
  }

  @override
  Future<void> open(AccountDestination destination) async {
    if (!canOpen(destination)) return;
    await _router.push(PageRouteInfo(_names[destination]!));
  }

  @override
  Future<void> openProfile() => _router.push(const ProfileRoute());

  @override
  Future<void> openContracts() => _router.push(const ContractsRoute());

  @override
  Future<void> openContract(LegalEntry entry) =>
      _router.push(ContractReaderRoute(document: entry.document));
}
