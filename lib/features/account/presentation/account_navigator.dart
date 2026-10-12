import 'package:smap/features/account/application/legal_entries.dart';

/// The screens of the account area that other tasks own (E14b); the Hesap and
/// Profil screens reach them through [AccountNavigator.open].
enum AccountDestination {
  /// "Şifre" (pano 9.3; `PasswordRoute`). Closed until the backend has an
  /// endpoint, so the route may not exist.
  password,

  /// "Koçluk" (pano 9.5; `CoachingRoute`), a student's screen.
  coaching,

  /// "Bildirimler" (pano 9.6; `NotificationsRoute`).
  notifications,

  /// "Hesabı Sil" (pano 9.4; `AccountDeletionRoute`), full screen.
  deletion,
}

/// Where the account screens lead (pano 13.10): the ViewModels call this, not
/// a router, so a test can record the calls.
///
/// The screens of [AccountDestination] belong to another task; a route that
/// is not in the router (not landed yet, or closed by a feature flag) cannot
/// be opened, and the entry point is not drawn ([canOpen] is `false`).
abstract interface class AccountNavigator {
  /// Whether the router has the route of [destination].
  bool canOpen(AccountDestination destination);

  /// Opens [destination]; completes when its screen is closed.
  Future<void> open(AccountDestination destination);

  /// Profil (pano 9.2).
  Future<void> openProfile();

  /// Sözleşmeler (pano 9.7 kare 1).
  Future<void> openContracts();

  /// The reading screen of one legal text (pano 9.7 kare 2).
  Future<void> openContract(LegalEntry entry);
}
